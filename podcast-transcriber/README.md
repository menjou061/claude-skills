# podcast-transcriber

智能播客/视频转写工具。YouTube 直接提取字幕（秒级），小宇宙用 Groq API 云端转写（分钟级，免费）。自动识别平台并选择最快方式，转写完成后自动清理临时文件。

## 支持平台

| 平台 | 方式 | 速度 |
|------|------|------|
| YouTube | yt-dlp 提取字幕 | 秒级 |
| 小宇宙播客 | Groq API → 本地 Whisper 备用 | 分钟级 |
| B站视频 | yt-dlp 提取字幕 | 秒级 |

## 使用方法

直接把链接发给 Claude：

```
转写这个 https://www.youtube.com/watch?v=xxx
这期播客转写一下 https://www.xiaoyuzhoufm.com/episode/xxx
```

## 输出

转写结果保存为 Markdown 文件，输出到 Obsidian Inbox：

```
~/Library/Mobile Documents/iCloud~md~obsidian/Documents/menjou-zero/00-Inbox/<标题>.md
```

## 自动清理

转写完成后自动删除：下载的视频/音频、转码 MP3、临时切片文件。只保留最终 Markdown。

## 依赖

- `yt-dlp`：`brew install yt-dlp`
- `ffmpeg`：`brew install ffmpeg`（小宇宙音频转码用）
- Groq API key：设置环境变量 `GROQ_API_KEY`（免费，[申请地址](https://console.groq.com)）
- Clash 代理 `127.0.0.1:7897`（访问海外 API 用）

## 脚本

转写逻辑在 [`../scripts/`](../scripts/) 目录：

- `transcribe_youtube.sh` — YouTube/B站字幕提取
- `transcribe_xiaoyuzhou_groq.sh` — 小宇宙 Groq 转写（失败自动切换本地 Whisper）

## 文件

- [`SKILL.md`](./SKILL.md) — 完整 skill 指令
