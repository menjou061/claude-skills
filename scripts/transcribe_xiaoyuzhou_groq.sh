#!/bin/bash
# 小宇宙播客转文字脚本（Groq API + 本地 Whisper 备用）
# 用法: bash transcribe_xiaoyuzhou_groq.sh <小宇宙链接> [输出文件路径]

set -e

URL="${1:?用法: bash $0 <小宇宙链接> [输出文件路径]}"
INBOX_DIR="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/menjou-zero/00-Inbox"
mkdir -p "$INBOX_DIR"
OUTPUT="${2:-$INBOX_DIR/xiaoyuzhou_$(date +%Y%m%d_%H%M%S).md}"
TMPDIR="/tmp/xiaoyuzhou_$$"

# 从配置文件读取 GROQ_API_KEY
CONFIG_FILE="$HOME/.claude/settings.json"
if [ -f "$CONFIG_FILE" ]; then
    GROQ_API_KEY=$(python3 -c "import json; d=json.load(open('$CONFIG_FILE')); print(d.get('env',{}).get('GROQ_API_KEY',''))" 2>/dev/null || true)
fi

USE_LOCAL_WHISPER=false
MAX_CHUNK_SIZE_MB=20
AUDIO_BITRATE="64k"

# 清理临时文件
cleanup() {
    if [ -d "$TMPDIR" ]; then
        rm -rf "$TMPDIR"
        echo "🧹 已清理临时文件: $TMPDIR"
    fi
}

# 脚本退出时自动清理
trap cleanup EXIT

# 清理 Whisper 模型缓存（可选，节省磁盘空间）
cleanup_whisper_cache() {
    local cache_dir="$HOME/.cache/huggingface/hub"
    if [ -d "$cache_dir" ]; then
        # 清理 tiny 模型的缓存（约 40MB）
        find "$cache_dir" -name "*whisper*tiny*" -type d 2>/dev/null | while read dir; do
            echo "   清理 Whisper 缓存: $(basename "$dir")"
            rm -rf "$dir" 2>/dev/null || true
        done
    fi
}

mkdir -p "$TMPDIR"

echo "📻 小宇宙播客转文字"
echo "===================================="

# Step 1: 提取音频 URL 和标题
echo "🔍 正在解析页面..."
PAGE=$(curl -s "$URL")
AUDIO_URL=$(echo "$PAGE" | grep -oE 'https://media\.xyzcdn\.net/[^"]*\.(m4a|mp3)' | head -1)
TITLE=$(echo "$PAGE" | grep -oE '"title":"[^"]*"' | head -1 | sed 's/"title":"//;s/"$//')

if [ -z "$AUDIO_URL" ]; then
    echo "❌ 无法从页面提取音频链接"
    exit 1
fi

echo "📝 标题: $TITLE"
echo "🔗 音频: $AUDIO_URL"

# 生成安全的文件名（使用标题）
SAFE_TITLE=$(echo "$TITLE" | sed 's/[[:space:]]/_/g' | sed 's/[<>:"|?*]//g' | cut -c1-50)
OUTPUT="${2:-$INBOX_DIR/${SAFE_TITLE}.md}"

# Step 2: 下载音频
echo "⬇️  正在下载音频..."
EXT="${AUDIO_URL##*.}"
curl -sL -o "$TMPDIR/original.$EXT" "$AUDIO_URL"
FILE_SIZE=$(ls -lh "$TMPDIR/original.$EXT" | awk '{print $5}')
echo "📦 文件大小: $FILE_SIZE"

# Step 3: 检查 ffmpeg
if ! command -v ffmpeg &> /dev/null; then
    echo "❌ 需要安装 ffmpeg: brew install ffmpeg"
    exit 1
fi

# Step 4: 转为低码率单声道 MP3
echo "🔄 正在转码..."
ffmpeg -y -i "$TMPDIR/original.$EXT" -b:a "$AUDIO_BITRATE" -ac 1 "$TMPDIR/mono.mp3" 2>/dev/null
MONO_SIZE=$(stat -c%s "$TMPDIR/mono.mp3" 2>/dev/null || stat -f%z "$TMPDIR/mono.mp3")
SIZE_MB=$((MONO_SIZE / 1024 / 1024))
echo "📦 转码后: ${SIZE_MB}MB"

# Step 5: 获取时长（先 ffprobe mono.mp3，失败则按 64kbps 估算）
DURATION=$(ffprobe -v quiet -show_entries format=duration -of csv=p=0 "$TMPDIR/mono.mp3" 2>/dev/null | cut -d. -f1)
if [ -z "$DURATION" ] || [ "$DURATION" = "0" ]; then
    # 64kbps = 8000 字节/秒
    DURATION=$((MONO_SIZE / 8000))
    echo "⏱️  时长（按文件大小估算）: $((DURATION / 60))分$((DURATION % 60))秒"
else
    echo "⏱️  时长: $((DURATION / 60))分$((DURATION % 60))秒"
fi
DURATION_MIN=$((DURATION / 60))
DURATION_SEC=$((DURATION % 60))

# Step 5: 按大小切片
MAX_BYTES=$((MAX_CHUNK_SIZE_MB * 1024 * 1024))

if [ "$MONO_SIZE" -le "$MAX_BYTES" ]; then
    cp "$TMPDIR/mono.mp3" "$TMPDIR/chunk_0.mp3"
    NUM_CHUNKS=1
    echo "📎 无需切片"
else
    NUM_CHUNKS=$(( (MONO_SIZE / MAX_BYTES) + 1 ))
    CHUNK_DURATION=$(( DURATION / NUM_CHUNKS + 10 ))
    echo "✂️  切分为 $NUM_CHUNKS 段..."

    for i in $(seq 0 $((NUM_CHUNKS - 1))); do
        START=$((i * CHUNK_DURATION))
        ffmpeg -y -i "$TMPDIR/mono.mp3" -ss "$START" -t "$CHUNK_DURATION" -c copy "$TMPDIR/chunk_${i}.mp3" 2>/dev/null
        echo "   段 $((i+1))/$NUM_CHUNKS 完成"
    done
fi

# ========== 转录函数 ==========

# Groq API 转录（带重试，处理限速）
transcribe_groq() {
    local chunk="$1"
    local output="$2"
    local max_retries=4

    if [ -z "$GROQ_API_KEY" ]; then
        return 1
    fi

    for retry in $(seq 1 $max_retries); do
        RESPONSE=$(curl -s -w "\n%{http_code}" \
            ${GROQ_PROXY:+-x "$GROQ_PROXY"} \
            --max-time 300 \
            https://api.groq.com/openai/v1/audio/transcriptions \
            -H "Authorization: Bearer $GROQ_API_KEY" \
            -F file="@$chunk" \
            -F model="whisper-large-v3" \
            -F language="zh" \
            -F response_format="text" 2>/dev/null)

        HTTP_CODE=$(echo "$RESPONSE" | tail -1)
        BODY=$(echo "$RESPONSE" | sed '$d')

        if [ "$HTTP_CODE" = "200" ]; then
            echo "$BODY" > "$output"
            return 0
        fi

        # 429 = 限速，从响应头读 retry-after 或固定等待
        if [ "$HTTP_CODE" = "429" ]; then
            local wait_sec=$((30 * retry))
            echo "" >&2
            echo "   ⏳ Groq 限速 (429)，等 ${wait_sec}s 后重试 ($retry/$max_retries)..." >&2
            sleep "$wait_sec"
            continue
        fi

        # 其他错误（401/403/413/5xx）打印诊断信息后放弃
        echo "" >&2
        echo "   ❌ Groq HTTP $HTTP_CODE: $(echo "$BODY" | head -c 200)" >&2
        return 1
    done
    return 1
}

# 本地 Whisper 转录
transcribe_local() {
    local chunk="$1"
    local output="$2"

    # 检查是否安装了 faster-whisper
    if ! python3 -c "import faster_whisper" 2>/dev/null; then
        echo ""
        echo "⚠️  Groq API 失败，且未安装 faster-whisper"
        echo ""
        echo "安装本地 Whisper："
        echo "  pip3 install faster-whisper"
        echo ""
        return 1
    fi

    python3 -c "
from faster_whisper import WhisperModel
import sys

model = WhisperModel('small', device='cpu', compute_type='int8')
segments, info = model.transcribe('$chunk', language='zh', beam_size=5)
text = ''.join([s.text for s in segments])
print(text, end='')
" > "$output" 2>/dev/null

    return 0
}

# ========== 执行转录 ==========

echo ""
if [ "$USE_LOCAL_ONLY" = "1" ]; then
    echo "🎙️  使用本地 Whisper small 模型（已强制本地）..."
    USE_GROQ=false
elif [ -n "$GROQ_API_KEY" ]; then
    echo "🎙️  尝试 Groq Whisper API (云端，快速)..."
    USE_GROQ=true
else
    echo "🎙️  使用本地 Whisper (离线)..."
    USE_GROQ=false
fi

GROQ_FAILED=false

for i in $(seq 0 $((NUM_CHUNKS - 1))); do
    CHUNK_FILE="$TMPDIR/chunk_${i}.mp3"
    OUTPUT_FILE="$TMPDIR/transcript_${i}.txt"

    echo -n "   段 $((i+1))/$NUM_CHUNKS... "

    if [ "$USE_GROQ" = true ] && [ "$GROQ_FAILED" = false ]; then
        # 尝试 Groq API
        if transcribe_groq "$CHUNK_FILE" "$OUTPUT_FILE"; then
            CHARS=$(wc -m < "$OUTPUT_FILE")
            echo "✅ Groq ($CHARS 字)"
            continue
        else
            echo "⚠️  Groq 失败，切换到本地..."
            GROQ_FAILED=true
        fi
    fi

    # 使用本地 Whisper
    if transcribe_local "$CHUNK_FILE" "$OUTPUT_FILE"; then
        CHARS=$(wc -m < "$OUTPUT_FILE")
        if [ "$GROQ_FAILED" = true ]; then
            echo "   ✅ 本地 Whisper ($CHARS 字)"
        else
            echo "✅ 本地 Whisper ($CHARS 字)"
        fi
    else
        echo "❌ 转录失败"
        exit 1
    fi
done

# ========== 合并输出 ==========

echo ""
echo "📄 正在合并文字稿..."

METHOD="Groq Whisper"
if [ "$USE_LOCAL_ONLY" = "1" ]; then
    METHOD="本地 Whisper small"
elif [ "$GROQ_FAILED" = true ]; then
    METHOD="本地 Whisper (Groq API 失败，自动切换)"
elif [ -z "$GROQ_API_KEY" ]; then
    METHOD="本地 Whisper"
fi

{
    echo "# $TITLE"
    echo ""
    echo "来源: $URL"
    echo "时长: ${DURATION_MIN}分${DURATION_SEC}秒"
    echo "转录方式: $METHOD"
    echo "转录时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    echo "---"
    echo ""

    for i in $(seq 0 $((NUM_CHUNKS - 1))); do
        cat "$TMPDIR/transcript_${i}.txt"
        echo ""
    done
} > "$OUTPUT"

TOTAL_CHARS=$(wc -m < "$OUTPUT")
echo ""
echo "✅ 完成！"
echo "📄 输出: $OUTPUT"
echo "📊 总字数: $TOTAL_CHARS"
echo "🔧 方式: $METHOD"

# 如果使用了本地 Whisper，询问是否清理模型缓存
if [ "$USE_GROQ" = false ] || [ "$GROQ_FAILED" = true ]; then
    echo ""
    echo "💡 提示: 本地 Whisper 模型缓存约 40MB，可手动清理:"
    echo "   rm -rf ~/.cache/huggingface/hub/*whisper*tiny*"
fi
