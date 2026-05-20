# BTC CLI (`~/.local/bin/btc`)

Local Python 3 stdlib script for live BTC market data. No deps, no API keys.

## Why a separate tool

User's Longbridge account does not have crypto quote permissions. `longbridge quote BTCUSD.HAS` returns empty (`overnight_quote: null`). Free public APIs from Binance + Deribit cover everything we need.

## Prerequisites

- Clash proxy running at `127.0.0.1:7897` (script reads `HTTPS_PROXY` env var, falls back to this default)
- Python 3 (macOS system Python is fine)

## Subcommands

| Command | Output |
|---|---|
| `btc` / `btc snapshot` | Spot price + 24h change + 5-level order book + funding rate + OI + global long/short ratio + 2 nearest expiries (top 3 Call/Put walls + max pain) + DVOL |
| `btc options` | 5 nearest expiries, top 5 Call/Put walls + max pain per expiry |
| `btc compare` | Cross-exchange spot price + 24h volume (Binance/Coinbase/OKX/Bybit/Kraken) + max-min spread |
| `btc liq` | Funding rate history (last 3) + global L/S ratio 4h window + top-trader position L/S + OI 5min × 6 |

## Source APIs

- **Binance Spot**: `api.binance.com/api/v3/{ticker/24hr,depth}`
- **Binance Futures (USD-M perpetual)**: `fapi.binance.com/fapi/v1/{premiumIndex,openInterest,fundingRate}` + `fapi.binance.com/futures/data/{globalLongShortAccountRatio,topLongShortPositionRatio,openInterestHist}`
- **Deribit**: `www.deribit.com/api/v2/public/{get_book_summary_by_currency,get_volatility_index_data}`
- **Compare sources**: Coinbase Exchange, OKX, Bybit, Kraken

## When to invoke

User asks about BTC:
- price / 现价 / 突破
- resistance / 压力位 / 卖盘点位
- options / 期权 / max pain / call wall / put wall
- funding / 资金费率
- long-short ratio / 多空比 / 爆仓 / 强平
- IV / DVOL / vol

→ Run the matching subcommand directly via `Bash`. The data refreshes per-call and is far more precise than WebSearch summaries.

## Combining with equity proxies

For a full crypto picture, also pull MSTR/COIN/IBIT via `longbridge quote` — they often diverge from spot during US session (premium/discount tells you institutional flow direction).
