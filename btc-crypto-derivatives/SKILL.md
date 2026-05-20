---
name: btc-crypto-derivatives
description: 'MANDATORY skill whenever crypto-related equities or BTC/ETH derivatives come up. TRIGGER on: (1) any operational decision question about crypto-beta stocks — COIN/COIN.US (Coinbase), MSTR/MSTR.US (MicroStrategy), IBIT/IBIT.US, GBTC, MARA, RIOT, CLSK, HUT, etc. — including "should I sell COIN at $X", "时机", "加仓/减仓 COIN", "COIN 现在能持有吗", "MSTR 怎么看"; (2) any BTC/ETH/crypto question — price levels, resistance, funding rate, open interest (OI), liquidation, Max Pain, Call/Put walls, long/short ratio, DVOL/IV, 资金费率, 多空比, 期权墙, 强平, 共振信号; (3) any mention of 比特币/以太坊/加密/合约/永续/衍生品 + decision context. ALWAYS auto-invoke `btc snapshot` and apply the resonance rules below — never give crypto-equity advice without checking BTC derivatives first. The BTC signal is treated as a fundamentals-extension dimension for crypto-beta equities, on par with blogger/macro inputs (but always subordinate to 金铲铲 Priority 1 生存铁律 if conflict).'
---

# BTC / Crypto Derivatives Analysis

**Data source:** `~/.local/bin/btc` (Binance + Deribit free public APIs via Clash proxy 127.0.0.1:7897)
**Framework source:** `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/menjou-zero/01-财经/策略/加密货币-衍生品指标框架.md`(以下简称"框架文档",冲突时以框架文档为准)

---

## When this skill MUST fire

**场景 A:加密 equity proxy 操作决策(最重要)**

用户问 COIN.US / MSTR.US / IBIT.US / GBTC / MARA / RIOT / CLSK / HUT 等加密 beta 股的**任何买卖/持仓决策**(包括"该不该卖"、"现在加仓时机如何"、"$X 价位能持有吗"、"减仓窗口"等)→ **必须**先跑 `btc snapshot`,把 BTC 衍生品信号作为决策的一个独立维度,**绝不能只看股票本身的价格/技术面就给建议**。

> 原因:这类股票本质是 BTC 的杠杆 beta,BTC 的资金费率、OI、Max Pain、期权墙是它们日内—周线级方向的领先信号。漏掉这个维度等于少了 1/3 的决策信息。

**场景 B:BTC/ETH 直接分析**

用户直接问 BTC 价格、阻力位、走势、共振信号、资金费率等 → 跑 `btc snapshot`(必要时加 `btc liq` 看 OI 演变)+ 按共振规则解读。

---

## Step 0(场景 A 必须先做):查 longbridge news

被问 crypto-equity (COIN/MSTR/IBIT/CRCL/MARA/RIOT/CLSK/HUT 等)的任何买卖决策时,**先于 BTC CLI** 跑:

```bash
longbridge news SYMBOL.US           # 24h 新闻头条
longbridge news detail <id>         # 重要新闻全文
longbridge filing SYMBOL.US         # 监管文件 (8-K/10-Q 等)
```

扫近 24-48h 内容:监管/法案(CLARITY Act / GENIUS Act / SEC actions)、合作公告(Visa/Meta/Stripe)、稳定币业务变动、财报日期、Form 4 内部人交易。

> **原因(2026-05 复盘):** 仅跑 BTC snapshot + 财报日期就给 COIN 减仓建议,漏了 5/4 当日 CLARITY Act 妥协案(COIN +6.1%、CRCL +19.9%),建议方向错误。crypto-equity 的"基本面"不只财报/估值,**监管/法案/合作公告等可凌驾 BTC 衍生品信号**(按裁决优先级:基本面 > BTC 衍生品信号)。详见 longbridge skill 的 News-first workflow。

跑完 longbridge news 后再进入下面的 BTC 衍生品标准流程。

---

## 标准执行流程(每次必跑)

```bash
btc snapshot   # 现货 + 资金费率 + OI + 多空比 + 最近 2 个到期 Call/Put Wall + Max Pain + DVOL
btc liq        # 仅在需要 OI 5min×6 演变 + 大户多空比 + 资金费率 8h 历史时调用
btc options    # 仅在需要 5 个最近到期日全景时调用(月度/季度博弈位)
```

调用失败排查:代理(`127.0.0.1:7897` Clash)→ 重试一次 → 仍失败则记"BTC 数据不可用"并继续(不阻塞决策,但要明示缺失)。

---

## 必报字段(任何 crypto-equity 决策时,以下都要拉出来)

| 维度 | 字段 | 解读阈值(精简版,详见框架文档) |
|---|---|---|
| 现货 | BTC 现价 / 24h 变动 | 涨跌幅 + 量能 |
| 资金费率 | funding rate / 8h | >+0.05% 多头过热 / -0.01~+0.01% 中性 / <-0.05% 极端空头 |
| OI | 未平仓总量 + 5min×6 演变 | 价升 OI 涨 = FOMO 顶 / 价跌 OI 涨 = 空头加仓(反向利多) |
| 多空比(散户) | global L/S 1h | >2 极多(反向利空) / <0.7 极空(反向利多) |
| 大户多空比 | top trader L/S | **正向**指标,与散户分歧时跟大户 |
| 期权墙 | Call Wall / Put Wall | 突破 Call Wall → gamma squeeze 利多;失守 Put Wall → 加速下跌 |
| Max Pain | 最近到期日 | 到期前 3-7 天磁力效应最强 |
| DVOL | BTC IV 指数 | >60 高波动警告(类似 VIX) |

---

## 共振决策原则(必须 2+ 信号同向才下判定)

### 看涨共振(任 2 项即可)
- 价格走低 + OI 暴涨(空头加仓)
- 散户 L/S < 0.7(极空反向)
- 资金费率 < -0.01%(空头过热反向)
- 价格突破 Call Wall + 放量 + OI 跟涨
- 价格在 Put Wall 附近横盘

### 看跌共振(任 2 项即可)
- 价格新高 + OI 暴涨 + 资金费率 > +0.05%
- 散户 L/S > 1.5
- 现价距月度 Max Pain < 5%(到期前磁力)
- Call Wall 失败回落 + OI 暴跌

**核心口诀:买在分歧(OI 涨跌不一致),卖在一致(OI 一边倒)**

> ⚠️ **单一指标即使再强也不下判定**。例:仅资金费率 -0.05% 一项,不构成做多依据。

---

## 与金铲铲框架的对应(crypto-equity 决策时尤其重要)

| 金铲铲规则 | crypto-equity / BTC 应用 |
|---|---|
| **Priority 1 生存铁律(25%/5% 红线)** | BTC 永续 ≥5x 杠杆单笔亏损 ≤ 总资金 5%;crypto-equity 单只仓位上限服从原 T 级别 |
| **基本面一票否决** | SEC 重大监管 / 交易所被黑 / 稳定币脱锚 → 无视 BTC 技术面立即处理 crypto-equity 仓位 |
| **事件铁律** | 加密 equity 财报前(COIN/MSTR 等)— 即使 BTC 信号一致看涨,**仍按事件减仓铁律执行**,BTC 不能凌驾事件 |
| **盈亏比 ≥ 2:1** | 任何加仓试探必须满足 |
| **左侧雷达试探** | OI 暴涨 + 价格新低 + Put Wall = 左侧低多 1/3 仓 |

**裁决优先级(冲突时):金铲铲 Priority 1 > 基本面(博主/路透) > BTC 衍生品信号 > 纯技术面 > 情绪面**

---

## 输出格式(crypto-equity 决策场景)

回答用户"COIN/MSTR/IBIT 等该不该 X"时,**至少**包含以下 3 段(顺序可调,但都要有):

1. **🪙 BTC 衍生品快照**:必报字段一行表 + DVOL
2. **🎯 共振判定**:列出当前命中的 2+ 个信号,给出"看涨/看跌/中性"定调一句
3. **📊 对 crypto-equity 的含义**:BTC 信号 → 该股短期方向倾向 + 对当前仓位决策的支持/反对意见;同时明示是否与基本面/金铲铲触发线一致

**示例(COIN $206 情景)**:
> 🪙 BTC $80,170 / 资金费率 0.00% / OI 106.7K BTC / L/S 0.57 / Max Pain $79,500 / DVOL 39.86
> 🎯 共振:中性偏弱(L/S 0.57 反向利多 + 资金费率中性,但 Max Pain $79,500 在下方有磁力)
> 📊 对 COIN:BTC 缺乏向上弹性,COIN $206 涨幅难持续;**支持** $200-205 减仓窗触发,**反对** 重仓走入 5/7 财报

---

## 什么不要做

- ❌ **绝不**在被问 COIN/MSTR/IBIT 操作时跳过 BTC 衍生品检查
- ❌ 不基于单一指标(如只看资金费率)就做判定
- ❌ 不用周期模型 / 艾略特波浪 / 4 浪计数(框架文档已弃用)
- ❌ 不付费跟单博主仓位
- ❌ 不在重大宏观事件前(FOMC/CPI/地缘)用衍生品指标重仓 — 事件冲击下指标全失效
- ❌ 不让 BTC 信号凌驾金铲铲 Priority 1 生存铁律 / 基本面一票否决

---

## 复盘机制

每次基于 BTC 衍生品信号做出的 crypto-equity 决策,事后回头看:
1. 入场前的共振信号清单是什么?
2. 离场原因是触发止盈/止损/破位防守 / 还是情绪化操作?
3. 若与判定方向相反,是哪个指标先失效的?

累积 10 次后回头校验框架准确率,失效规则下沉(详见框架文档第七节)。
