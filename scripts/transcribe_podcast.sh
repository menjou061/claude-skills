#!/bin/bash
# 智能播客转写工具 - 自动识别平台并选择转写方法

source_url="$1"
output_dir="${2:-/tmp/podcast_transcripts}"

# 创建输出目录
mkdir -p "$output_dir"

# 检测 URL 类型
detect_platform() {
    local url="$1"
    
    if [[ "$url" =~ youtube\.com ]] || [[ "$url" =~ youtu\.be ]]; then
        echo "youtube"
    elif [[ "$url" =~ xiaoyuzhoufm\.com ]]; then
        echo "xiaoyuzhou"
    elif [[ "$url" =~ ximalaya\.com ]]; then
        echo "ximalaya"
    elif [[ "$url" =~ bilibili\.com ]]; then
        echo "bilibili"
    else
        echo "unknown"
    fi
}

# 转写 YouTube (使用 yt-dlp 获取字幕)
transcribe_youtube() {
    local url="$1"
    local output="$2"
    
    echo "🎬 检测到 YouTube 链接，提取字幕..."
    
    # 尝试获取字幕
    yt-dlp --write-auto-sub --sub-lang zh-Hans,zh-Hant,zh,en \
           --skip-download \
           --sub-format txt \
           -o "$output" \
           "$url" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "✅ YouTube 字幕提取成功"
        return 0
    else
        echo "⚠️ YouTube 字幕提取失败，尝试音频转写..."
        # 下载音频并用 Whisper 转写
        local audio_file="/tmp/youtube_audio_$(date +%s).m4a"
        yt-dlp -f "ba" -o "$audio_file" "$url"
        transcribe_audio "$audio_file" "$output"
        rm -f "$audio_file"
        return $?
    fi
}

# 转写小宇宙 (下载音频 + Whisper)
transcribe_xiaoyuzhou() {
    local url="$1"
    local output="$2"
    
    echo "🎙️ 检测到小宇宙链接，下载音频并转写..."
    
    # 获取页面信息
    local page_data=$(curl -s "$url")
    
    # 提取音频 URL (需要改进)
    local audio_url=$(echo "$page_data" | grep -o 'https://media\.xyzcdn\.net/[^"]*\.m4a' | head -1)
    
    if [ -z "$audio_url" ]; then
        echo "❌ 无法提取音频 URL"
        return 1
    fi
    
    # 下载音频
    local audio_file="/tmp/xiaoyuzhou_$(date +%s).m4a"
    echo "下载音频..."
    curl -sL -o "$audio_file" "$audio_url"
    
    # 转写
    transcribe_audio "$audio_file" "$output"
    local result=$?
    
    # 清理
    rm -f "$audio_file"
    
    return $result
}

# 通用音频转写
transcribe_audio() {
    local audio_file="$1"
    local output="$2"
    
    echo "🔄 开始转写音频..."
    
    python3 << PYTHON_EOF
import sys
sys.path.insert(0, '/Users/liuyizhen/Library/Python/3.9/lib/python/site-packages')

from faster_whisper import WhisperModel

model = WhisperModel("small", device="cpu", compute_type="int8")

segments, info = model.transcribe(
    "$audio_file",
    language="zh",
    beam_size=5,
    vad_filter=True
)

with open("$output", "w", encoding="utf-8") as f:
    for segment in segments:
        f.write(segment.text)

print(f"✅ 转写完成")
PYTHON_EOF
    
    return $?
}

# 主逻辑
platform=$(detect_platform "$source_url")
echo "🔍 检测到平台: $platform"

output_file="$output_dir/transcript_$(date +%Y%m%d_%H%M%S).txt"

case "$platform" in
    youtube)
        transcribe_youtube "$source_url" "$output_file"
        ;;
    xiaoyuzhou)
        transcribe_xiaoyuzhou "$source_url" "$output_file"
        ;;
    bilibili|ximalaya)
        echo "🚧 $platform 暂不支持直接转写，下载音频后处理..."
        ;;
    *)
        echo "❌ 无法识别的平台"
        exit 1
        ;;
esac

if [ $? -eq 0 ]; then
    echo "📄 转写文件: $output_file"
    wc -c "$output_file"
else
    echo "❌ 转写失败"
    exit 1
fi
