# claude-skills

Personal Claude Code skills & agent configs for finance, crypto, media, and productivity workflows.

## Structure

```
claude-skills/
├── btc-crypto-derivatives/        # BTC/ETH derivatives analysis + crypto-equity decisions
├── knowledge-governance/          # Personal decision governance — 7-gate rule promotion, 6 sources, 5 redlines
├── longbridge/                    # Longbridge trading platform — market data, portfolio, orders
├── order-replay/                  # Daily order reconciliation — update brief + generate review
├── podcast-transcriber/           # YouTube / 小宇宙 / B站 transcript extraction
├── panniantong-agent-reach-skill/ # Multi-platform web search & read (16 platforms)
├── qiaomu-anything-to-notebooklm/ # Multi-source → NotebookLM pipeline
├── prompts/                       # Scheduled task prompts (finance daily brief)
└── scripts/                       # Shell scripts used by skills and launchd tasks
```

## Installation

```bash
# Clone to a dedicated directory (not directly into ~/.claude/skills)
git clone https://github.com/menjou061/claude-skills.git ~/claude-skills

# Symlink each skill into ~/.claude/skills/
mkdir -p ~/.claude/skills ~/.claude/prompts ~/.claude/scripts

ln -s ~/claude-skills/btc-crypto-derivatives ~/.claude/skills/btc-crypto-derivatives
ln -s ~/claude-skills/knowledge-governance ~/.claude/skills/knowledge-governance
ln -s ~/claude-skills/longbridge ~/.claude/skills/longbridge
ln -s ~/claude-skills/order-replay ~/.claude/skills/order-replay
ln -s ~/claude-skills/podcast-transcriber ~/.claude/skills/podcast-transcriber
ln -s ~/claude-skills/panniantong-agent-reach-skill ~/.claude/skills/panniantong-agent-reach-skill

# Prompts
ln -s ~/claude-skills/prompts/finance-news.md ~/.claude/prompts/finance-news.md
ln -s ~/claude-skills/prompts/finance-news-framework.md ~/.claude/prompts/finance-news-framework.md

# Scripts
ln -s ~/claude-skills/scripts/transcribe_youtube.sh ~/.claude/scripts/transcribe_youtube.sh
ln -s ~/claude-skills/scripts/transcribe_xiaoyuzhou_groq.sh ~/.claude/scripts/transcribe_xiaoyuzhou_groq.sh
ln -s ~/claude-skills/scripts/lb-snapshot.sh ~/.claude/scripts/lb-snapshot.sh
ln -s ~/claude-skills/scripts/run-finance-news.sh ~/.claude/scripts/run-finance-news.sh
```

To update all skills on any device:

```bash
cd ~/claude-skills && git pull
```

## Skills Overview

| Skill | Category | Trigger |
|-------|----------|---------|
| [btc-crypto-derivatives](./btc-crypto-derivatives/) | Finance / Crypto | COIN/MSTR/BTC/ETH 操作决策 |
| [longbridge](./longbridge/) | Finance | 任何股票行情、持仓、订单查询 |
| [order-replay](./order-replay/) | Finance | 每日简报生成后自动触发 |
| [podcast-transcriber](./podcast-transcriber/) | Media | YouTube / 小宇宙 / B站链接 |
| [panniantong-agent-reach-skill](./panniantong-agent-reach-skill/) | Web | 搜推特 / 小红书 / 上网搜 / read this link |
| [qiaomu-anything-to-notebooklm](./qiaomu-anything-to-notebooklm/) | Productivity | 多源内容 → NotebookLM |

## Dependencies

| Tool | Used by | Install |
|------|---------|---------|
| `~/.local/bin/longbridge` | longbridge, order-replay, btc-crypto-derivatives | [Longbridge CLI](https://open.longbridge.com) |
| `~/.local/bin/btc` | btc-crypto-derivatives | See [btc-cli.md](./longbridge/references/btc-cli.md) |
| `yt-dlp` | podcast-transcriber | `brew install yt-dlp` |
| Groq API key | podcast-transcriber (小宇宙) | Set `GROQ_API_KEY` in env |
| Clash proxy | btc-crypto-derivatives, longbridge | `127.0.0.1:7897` |

## Scheduled Tasks

The finance daily brief runs via macOS launchd (weekdays 12:00 CST). See [prompts/finance-news.md](./prompts/finance-news.md) for the full prompt and [scripts/run-finance-news.sh](./scripts/run-finance-news.sh) for the wrapper script.
