---
name: podcast-transcriber
description: 智能播客/视频转写工具。YouTube 直接提取字幕（秒级），小宇宙用 Groq API 云端转写（分钟级，免费）。自动识别平台并选择最快方式。转写完成后自动清理临时文件。
user-invocable: true
---

# 智能播客转写

自动识别链接类型，选择最快的转写方式：

| 平台 | 方式 | 速度 | 费用 |
|------|------|------|------|
| YouTube | yt-dlp 提取字幕 | 秒级 | 免费 |
| 小宇宙播客 | Groq API → 本地 Whisper 备用 | 分钟级 | 免费 |
| B站视频 | yt-dlp 提取字幕 | 秒级 | 免费 |

## 使用方法

直接给我播客/视频链接，我会自动识别并转写：

```
转写这个 https://www.youtube.com/watch?v=xxx
这期播客转写一下 https://www.xiaoyuzhoufm.com/episode/xxx
```

## 自动清理

转写完成后，所有下载的音频文件和临时缓存会自动删除：
- ✅ 下载的视频/音频
- ✅ 转码后的 MP3
- ✅ 临时切片文件
- ✅ 只保留最终转写文本

## 命令

```bash
# YouTube（提取字幕）
bash ~/.claude/scripts/transcribe_youtube.sh "URL"

# 小宇宙（Groq 转写，失败时自动切换本地 Whisper）
bash ~/.claude/scripts/transcribe_xiaoyuzhou_groq.sh "URL"
```

## 输出

转写结果保存到 `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/menjou-zero/00-Inbox/`
用户后续说「整理 Inbox」或「归档财经」触发自动归类
