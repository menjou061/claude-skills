# prompts

Scheduled task prompts used by launchd automation.

## Files

### `finance-news.md`

每日财经简报的完整 prompt，由 macOS launchd 在周一至周五 12:00 CST 自动触发。

**流程概览：**
1. 交易日检查
2. 读取 Longbridge 快照（`~/.claude/cache/lb-snapshot.md`）
3. 读取金铲铲框架 cheatsheet
4. 读取最新复盘文档
5. 抓取博主视频转录（视野环球财经 / 相谈比特币）
6. WebSearch 补充路透/彭博宏观要点
7. 交叉验证融合
8. 输出持仓三维对照 + 操作建议 + 操作确认 checklist
9. 写入简报文件（倒序追加）
10. 拉取当日订单，更新操作确认区，生成复盘（order-replay 逻辑）

### `finance-news-framework.md`

金铲铲策略框架的浓缩 cheatsheet，供简报 prompt 加载（避免每次加载完整金铲铲原文）。包含：风险水位、T1-T4 分级、Priority 1-3 铁律、关键防守触发线表格、现金分层矩阵。

## Scheduled Task Setup (macOS launchd)

```bash
# plist 路径
~/Library/LaunchAgents/com.liuyizhen.claude.finance-news.plist

# 手动触发
launchctl kickstart gui/$(id -u)/com.liuyizhen.claude.finance-news

# 查看状态
launchctl print gui/$(id -u)/com.liuyizhen.claude.finance-news

# 查看日志
tail -f ~/.claude/logs/finance-news-$(date +%Y%m%d).log
```
