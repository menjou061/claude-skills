# ADR-099 真源與 CC repo 角色分工（Source of Truth vs Governance Staging）

## Status
Accepted (2026-05-31)

## Context

健康度檢查 2026-05-31 發現「CC repo rules.json 與 Obsidian 真源不同步」，並將其誤判為 P1 必修問題。

這個誤判源於 CC 對自身角色的錯誤理解——把 CC repo 視為 Obsidian 真源的「副本/鏡像」。

實際的設計意圖：

- **Obsidian** = 唯一真源（敘事、規則庫、復盤、案例）
- **CC repo** = 治理流程工作區（staging area for promotion gates）
- 兩者不是主從關係，是**不同生命週期**

如果 CC 主動鏡像 Obsidian 全量，會導致：
- 雙寫風險（兩處都可寫，產生衝突）
- 真源邊界模糊（哪邊是源頭？）
- CC 越權拓寬（從 staging 變成 owner）

## Decision

### A. 角色明確定義

| 角色 | 內容 | 寫權 |
|------|------|------|
| **Obsidian 真源** | 規則庫全量 / 復盤敘事 / 案例 / 概念 | 用戶 / 人工同步腳本 |
| **CC repo rules.json** | 僅治理流程涉及過的規則（候選晉升 / 退役評估等） | CC（僅在用戶 approve 後）|
| **CC repo candidates.json** | 治理流程中的候選池 | CC（受 ADR-004 約束）|

### B. 同步方向（單向）

```
[Obsidian 真源]
   ↓ (人工/腳本回寫)
[CC repo rules.json]
   ↑ (CC approved 後寫入，等待人工同步回 Obsidian)
```

**禁止反向同步**：CC 不得主動把 Obsidian 全量規則寫入 CC repo。

### C. 「不同步」是正常狀態

健康度檢查中「CC repo X 條 vs Obsidian Y 條」的差距是**正常**，不是 bug：

- Obsidian 真源 = 完整規則庫（如 trading-discipline 20 條）
- CC repo rules.json = 治理流程涉及過的子集（如剛晉升的 3 條）

巡檢報告不應把這個差距列為 P1 必修。

### D. CC 何時寫入 rules.json

僅在以下場景：

1. **新規則晉升**：用戶通過 7 閘明確 approve 後，CC 寫入新規則到 rules.json
2. **規則退役**（ADR-010 未來）：用戶確認退役後，CC 從 rules.json 移除
3. **規則修改**：用戶在 Obsidian 真源修改後，**用戶手動觸發** CC 重新導出

CC **絕不主動**鏡像 Obsidian 全量。

## Consequences

**正面：**
- 真源邊界清晰，避免雙寫衝突
- CC 角色收斂為「治理流程執行者」，不越權成為「規則庫 owner」
- 巡檢報告不再因「不同步」誤判

**負面：**
- 當需要「對全量規則做分析」時，需要先從 Obsidian 導出快照
- 新用戶可能誤以為 CC repo 是規則庫主體

**緩解：**
- 在 SKILL.md 明確標注「Obsidian = 真源 / CC repo = staging」
- 提供「按需導出 Obsidian 全量到臨時快照」的腳本（未來）

## Constraints（紅線）

1. ❌ CC 不得主動把 Obsidian 真源全量寫入 CC repo
2. ❌ CC 不得在 Obsidian 與 CC repo 不同步時主動「修復」
3. ❌ CC 不得把「不同步」誤判為 bug
4. ✅ 反向同步（Obsidian → CC repo）僅在用戶明確指令時執行

## Implementation

1. 健康度檢查報告模板更新：「規則庫狀態」項不應比對 Obsidian 全量
2. SKILL.md 明確聲明角色分工
3. 未來規則退役 ADR-010 必須遵守此分工
4. ADR 編號使用 099 表示「跨層級基礎約定」（非主流 ADR 序列）

## Related

- [[004-rule-promotion-gates.md]] 規則晉升 6 閘
- [[obsidian-mapping.md]] 域映射文件
- [[../post-mortems/2026-05-31-unauthorized-promotion.md]] 對應事故覆盤
