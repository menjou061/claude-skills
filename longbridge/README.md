# longbridge

Longbridge 交易平台全栈 skill：实时行情、持仓管理、历史订单、新闻、财报、内部人交易等。

## 触发条件

任何股票/市场问题优先使用此 skill，包括：
- 股票行情、K 线、涨跌幅、成交量
- 持仓查询、P&L、账户资产、历史订单
- 新闻、财报、分析师评级、内部人交易（SEC Form 4）
- 任何 ticker 提及（TSLA/NVDA/700.HK 等）

## News-first 铁律

**任何股票决策第一步必须跑 `longbridge news SYMBOL.US`。**

原因（2026-05 复盘）：仅看 BTC 衍生品 + 财报日期给 COIN 减仓建议，漏了 CLARITY Act 通过（COIN +6.1% 当日），建议方向错误。

## 常用命令

```bash
# 新闻与催化剂（必须第一步）
longbridge news SYMBOL.US
longbridge news detail <id>
longbridge filing SYMBOL.US
longbridge insider-trades SYMBOL.US
longbridge market-temp

# 行情
longbridge quote SYMBOL.US
longbridge kline history SYMBOL.US --start YYYY-MM-DD --end YYYY-MM-DD --period day
longbridge intraday SYMBOL.US

# 账户
longbridge positions
longbridge portfolio
longbridge assets
longbridge order --history --start YYYY-MM-DD
longbridge order executions --history --start YYYY-MM-DD
```

## Symbol 格式

| 市场 | 后缀 | 示例 |
|------|------|------|
| 美股 | `.US` | `TSLA.US`, `NVDA.US` |
| 港股 | `.HK` | `700.HK`, `9988.HK` |
| 沪市 | `.SH` | `600519.SH` |
| 深市 | `.SZ` | `000568.SZ` |
| 新加坡 | `.SG` | `D05.SG` |

## 依赖

- `~/.local/bin/longbridge`（[安装与认证](./references/setup.md)）
- Longbridge OpenAPI token（`longbridge auth login` 完成授权）

## 文件结构

```
longbridge/
├── SKILL.md                      # 完整 skill 指令
└── references/
    ├── setup.md                  # 安装与认证
    ├── btc-cli.md                # BTC CLI 工具说明
    ├── cli/
    │   ├── overview.md           # CLI 命令总览与输出格式
    │   └── quant.md              # 量化分析（quant 子命令）
    ├── python-sdk/
    │   ├── overview.md           # SDK 安装、Config、HttpClient
    │   ├── quote-context.md      # 行情订阅与查询方法
    │   ├── trade-context.md      # 交易、订单、账户方法
    │   ├── content-context.md    # 新闻、财报内容
    │   └── types.md              # 枚举与类型定义
    ├── rust-sdk/
    │   ├── overview.md
    │   ├── quote-context.md
    │   ├── trade-context.md
    │   ├── content.md
    │   └── types.md
    ├── mcp.md                    # MCP 服务器配置
    └── llm.md                    # LLMs.txt / Markdown API 集成
```
