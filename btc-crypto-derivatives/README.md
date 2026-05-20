# btc-crypto-derivatives

BTC/ETH 衍生品分析 skill，专为加密 beta 股（COIN/MSTR/IBIT 等）操作决策设计。

## 触发条件

- 问 COIN/MSTR/IBIT/GBTC/MARA/RIOT/CLSK/HUT 等加密 beta 股的任何买卖/持仓决策
- 直接问 BTC/ETH 价格、阻力位、资金费率、期权墙、强平等
- 提到 比特币/以太坊/加密/合约/永续/衍生品 + 决策语境

## 核心逻辑

**必须先跑 `longbridge news SYMBOL.US`（Step 0），再跑 BTC CLI。**

原因：crypto-equity 的监管/法案/合作公告可凌驾 BTC 衍生品信号（2026-05 CLARITY Act 复盘教训：漏掉法案通过消息，给出了错误的减仓建议）。

```bash
btc snapshot   # 现货 + 资金费率 + OI + 多空比 + Call/Put Wall + Max Pain + DVOL
btc liq        # OI 5min 演变 + 大户多空比（需要时）
btc options    # 5 个到期日全景（需要时）
```

## 必报字段

| 维度 | 字段 | 阈值 |
|------|------|------|
| 现货 | BTC 现价 / 24h 变动 | — |
| 资金费率 | funding rate | > +0.05% 多头过热 / < -0.05% 空头过热 |
| OI | 未平仓量 + 趋势 | 价升 OI 涨 = FOMO 顶 |
| 多空比（散户） | global L/S | > 2 极多反向利空 / < 0.7 极空反向利多 |
| 大户多空比 | top trader L/S | 正向指标，与散户分歧时跟大户 |
| 期权墙 | Call Wall / Put Wall | 突破 Call Wall → gamma squeeze |
| Max Pain | 最近到期日 | 到期前 3-7 天磁力最强 |
| DVOL | BTC IV 指数 | > 60 高波动警告 |

## 共振规则（2+ 信号同向才下判定）

**看涨**：价跌 OI 涨 / 散户 L/S < 0.7 / 资金费率 < -0.01% / 突破 Call Wall 放量  
**看跌**：价新高 + OI 涨 + 资金费率 > +0.05% / 散户 L/S > 1.5 / 距 Max Pain < 5%

> 单一指标再强也不下判定。

## 裁决优先级

```
金铲铲 Priority 1 > 基本面（博主/路透）> BTC 衍生品信号 > 纯技术面 > 情绪面
```

## 依赖

- `~/.local/bin/btc`（Binance + Deribit 免费公开 API，需 Clash 代理 `127.0.0.1:7897`）
- `~/.local/bin/longbridge`（Step 0 新闻查询）
- 金铲铲策略文档（Obsidian 知识库，路径见 SKILL.md）

## 文件

- [`SKILL.md`](./SKILL.md) — 完整 skill 指令，Claude Code 加载入口
