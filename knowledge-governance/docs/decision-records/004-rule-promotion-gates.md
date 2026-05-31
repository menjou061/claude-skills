# ADR-004 規則晉升六閘審查（Six-Gate Rule Promotion）

## Status
Accepted (2026-05-31)

## Context

規則庫膨脹是決策系統最大失敗模式：
- 每本書/每次提案塞 20–50 條 → 一年 1000+ → 沒人記得 → 形同虛設
- AI 自動晉升 → 規則未經個人化驗證 → 套用後反而扭曲決策
- 缺乏明確閘門 → 主觀拍腦袋 → 規則品質參差不齊

## Decision

所有候選規則（無論來自 book-digest / 復盤自提案 / curate / 用戶手寫）
必須順序通過 6 道閘門才能晉升到 rules.json：

1. **唯一性**（AI 判斷）：與現有規則 + 同批候選的相似度
2. **可執行**（AI 判斷）：是否有可量化的檢查邏輯
3. **痛感**（AI 檢索證據 + 用戶確認）：是否有 Obsidian 歷史踩坑案例
4. **頻次**（AI 統計）：過去 6 個月該情境出現次數
5. **層級審核**（AI 建議 + 用戶拍板）：P1/P2/P3 判斷
6. **個人化回測**（AI 模擬 + 用戶最終決策）：套到歷史案例上是否改變結果且更好

## Consequences

**正面：**
- 規則庫精華，每條都有歷史證據支撐
- AI 提案、用戶決策，責任清晰
- 防止規則庫膨脹，維持人腦短期記憶可承受範圍

**負面：**
- 晉升流程慢（每條需用戶 review）
- 對 Obsidian 案例庫密度有要求

## Constraints（紅線）

- AI 絕對禁止直接寫 rules.json
- 規則層級配額：
  - trading-discipline P1+P2 ≤ 30
  - product-experience P1+P2 ≤ 25
  - personal-capability P1+P2 ≤ 20
  - 跨域原則 ≤ 7
- 一本書 / 一輪提案預期晉升 3–7 條，超過必須說明理由

## Related

- [[docs/PRD.md]] §7 成功指標
- [[docs/rule-promotion-process.md]] 操作 SOP
- [[domains/trading-discipline/rules.json]]
- [[domains/product-experience/rules.json]]
- [[domains/personal-capability/rules.json]]
