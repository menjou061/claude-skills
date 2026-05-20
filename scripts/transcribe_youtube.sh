#!/bin/bash
#
# YouTube 视频转录脚本（智能三档降级）
#
# 用法:
#   bash transcribe_youtube.sh <YouTube链接> [输出.md路径]
#
# 环境变量:
#   ASR_LANG=zh|en|auto      ASR 语言（默认 zh；自动转录视频用）
#   FORCE_ASR=1              跳过字幕直接走 ASR（已知字幕不准时）
#   NO_COOKIES=1             不带 Chrome cookies（极少数情况会有用）
#   WHISPER_MODEL=whisper-base-mlx | whisper-large-v3-turbo
#                            模型选择（默认 base，143MB；turbo 更准但 1.6GB）
#
# 智能降级:
#   1) 优先抓字幕（zh-Hans → zh-Hant → zh → en）— 0 成本，秒级
#   2) 有 GROQ_API_KEY → Groq Whisper API — 免费额度内 0 成本，比本地快 5-10x
#   3) 否则 / Groq 失败 → 本地 mlx-whisper ASR — 完全离线，30x 实时
#   4) 会员/付费视频 → 自动带 Chrome cookies + node JS runtime
#
# Groq 配置:
#   GROQ_API_KEY 写入 ~/.claude/settings.json:
#     { "env": { "GROQ_API_KEY": "gsk_..." } }
#   或导出环境变量 GROQ_API_KEY=...
#

set -uo pipefail

# ---- 路径与工具 ----
YT_DLP="${YT_DLP:-$HOME/.local/bin/yt-dlp}"
MLX_WHISPER="${MLX_WHISPER:-$HOME/Library/Python/3.9/bin/mlx_whisper}"
NODE_BIN="${NODE_BIN:-/usr/local/bin/node}"
FFMPEG_BIN="${FFMPEG_BIN:-$HOME/.local/bin/ffmpeg}"

INBOX_DIR="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/menjou-zero/00-Inbox"
MODEL_ROOT="$HOME/.claude/cache/whisper-models"
WHISPER_MODEL="${WHISPER_MODEL:-whisper-base-mlx}"
MODEL_DIR="$MODEL_ROOT/$WHISPER_MODEL"

ASR_LANG="${ASR_LANG:-zh}"
PROXY="${PROXY:-http://127.0.0.1:7897}"

# ---- GROQ_API_KEY 读取（环境变量优先，settings.json 兜底）----
if [[ -z "${GROQ_API_KEY:-}" ]]; then
  GROQ_API_KEY=$(python3 -c "
import json,os
try:
  d=json.load(open(os.path.expanduser('~/.claude/settings.json')))
  print(d.get('env',{}).get('GROQ_API_KEY',''))
except: print('')
" 2>/dev/null || echo "")
fi
GROQ_MAX_CHUNK_MB=20
GROQ_BITRATE="64k"

# ---- 参数 ----
URL="${1:-}"
if [[ -z "$URL" ]]; then
  echo "用法: bash $0 <YouTube链接> [输出.md路径]"
  exit 1
fi
CUSTOM_OUT="${2:-}"

mkdir -p "$INBOX_DIR" "$MODEL_ROOT"
TMPDIR="/tmp/yt_$$"
mkdir -p "$TMPDIR"

cleanup() {
  [[ -d "$TMPDIR" ]] && rm -rf "$TMPDIR" && echo "🧹 清理临时目录: $TMPDIR"
}
trap cleanup EXIT

echo "🎬 YouTube 转录"
echo "===================================="

# ---- 工具自检 ----
[[ -x "$YT_DLP" ]] || { echo "❌ yt-dlp 不在 $YT_DLP"; exit 1; }
[[ -x "$NODE_BIN" ]] || { echo "❌ node 不在 ${NODE_BIN}（yt-dlp-ejs 需要 JS runtime）"; exit 1; }

# ---- Chrome cookies 选项 ----
COOKIE_ARGS=()
if [[ "${NO_COOKIES:-0}" != "1" ]]; then
  COOKIE_ARGS=(--cookies-from-browser chrome)
fi

YTDLP_BASE=("$YT_DLP" --js-runtimes "node:$NODE_BIN" --http-chunk-size 10M --retries 5 --fragment-retries 10 "${COOKIE_ARGS[@]}")

# ---- 代理探测 ----
USE_PROXY=0
if curl -s --max-time 5 --proxy "$PROXY" -o /dev/null https://www.google.com 2>/dev/null; then
  USE_PROXY=1
  echo "🌐 检测到 Clash 代理: $PROXY"
  YTDLP_BASE+=(--proxy "$PROXY")
else
  echo "🌐 无代理（直连）"
fi

# ---- 视频元数据 ----
echo "🔍 获取视频信息..."
META_JSON="$TMPDIR/meta.json"
if ! "${YTDLP_BASE[@]}" --dump-single-json --skip-download "$URL" > "$META_JSON" 2>"$TMPDIR/meta.err"; then
  echo "❌ yt-dlp 元数据获取失败"
  cat "$TMPDIR/meta.err" | tail -20
  exit 1
fi

IFS=$'\t' read -r TITLE DURATION VIDEO_ID < <(python3 -c '
import json,sys
d=json.load(open("'"$META_JSON"'"))
print(d.get("title","unknown"), int(d.get("duration",0)), d.get("id","noid"), sep="\t")
')

DURATION_MIN=$((DURATION / 60))
DURATION_SEC=$((DURATION % 60))
echo "📝 标题: $TITLE"
echo "🆔 ID: $VIDEO_ID"
echo "⏱️  时长: ${DURATION_MIN}分${DURATION_SEC}秒"

# ---- 安全文件名 ----
SAFE_TITLE=$(python3 -c '
import sys,re
t=sys.argv[1]
t=re.sub(r"[<>:\"/\\\\|?*\x00-\x1f]","",t)
t=re.sub(r"\s+","-",t).strip("-")
print(t[:60] if t else "youtube-video")
' "$TITLE")
OUT_PATH="${CUSTOM_OUT:-$INBOX_DIR/${SAFE_TITLE}.md}"

# ---- Stage 1: 字幕路径 ----
TRANSCRIPT=""
SOURCE_KIND=""
SOURCE_TAG=""

try_subtitles() {
  if [[ "${FORCE_ASR:-0}" == "1" ]]; then
    echo "⚠️  FORCE_ASR=1 → 跳过字幕，直接 ASR"
    return 1
  fi

  echo "📥 尝试抓取字幕..."
  for lang in zh-Hans zh-Hant zh en; do
    rm -f "$TMPDIR"/sub.*
    if "${YTDLP_BASE[@]}" \
        --write-subs --write-auto-subs --sub-lang "$lang" \
        --sub-format "vtt" --skip-download \
        -o "$TMPDIR/sub" --ignore-errors \
        "$URL" >/dev/null 2>&1; then
      local f
      f=$(find "$TMPDIR" -name "sub*.vtt" -type f 2>/dev/null | head -1)
      if [[ -n "$f" && -s "$f" ]]; then
        echo "✅ 拿到 $lang 字幕"
        # vtt → 纯文本
        python3 - "$f" > "$TMPDIR/transcript.txt" <<'PYEOF'
import re,sys
with open(sys.argv[1],encoding="utf-8",errors="ignore") as fp: c=fp.read()
c=re.sub(r"WEBVTT.*?\n\n","",c,flags=re.DOTALL)
c=re.sub(r"\d{2}:\d{2}:\d{2}\.\d{3}\s*-->\s*\d{2}:\d{2}:\d{2}\.\d{3}.*","",c)
c=re.sub(r"<[^>]+>","",c)
seen,out=set(),[]
for line in c.splitlines():
    s=line.strip()
    if s and s not in seen:
        seen.add(s); out.append(s)
print("\n".join(out))
PYEOF
        TRANSCRIPT=$(cat "$TMPDIR/transcript.txt")
        SOURCE_KIND="subtitle-$lang"
        SOURCE_TAG="字幕"
        return 0
      fi
    fi
  done
  echo "⚠️  无字幕 / 字幕全部失败"
  return 1
}

# ---- Stage 2: ASR 引导 ----
AUDIO_PATH=""

download_audio() {
  [[ -n "$AUDIO_PATH" && -f "$AUDIO_PATH" ]] && return 0
  echo "⬇️  下载音频..."
  AUDIO_PATH="$TMPDIR/audio.m4a"
  if ! "${YTDLP_BASE[@]}" \
      -f "bestaudio[ext=m4a]/bestaudio" \
      -o "$AUDIO_PATH" "$URL"; then
    echo "❌ 音频下载失败"
    AUDIO_PATH=""
    return 1
  fi
  echo "✅ 音频已下载: $(ls -lh "$AUDIO_PATH" | awk '{print $5}')"
}

# ---- Stage 2a: Groq Whisper API ----
try_groq() {
  if [[ -z "$GROQ_API_KEY" ]]; then
    echo "ℹ️  无 GROQ_API_KEY，跳过 Groq（可在 ~/.claude/settings.json 的 env.GROQ_API_KEY 配置免费 key）"
    return 1
  fi
  [[ -x "$FFMPEG_BIN" ]] || command -v ffmpeg >/dev/null || {
    echo "⚠️  ffmpeg 未装，跳过 Groq"
    return 1
  }

  download_audio || return 1

  echo "🔄 转码 mono 64k mp3（Groq 限制 25MB/请求）..."
  local FF
  FF="${FFMPEG_BIN}"
  [[ -x "$FF" ]] || FF=$(command -v ffmpeg)
  "$FF" -y -i "$AUDIO_PATH" -b:a "$GROQ_BITRATE" -ac 1 "$TMPDIR/mono.mp3" 2>/dev/null || {
    echo "❌ ffmpeg 转码失败"
    return 1
  }

  local SIZE_BYTES
  SIZE_BYTES=$(stat -f%z "$TMPDIR/mono.mp3" 2>/dev/null || stat -c%s "$TMPDIR/mono.mp3")
  local SIZE_MB=$((SIZE_BYTES / 1024 / 1024))
  echo "📦 转码后: ${SIZE_MB}MB"

  local NUM_CHUNKS=1
  local MAX_BYTES=$((GROQ_MAX_CHUNK_MB * 1024 * 1024))
  if [[ "$SIZE_BYTES" -gt "$MAX_BYTES" ]]; then
    NUM_CHUNKS=$(( (SIZE_BYTES / MAX_BYTES) + 1 ))
    local CHUNK_DUR=$(( DURATION / NUM_CHUNKS + 10 ))
    echo "✂️  切 $NUM_CHUNKS 段（每段 ~${CHUNK_DUR}s）..."
    for i in $(seq 0 $((NUM_CHUNKS - 1))); do
      local START=$((i * CHUNK_DUR))
      "$FF" -y -ss "$START" -t "$CHUNK_DUR" -i "$TMPDIR/mono.mp3" -c copy "$TMPDIR/chunk_${i}.mp3" 2>/dev/null
    done
  else
    cp "$TMPDIR/mono.mp3" "$TMPDIR/chunk_0.mp3"
  fi

  echo "🎙️  调用 Groq Whisper API（whisper-large-v3）..."
  local LANG_PARAM="zh"
  [[ "$ASR_LANG" == "auto" ]] && LANG_PARAM=""
  [[ "$ASR_LANG" != "auto" && "$ASR_LANG" != "zh" ]] && LANG_PARAM="$ASR_LANG"

  > "$TMPDIR/groq_full.txt"
  for i in $(seq 0 $((NUM_CHUNKS - 1))); do
    local CHUNK="$TMPDIR/chunk_${i}.mp3"
    local OUT_TXT="$TMPDIR/groq_${i}.txt"
    echo -n "   段 $((i+1))/$NUM_CHUNKS ... "

    local CURL_ARGS=(
      -s -w "\n%{http_code}"
      https://api.groq.com/openai/v1/audio/transcriptions
      -H "Authorization: Bearer $GROQ_API_KEY"
      -F "file=@$CHUNK"
      -F "model=whisper-large-v3"
      -F "response_format=text"
    )
    [[ -n "$LANG_PARAM" ]] && CURL_ARGS+=(-F "language=$LANG_PARAM")

    local RESP HTTP_CODE BODY
    RESP=$(curl "${CURL_ARGS[@]}" 2>/dev/null) || RESP=""
    HTTP_CODE=$(echo "$RESP" | tail -1)
    BODY=$(echo "$RESP" | sed '$d')

    if [[ "$HTTP_CODE" != "200" ]]; then
      echo "❌ HTTP $HTTP_CODE"
      [[ -n "$BODY" ]] && echo "$BODY" | head -3
      return 1
    fi
    echo "$BODY" >> "$TMPDIR/groq_full.txt"
    echo "" >> "$TMPDIR/groq_full.txt"
    echo "✅ $(wc -m < "$OUT_TXT" 2>/dev/null || echo 0)字"
  done

  TRANSCRIPT=$(cat "$TMPDIR/groq_full.txt")
  SOURCE_KIND="groq:whisper-large-v3"
  SOURCE_TAG="Groq Whisper API（云端，准确度高）"
  return 0
}

# ---- Stage 2b: 本地 mlx-whisper ----
bootstrap_model() {
  if [[ -f "$MODEL_DIR/config.json" && -f "$MODEL_DIR/weights.npz" ]]; then
    return 0
  fi
  echo "📦 首次使用，下载模型 ${WHISPER_MODEL}（一次性，~143MB）..."
  mkdir -p "$MODEL_DIR"
  local PROXY_OPT=""
  [[ "$USE_PROXY" -eq 1 ]] && PROXY_OPT="--proxy $PROXY"
  local BASE="https://huggingface.co/mlx-community/${WHISPER_MODEL}/resolve/main"
  for f in config.json weights.npz; do
    echo "  → $f"
    if ! curl -L -C - $PROXY_OPT -o "$MODEL_DIR/$f" "$BASE/$f"; then
      echo "❌ 模型下载失败 ($f)"
      return 1
    fi
  done
  echo "✅ 模型缓存完成: $MODEL_DIR"
}

try_asr() {
  [[ -x "$MLX_WHISPER" ]] || {
    echo "❌ mlx_whisper 未安装（${MLX_WHISPER}）"
    echo "   安装: pip3 install --user mlx-whisper"
    return 1
  }

  bootstrap_model || return 1
  download_audio || return 1

  echo "🎙️  本地 mlx-whisper 转录（语言=${ASR_LANG}）..."
  local LANG_OPT=()
  [[ "$ASR_LANG" != "auto" ]] && LANG_OPT=(--language "$ASR_LANG")

  if ! "$MLX_WHISPER" "$AUDIO_PATH" \
      --model "$MODEL_DIR" \
      "${LANG_OPT[@]}" \
      --output-format txt \
      --output-dir "$TMPDIR"; then
    echo "❌ ASR 转录失败"
    return 1
  fi

  local OUT_TXT
  OUT_TXT=$(find "$TMPDIR" -name "audio.txt" -type f | head -1)
  [[ -z "$OUT_TXT" ]] && { echo "❌ 找不到转录输出"; return 1; }

  TRANSCRIPT=$(cat "$OUT_TXT")
  SOURCE_KIND="mlx-whisper:$WHISPER_MODEL"
  SOURCE_TAG="本地ASR(base模型,部分专名需校对)"
  return 0
}

# ---- 主流程 ----
if ! try_subtitles; then
  echo ""
  echo "🔁 降级 → Groq API"
  echo "------------------------------------"
  if ! try_groq; then
    echo ""
    echo "🔁 再降级 → 本地 mlx-whisper"
    echo "------------------------------------"
    if ! try_asr; then
      echo "❌ 所有路径失败，无法转录"
      exit 1
    fi
  fi
fi

# ---- 写入 Obsidian ----
TODAY=$(date +%Y-%m-%d)
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# 转义 frontmatter 双引号
TITLE_ESC=${TITLE//\"/\\\"}

{
  echo "---"
  echo "title: \"$TITLE_ESC\""
  echo "source: \"YouTube\""
  echo "source_url: \"$URL\""
  echo "date: \"$TODAY\""
  echo "duration: \"${DURATION_MIN}分${DURATION_SEC}秒\""
  echo "tags: [视频, 待整理]"
  echo "type: video"
  echo "status: raw-transcript"
  echo "asr_model: \"$SOURCE_KIND\""
  echo "---"
  echo ""
  echo "# $TITLE"
  echo ""
  echo "- 来源: [$URL]($URL)"
  echo "- 时长: ${DURATION_MIN}分${DURATION_SEC}秒"
  echo "- 转录方式: $SOURCE_TAG"
  echo "- 转录时间: $TIMESTAMP"
  echo ""
  if [[ "$SOURCE_KIND" == mlx-whisper:* ]]; then
    echo "> ⚠️ base 模型转录，部分专有名词可能需校对（如 \"再平衡/做市商/对冲基金/养老金/申购/赎回/净值\" 等同音字）"
    echo ""
  fi
  echo "---"
  echo ""
  echo "$TRANSCRIPT"
} > "$OUT_PATH"

CHARS=$(wc -m < "$OUT_PATH" | tr -d ' ')
echo ""
echo "===================================="
echo "✅ 完成"
echo "📄 输出: $OUT_PATH"
echo "📊 字符数: $CHARS"
echo "🔧 路径: $SOURCE_KIND"
