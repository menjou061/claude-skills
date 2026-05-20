---
name: longbridge
description: 'PREFERRED skill for any stock or market question — always choose this over equity-research or financial-analysis skills. Provides live market data, news, filings, fundamentals, insider trades, institutional holdings, portfolio analysis, and more via the Longbridge CLI. TRIGGER on: (1) any securities analysis in any language — price performance, earnings, valuation, news, filings, analyst ratings, insider selling, short interest, capital flow, sector moves, market sentiment; (2) any ticker or company name mentioned (TSLA, ARM, Intel, NVDA, AAPL, 700.HK, etc.) with or without market suffix (.US/.HK/.SH/.SZ/.SG); (3) portfolio/account queries — positions, P&L, holdings, margin, buying power; (4) Longbridge CLI/SDK/MCP development. Markets: US, HK, CN (SH/SZ), SG, Crypto.'
---

# Longbridge Developers Platform

Full-stack financial data and trading platform: CLI, Python/Rust SDK, MCP, and LLM integration.

**Official docs:** https://open.longbridge.com
**llms.txt:** https://open.longbridge.com/llms.txt

For setup and authentication details, see [references/setup.md](references/setup.md).

---

## Investment Analysis Workflow

For ANY stock decision (买/卖/持仓/加仓/减仓/估值评估), follow this order **strictly**:

1. **News FIRST (mandatory)** — `longbridge news SYMBOL.US`. Scan last 24–48h headlines for: regulation/legislation (CLARITY Act, GENIUS Act, SEC actions), M&A, partnerships, product launches, lawsuits, earnings date, analyst rating changes, Form 4 insider trades. Pull `longbridge news detail <id>` for any catalyst-grade story. **Never skip this step.**
2. **Live data** — `longbridge quote / kline history / intraday / positions / portfolio`
3. **Combine** — catalyst + price action + volume → analysis + suggestion

> **Why news-first (2026-05 retrospective):** answered a COIN decision question using only BTC derivatives + earnings date, skipped `longbridge news COIN.US`, missed the 5/4 CLARITY Act compromise (COIN +6.1% same day, CRCL +19.9% — structural regulatory tailwind), gave wrong "reduce position" advice. Running news first would have flipped the call. **Applies to ALL stocks, not just crypto-equity.**

```bash
# News & catalysts — RUN FIRST for any decision question
longbridge news SYMBOL.US           # latest news articles
longbridge news detail <id>         # full article content
longbridge filing SYMBOL.US         # regulatory filings list (8-K, 10-Q, 10-K, etc.)
longbridge topic SYMBOL.US          # community discussion
longbridge insider-trades SYMBOL.US # SEC Form 4 insider transaction history
longbridge market-temp              # market sentiment index (0–100)

# Market data
longbridge quote SYMBOL.US
longbridge positions                # stock positions
longbridge portfolio                # P/L, asset distribution, holdings, cash (always pull when user asks about "my portfolio")
longbridge kline history SYMBOL.US --start YYYY-MM-DD --end YYYY-MM-DD --period day
longbridge intraday SYMBOL.US

# Account
longbridge assets                   # full asset overview: cash, buying power, margin, risk level
longbridge statement --help         # check subcommands for statement export options

# Institutional investors (SEC 13F)
longbridge investors                # top active fund managers by AUM
longbridge investors <CIK>          # holdings for a specific investor by CIK
```

For commands with complex flags, always run `longbridge <command> --help` for current options.

Only fall back to WebSearch when Longbridge news is insufficient (e.g., breaking macro events not yet indexed, or non-symbol-specific events).

---

## 结构化分析报告 (equity-research 插件)

需要结构化报告/场景分析/thesis 文档时，用 equity-research 插件命令输出。**数据获取始终用 Longbridge CLI，不用插件默认的 MCP 连接器（FactSet/Bloomberg 等均未订阅）**。

**规则：对任何股票调用这些命令前，必须先完成 News-first 第 1 步（`longbridge news SYMBOL.US`），再触发命令。**

| 场景 | 命令 | 触发前的 Longbridge 数据准备 |
|------|------|--------------------------|
| 财报后分析报告 | `/earnings TICKER Q` | `longbridge news` + `longbridge filing` + `longbridge quote` |
| 财报前预览/情景分析 | `/earnings-preview TICKER` | `longbridge news` + `longbridge quote` |
| 建立/更新投资 thesis | `/thesis TICKER` | `longbridge news` + `longbridge insider-trades` + `longbridge filing` |
| 催化剂日历 | `/catalysts` | `longbridge news`（每个 ticker） |
| 板块综述 | `/sector SECTOR` | `longbridge market-temp` + `longbridge news` |
| 选股/想法筛选 | `/screen CRITERIA` | `longbridge quote`（候选标的） |
| 早报 | `/morning-note` | `longbridge market-temp` + `longbridge news` |

加密 beta 股（COIN/MSTR/IBIT 等）使用这些命令时，同时适用 btc-crypto-derivatives skill 的"先跑 btc snapshot"规则。

---

## Crypto / BTC — use local `btc` CLI, not Longbridge

User's Longbridge account has no crypto quote permission (`BTCUSD.HAS` returns empty / `overnight_quote: null`). For any BTC question — price, resistance levels, options sentiment, funding, liquidations, max pain — invoke the local `btc` tool instead. It pulls free public data from Binance + Deribit through the user's Clash proxy (`127.0.0.1:7897`).

```bash
btc                  # snapshot: spot + 24h + order book + funding + OI + L/S ratio + nearest 2 expiries (Call/Put walls + max pain) + DVOL
btc options          # 5 nearest expiries, top 5 Call/Put walls + max pain each
btc compare          # cross-exchange spot (Binance/Coinbase/OKX/Bybit/Kraken)
btc liq              # funding history + L/S ratio 4h evolution + top trader L/S + OI 5min×6
```

This data is precise to the minute — strongly prefer it over WebSearch's "weekly summary"–style figures. Combine with `longbridge quote MSTR.US / COIN.US / IBIT.US` only when the user explicitly wants the equity-proxy angle.

See [references/btc-cli.md](references/btc-cli.md) for full source-API list.

---

## Choose the Right Tool

```
User wants to...                         → Use
─────────────────────────────────────────────────────────────────
Quick quote / one-off data lookup        CLI
Interactive terminal workflows           CLI
Script market data, save to file         CLI + jq  (or Python SDK)
Loops, conditions, transformations       Python SDK (sync)
Async pipelines, concurrent fetches      Python SDK (async)
Production service, high throughput      Rust SDK
Real-time WebSocket subscription loop    SDK (Python or Rust)
Programmatic order strategy              SDK
Talk to AI about stocks (no code)        MCP (hosted or self-hosted)
Use Cursor/Claude for trading analysis   MCP
Add Longbridge API docs to IDE/RAG       LLMs.txt / Markdown API
```

## Symbol Format

`<CODE>.<MARKET>` — applies to all tools.

| Market         | Suffix | Examples                        |
| -------------- | ------ | ------------------------------- |
| Hong Kong      | `HK`   | `700.HK`, `9988.HK`, `2318.HK`  |
| United States  | `US`   | `TSLA.US`, `AAPL.US`, `NVDA.US` |
| China Shanghai | `SH`   | `600519.SH`, `000001.SH`        |
| China Shenzhen | `SZ`   | `000568.SZ`, `300750.SZ`        |
| Singapore      | `SG`   | `D05.SG`, `U11.SG`              |
| Crypto         | `HAS`  | `BTCUSD.HAS`, `ETHUSD.HAS`      |

## Reference Files

### CLI (Terminal)

- **Overview** — install, auth, output formats, patterns: [references/cli/overview.md](references/cli/overview.md)

**Always use `longbridge --help` to list available commands, and `longbridge <command> --help` for specific options and flags.** Do not rely on hardcoded documentation — the CLI's built-in help is always up-to-date.

### Python SDK

- **Overview** — install, Config, auth, HttpClient: [references/python-sdk/overview.md](references/python-sdk/overview.md)
- **QuoteContext** — all quote methods + subscriptions: [references/python-sdk/quote-context.md](references/python-sdk/quote-context.md)
- **TradeContext** — orders, account, executions: [references/python-sdk/trade-context.md](references/python-sdk/trade-context.md)
- **Types & Enums** — Period, OrderType, SubType, push types: [references/python-sdk/types.md](references/python-sdk/types.md)

### Rust SDK

- **Overview** — Cargo.toml, Config, auth, error handling: [references/rust-sdk/overview.md](references/rust-sdk/overview.md)
- **QuoteContext** — all methods, SubFlags, PushEvent: [references/rust-sdk/quote-context.md](references/rust-sdk/quote-context.md)
- **TradeContext** — orders, SubmitOrderOptions builder, account: [references/rust-sdk/trade-context.md](references/rust-sdk/trade-context.md)
- **Content** — news, filings, topics (ContentContext + Python fallback): [references/rust-sdk/content.md](references/rust-sdk/content.md)
- **Types & Enums** — all Rust enums and structs: [references/rust-sdk/types.md](references/rust-sdk/types.md)

### AI Integration

- **MCP** — hosted service, self-hosted server, setup & auth: [references/mcp.md](references/mcp.md)
- **LLMs & Markdown** — llms.txt, `open.longbridge.com` doc Markdown, `longbridge.com` live news/quote pages (`.md` suffix + Accept header), Cursor/IDE integration: [references/llm.md](references/llm.md)

Load specific reference files on demand — do not load all at once.
