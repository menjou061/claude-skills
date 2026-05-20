#!/bin/bash
#
# Pre-process Longbridge data for finance-news prompt
# Output: ~/.claude/cache/lb-snapshot.md (~80-120 lines, pre-computed)
#
# Purpose: shift 30+ tool calls + raw kline dumps OUT of the claude prompt
# into local shell, so the AI only reads a compact summary.
#

set -uo pipefail

export PATH="/Users/liuyizhen/.npm-global/bin:/Users/liuyizhen/.local/bin:/Users/liuyizhen/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
export https_proxy="http://127.0.0.1:7897"
export http_proxy="http://127.0.0.1:7897"
export all_proxy="socks5://127.0.0.1:7897"
export HTTPS_PROXY="http://127.0.0.1:7897"
export HTTP_PROXY="http://127.0.0.1:7897"
export ALL_PROXY="socks5://127.0.0.1:7897"
export no_proxy="localhost,127.0.0.1"

CACHE_DIR="$HOME/.claude/cache"
KLINE_DIR="$CACHE_DIR/lb_klines"
mkdir -p "$KLINE_DIR"
SNAPSHOT="$CACHE_DIR/lb-snapshot.md"

YSJJ_CHANNEL="UCFQsi7WaF5X41tcuOryDk8w"
YSJJ_TRANSCRIPT="$CACHE_DIR/ysjj-transcript.md"
YSJJ_LAST_ID="$CACHE_DIR/ysjj-last-video-id.txt"

# 相谈比特币频道（每天发两类视频：美股分析 + 加密策略；抓最近2期）
XIANTAN_CHANNEL="UC-t8ZzFopPZsBEsKvOj9UPQ"
XIANTAN_CACHE_DIR="$CACHE_DIR/xiantan"
mkdir -p "$XIANTAN_CACHE_DIR"

# Cookies 文件存在 ~/.claude/cache/（launchd 有权限读取；~/Downloads 受 TCC 沙箱限制）
YT_COOKIES_HEADER="$CACHE_DIR/youtube_cookies_header.txt"
YT_COOKIES_NETSCAPE="$CACHE_DIR/youtube_cookies_netscape.txt"

# Convert header-string cookies to Netscape format (yt-dlp requirement)
_convert_yt_cookies() {
  [[ -f "$YT_COOKIES_HEADER" ]] || { echo "WARN: YT cookies not found at $YT_COOKIES_HEADER"; return 1; }
  python3 - "$YT_COOKIES_HEADER" "$YT_COOKIES_NETSCAPE" << 'PYEOF'
import sys
src, dst = sys.argv[1], sys.argv[2]
raw = open(src).read().strip()
lines = ["# Netscape HTTP Cookie File"]
for pair in raw.split(";"):
    pair = pair.strip()
    if "=" not in pair:
        continue
    name, _, value = pair.partition("=")
    name = name.strip()
    secure = "TRUE" if name.startswith("__Secure-") or name.startswith("__Host-") else "FALSE"
    lines.append(f".youtube.com\tTRUE\t/\t{secure}\t1893456000\t{name}\t{value}")
open(dst, "w").write("\n".join(lines) + "\n")
PYEOF
}

# Fetch latest video ID from channel
_ysjj_latest_video_id() {
  yt-dlp --cookies "$YT_COOKIES_NETSCAPE" --js-runtimes node \
    --flat-playlist --playlist-end 1 --dump-json --no-warnings \
    "https://www.youtube.com/channel/${YSJJ_CHANNEL}/videos" 2>/dev/null \
    | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['id'])" 2>/dev/null
}

# Transcribe latest video if it's new; write to YSJJ_TRANSCRIPT
_ysjj_transcribe_if_new() {
  _convert_yt_cookies || return 1

  local vid_id
  vid_id=$(_ysjj_latest_video_id)
  [[ -z "$vid_id" ]] && { echo "WARN: could not fetch latest video ID"; return 1; }

  local last_id=""
  [[ -f "$YSJJ_LAST_ID" ]] && last_id=$(cat "$YSJJ_LAST_ID")

  if [[ "$vid_id" == "$last_id" && -f "$YSJJ_TRANSCRIPT" && -s "$YSJJ_TRANSCRIPT" ]]; then
    echo "  (视野视频无更新，使用缓存转录 video_id=$vid_id)"
    return 0
  fi

  echo "  转录新视频 $vid_id ..."
  local audio="/tmp/ysjj_${vid_id}.mp3"
  local dl_ok=0
  for attempt in 1 2; do
    yt-dlp -q -x --audio-format mp3 --audio-quality 5 -o "/tmp/ysjj_${vid_id}.%(ext)s" \
      --cookies "$YT_COOKIES_NETSCAPE" --js-runtimes node \
      "https://www.youtube.com/watch?v=${vid_id}" 2>&1 | sed "s/^/  [yt-dlp attempt $attempt] /"
    [[ -f "$audio" ]] && { dl_ok=1; break; }
    echo "  WARN: audio download failed (attempt $attempt), retrying in 10s..."
    sleep 10
  done
  [[ $dl_ok -eq 1 ]] || { echo "WARN: audio download failed after 2 attempts"; return 1; }

  python3 - "$audio" "$YSJJ_TRANSCRIPT" "$vid_id" << 'PYEOF'
import sys, warnings, whisper
warnings.filterwarnings("ignore")
audio_path, out_path, vid_id = sys.argv[1], sys.argv[2], sys.argv[3]
model = whisper.load_model("large-v3-turbo")
result = model.transcribe(audio_path, language="zh", verbose=False, fp16=False)
with open(out_path, "w") as f:
    f.write(f"<!-- video_id: {vid_id} -->\n")
    for seg in result["segments"]:
        t = int(seg["start"])
        ts = f"{t//60:02d}:{t%60:02d}"
        f.write(f"[{ts}] {seg['text'].strip()}\n")
print(f"Done: {len(result['segments'])} segments")
PYEOF

  rm -f "$audio"
  echo "$vid_id" > "$YSJJ_LAST_ID"
}

# Print section for snapshot: transcript or cached content
_ysjj_transcript_section() {
  local log
  log=$(_ysjj_transcribe_if_new 2>&1)
  local rc=$?
  echo "$log" | grep -v "^$" || true
  if [[ $rc -eq 0 && -f "$YSJJ_TRANSCRIPT" && -s "$YSJJ_TRANSCRIPT" ]]; then
    local _ysjj_vid_id
    _ysjj_vid_id=$(head -1 "$YSJJ_TRANSCRIPT" | grep -o 'video_id: [^>]*' | cut -d' ' -f2)
    echo "_video_id: ${_ysjj_vid_id}_"
    echo ""
    tail -n +2 "$YSJJ_TRANSCRIPT"
  else
    echo "转录失败或缓存为空（rc=${rc}）"
  fi
}

# ── 相谈比特币：抓最近2期视频并转录（每期缓存到独立文件）──────────────────

_xiantan_get_recent_ids() {
  yt-dlp --cookies "$YT_COOKIES_NETSCAPE" --js-runtimes node \
    --flat-playlist --playlist-end 2 --dump-json --no-warnings \
    "https://www.youtube.com/channel/${XIANTAN_CHANNEL}/videos" 2>/dev/null \
    | python3 -c "
import sys, json
for line in sys.stdin:
    line = line.strip()
    if line:
        try:
            d = json.loads(line)
            print(d['id'])
        except: pass
" 2>/dev/null
}

_xiantan_transcribe_one() {
  local vid_id="$1"
  local out="$XIANTAN_CACHE_DIR/${vid_id}.md"
  [[ -f "$out" && -s "$out" ]] && { echo "  (缓存命中 $vid_id)"; return 0; }

  echo "  转录相谈比特币 $vid_id ..."
  local audio="/tmp/xiantan_${vid_id}.mp3"
  local dl_ok=0
  for attempt in 1 2; do
    yt-dlp -q -x --audio-format mp3 --audio-quality 5 -o "/tmp/xiantan_${vid_id}.%(ext)s" \
      --cookies "$YT_COOKIES_NETSCAPE" --js-runtimes node \
      "https://www.youtube.com/watch?v=${vid_id}" 2>&1 | sed "s/^/  [yt-dlp attempt $attempt] /"
    [[ -f "$audio" ]] && { dl_ok=1; break; }
    echo "  WARN: 音频下载失败 $vid_id (attempt $attempt), retrying in 10s..."
    sleep 10
  done
  [[ $dl_ok -eq 1 ]] || { echo "WARN: 音频下载失败 $vid_id after 2 attempts"; return 1; }

  python3 - "$audio" "$out" "$vid_id" << 'PYEOF'
import sys, warnings, whisper
warnings.filterwarnings("ignore")
audio_path, out_path, vid_id = sys.argv[1], sys.argv[2], sys.argv[3]
model = whisper.load_model("large-v3-turbo")
result = model.transcribe(audio_path, language="zh", verbose=False, fp16=False)
with open(out_path, "w") as f:
    f.write(f"<!-- video_id: {vid_id} -->\n")
    for seg in result["segments"]:
        t = int(seg["start"])
        ts = f"{t//60:02d}:{t%60:02d}"
        f.write(f"[{ts}] {seg['text'].strip()}\n")
print(f"Done: {len(result['segments'])} segments")
PYEOF
  rm -f "$audio"
}

_xiantan_transcript_section() {
  local vid_id count f ids
  _convert_yt_cookies || { echo "相谈比特币：cookies 转换失败，跳过"; return; }

  ids=$(_xiantan_get_recent_ids)
  [[ -z "$ids" ]] && { echo "相谈比特币：无法获取视频列表，跳过"; return; }

  count=0
  while IFS= read -r vid_id; do
    [[ -z "$vid_id" ]] && continue
    _xiantan_transcribe_one "$vid_id" 2>&1 | grep -v "^$" || true
    f="$XIANTAN_CACHE_DIR/${vid_id}.md"
    if [[ -f "$f" && -s "$f" ]]; then
      echo ""
      echo "### 视频 $((count+1))（video_id: ${vid_id}）"
      tail -n +2 "$f"
      count=$((count+1))
    fi
  done <<< "$ids"

  [[ $count -eq 0 ]] && echo "转录失败或缓存为空"
}

ALL_SYMS="SPY.US MSFT.US GOOG.US NVDA.US TSLA.US COIN.US DUOL.US QQQ.US 1810.HK"

END=$(date +%Y-%m-%d)
START=$(date -v-380d +%Y-%m-%d 2>/dev/null || date -d "380 days ago" +%Y-%m-%d)

# Pre-fetch all klines in PARALLEL with retry (forward-adjusted, JSON) into cache dir.
# Empty / failed responses keep the previous good file so the snapshot stays usable
# even when longbridge throttles or the proxy hiccups.
for sym in $ALL_SYMS; do
  (
    tmp="$KLINE_DIR/$sym.json.tmp"
    target="$KLINE_DIR/$sym.json"
    for attempt in 1 2 3; do
      if longbridge kline history "$sym" --period day --start "$START" --end "$END" \
           --adjust forward --format json > "$tmp" 2>/dev/null && [[ -s "$tmp" ]]; then
        mv "$tmp" "$target"
        break
      fi
      sleep 1
    done
    rm -f "$tmp"
  ) &
done
wait

{
  echo "# Longbridge Snapshot — $(date '+%Y-%m-%d %H:%M:%S %Z')"
  echo ""
  echo "_(Pre-computed by lb-snapshot.sh; raw JSON klines cached at $KLINE_DIR)_"
  echo ""

  echo "## 账户"
  longbridge portfolio 2>/dev/null | grep -E "Total|Cash|^\| P/?L|Risk|Margin|Available" | head -8 || echo "N/A"
  echo ""

  echo "## 持仓 8 票现价（盘中主表）"
  longbridge quote $ALL_SYMS 2>/dev/null | sed -n '1,12p' || echo "N/A"
  echo ""

  echo "## 市场温度"
  longbridge market-temp US 2>/dev/null || echo "US: N/A"
  echo ""
  longbridge market-temp HK 2>/dev/null || echo "HK: N/A"
  echo ""

  echo "## VIX 现货"
  vix_out=$(longbridge quote .VIX.US 2>/dev/null)
  if [[ -n "$vix_out" && "$vix_out" == *".VIX.US"* ]]; then
    echo "$vix_out" | sed -n '1,3p'
  else
    echo "N/A"
  fi
  echo ""

  echo "## 组合宽度 + 回撤 + 8 票技术面（本地计算）"
  python3 - "$KLINE_DIR" <<'PYEOF'
import json, os, sys
kline_dir = sys.argv[1]
syms = ["SPY.US","MSFT.US","GOOG.US","NVDA.US","TSLA.US","COIN.US","DUOL.US","1810.HK"]
ma_periods = [5, 20, 50, 200]
above = {p: [] for p in ma_periods}
dd_rows = []
tech_rows = []

def f(v, default=0.0):
    try: return float(v)
    except: return default

for sym in syms:
    path = os.path.join(kline_dir, f"{sym}.json")
    if not os.path.exists(path) or os.path.getsize(path) == 0:
        tech_rows.append({"sym": sym, "missing": True})
        continue
    try:
        with open(path) as fh:
            data = json.load(fh)
        if not data:
            tech_rows.append({"sym": sym, "missing": True})
            continue
        closes = [f(d["close"]) for d in data]
        highs  = [f(d["high"])  for d in data]
        lows   = [f(d["low"])   for d in data]
        vols   = [f(d.get("volume")) for d in data]
        last = closes[-1]
        last_vol = vols[-1] if vols else 0.0
        for p in ma_periods:
            if len(closes) >= p:
                ma = sum(closes[-p:]) / p
                if last > ma:
                    above[p].append(sym)
        n = min(252, len(highs))
        h52 = max(highs[-n:])
        l52 = min(lows[-n:])
        dd = (last - h52) / h52 * 100 if h52 else 0
        dd_rows.append((sym, last, h52, dd))
        ma20  = sum(closes[-20:])/20  if len(closes) >= 20  else None
        ma50  = sum(closes[-50:])/50  if len(closes) >= 50  else None
        ma200 = sum(closes[-200:])/200 if len(closes) >= 200 else None
        ret_5d  = (last/closes[-6]  - 1)*100 if len(closes) >= 6  else None
        ret_20d = (last/closes[-21] - 1)*100 if len(closes) >= 21 else None
        avg_vol_20 = sum(vols[-20:])/20 if len(vols) >= 20 else None
        vol_ratio = (last_vol/avg_vol_20) if (avg_vol_20 and avg_vol_20 > 0) else None
        ma20_5d_ago = sum(closes[-25:-5])/20 if len(closes) >= 25 else None
        if ma20 is None or ma20_5d_ago is None:
            slope = "—"
        elif ma20 > ma20_5d_ago * 1.002:
            slope = "↑"
        elif ma20 < ma20_5d_ago * 0.998:
            slope = "↓"
        else:
            slope = "→"
        tech_rows.append({
            "sym": sym, "last": last, "h52": h52, "l52": l52,
            "ma20": ma20, "ma50": ma50, "ma200": ma200,
            "ret_5d": ret_5d, "ret_20d": ret_20d,
            "vol_ratio": vol_ratio, "slope": slope, "missing": False,
        })
    except Exception as e:
        print(f"<!-- {sym} parse err: {e} -->")
        tech_rows.append({"sym": sym, "missing": True})

print("### 宽度 (% above MA)")
for p in ma_periods:
    pct = len(above[p]) / len(syms) * 100
    members = ", ".join(s.split(".")[0] for s in above[p])
    print(f"- **{p}d**: {len(above[p])}/{len(syms)} = {pct:.0f}% — {members}")
print()
print("### 回撤 (from 52w high, sorted)")
dd_rows.sort(key=lambda x: x[3])
for sym, last, h52, dd in dd_rows:
    flag = " ⚠️" if dd < -50 else (" ✅" if dd > -1 else "")
    print(f"- {sym}: {last:.2f} vs 52w-high {h52:.2f} = {dd:+.1f}%{flag}")

print()
print("### 持仓 8 票技术面（金铲铲 Priority 3 用，prompt 直接读勿重算）")
print("| 票 | 现价 | MA20 (距%) | MA50 (距%) | MA200 (距%) | MA20 趋势 | 5d% | 20d% | 当日量比 | 距 52w 高 | 距 52w 低 |")
print("|---|---|---|---|---|---|---|---|---|---|---|")
def fmt_dist(price, ma):
    if ma is None: return "—"
    return f"{ma:.2f} ({(price/ma-1)*100:+.1f}%)"
def fmt_pct(v):
    if v is None: return "—"
    return f"{v:+.1f}%"
def fmt_vol(v):
    if v is None: return "—"
    return f"{v:.2f}x"
for r in tech_rows:
    if r.get("missing"):
        print(f"| {r['sym']} | ⚠️ 数据缺失 |  |  |  |  |  |  |  |  |  |")
        continue
    last = r["last"]
    print(f"| {r['sym']} | {last:.2f} | {fmt_dist(last, r['ma20'])} | {fmt_dist(last, r['ma50'])} | {fmt_dist(last, r['ma200'])} | {r['slope']} | {fmt_pct(r['ret_5d'])} | {fmt_pct(r['ret_20d'])} | {fmt_vol(r['vol_ratio'])} | {(last/r['h52']-1)*100:+.1f}% | {(last/r['l52']-1)*100:+.1f}% |")
PYEOF
  echo ""

  echo "## NVDA 内部人交易（最近 20 条）"
  longbridge insider-trades NVDA.US 2>/dev/null | head -25 || echo "N/A"
  echo ""

  echo "## 各票新闻标题（每票最近 5 条）"
  # Parallel news fetch — write to per-sym files, then concat in order
  NEWS_DIR="$CACHE_DIR/news_tmp"
  rm -rf "$NEWS_DIR" && mkdir -p "$NEWS_DIR"
  for sym in $ALL_SYMS; do
    (
      {
        echo "### $sym"
        longbridge news "$sym" 2>/dev/null | sed -n '3,8p' || echo "N/A"
        echo ""
      } > "$NEWS_DIR/$sym.txt"
    ) &
  done
  wait
  for sym in $ALL_SYMS; do
    cat "$NEWS_DIR/$sym.txt"
  done

  echo "## 视野环球财经最新视频转录摘要"
  _ysjj_transcript_section
  echo ""

  echo "## 相谈比特币最近2期视频转录摘要（辩证分析，观点仅供参考）"
  _xiantan_transcript_section
  echo ""

  echo "## COIN 加密参考（btc snapshot — Binance + Deribit，COIN 特殊分析用）"
  /Users/liuyizhen/.local/bin/btc snapshot 2>/dev/null || echo "btc CLI 不可用或代理未通"
  echo ""

} > "$SNAPSHOT" 2>&1

# Stats footer (printed to stdout, not the snapshot)
echo "✓ Snapshot: $SNAPSHOT"
echo "  size: $(wc -l < "$SNAPSHOT") lines, $(wc -c < "$SNAPSHOT") bytes"
