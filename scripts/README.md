# scripts

Shell scripts used by skills and launchd scheduled tasks.

## Files

| Script | Used by | Description |
|--------|---------|-------------|
| `transcribe_youtube.sh` | podcast-transcriber | YouTube/B站字幕提取，输出 Markdown 到 Obsidian Inbox |
| `transcribe_xiaoyuzhou_groq.sh` | podcast-transcriber | 小宇宙播客 Groq API 转写，失败自动切换本地 Whisper |
| `transcribe_podcast.sh` | podcast-transcriber | 通用播客转写入口 |
| `lb-snapshot.sh` | finance-news (launchd) | 预计算 Longbridge 快照，输出到 `~/.claude/cache/lb-snapshot.md` |
| `run-finance-news.sh` | launchd plist | 财经简报 launchd 包装脚本，调用 `claude -p --permission-mode bypassPermissions` |

## Dependencies

```bash
brew install yt-dlp ffmpeg
# Groq API key
export GROQ_API_KEY=your_key_here
# Clash proxy at 127.0.0.1:7897
```
