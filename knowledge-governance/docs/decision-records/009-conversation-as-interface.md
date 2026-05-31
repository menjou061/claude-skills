# ADR-009 對話即接口 + 結晶 SOP（Conversation-as-Interface + Crystallization）

## Status
Accepted (2026-05-31)

## Context

對話不應是「工具的一種使用方式」，應是 L0 統一接口——所有採集源（書/復盤/手寫/片段/工作產物）都從對話進入。

對話本身也是知識生成過程：
- 用戶與 AI 在對話中產生的設計討論、決策辨析、新想法 = 高價值結晶來源
- 但對話默認是易失的（chat 結束就消失）
- 如果不沉澱機制，所有對話價值歸零

核心矛盾：
- **流動性角度**：對話必須輕量、無摩擦，不能每句話都問「要保存嗎」
- **沉澱角度**：高價值結晶若不主動捕捉，會在大量對話中流失
- **解法**：4 種流模式識別 + 4 層沉澱機制

## Decision

### A. 4 種對話流模式

AI 必須在對話開始時主動識別流模式：

| 模式 | 識別信號 | 處理路徑 |
|------|---------|---------|
| **A 貼料流** | 「這篇文章/這本書/這段播客...」 | 對應採集源 SOP（ADR-005~008） |
| **B 設計流** | 「我們設計一個 X」「建立 Y 機制」 | 候選 ADR，進 docs/decision-records/ |
| **C 諮詢流** | 「我該怎麼做 X」「Y 違反規則嗎」 | retrieve audit（拉規則庫 → 對照分析） |
| **D 反思流** | 「我剛踩了個坑」「總結一下我這次...」 | 復盤 SOP（ADR-002 流程） |

模式混合場景：AI 應在每次模式切換時提示用戶。

### B. 4 層沉澱機制

| 層 | 內容 | 觸發 | 存放位置 | 持久性 |
|----|------|------|---------|--------|
| **L0 即時** | 對話本身 | 自動 | chat 上下文 | 歸零（chat 結束消失） |
| **L1 會話摘要** | 每場 chat 的核心 takeaways | 每場 chat 結束自動 | `docs/chat-logs/[日期]-[主題].md` | 永久 |
| **L2 結構化結晶** | ADR / 規則候選 / SOP 變更 | 識別到結晶價值時主動寫 | 對應 memory 文件 | 永久 |
| **L3 長期記憶** | 跨 session 連續性的 Active Threads | 用戶在多場 chat 中持續推進的主題 | `memory/active-threads.md` | 永久 |

### C. 配額機制

防止對話結晶噪音：

| 配額 | 上限 |
|------|------|
| 單場對話晉升候選 | 3 條 |
| 月度 ADR 提案 | 5 個 |
| 月度規則候選（對話來源） | 10 條 |

### D. 結晶觸發信號

AI 主動識別以下信號 → 提示用戶結晶：

| 信號 | 結晶類型 |
|------|---------|
| 「以後都這樣做」 | 規則候選 |
| 「我決定 X」 | 決策記錄（decision） |
| 「設計一個 X 機制」 | ADR 候選 |
| 「下次遇到 Y 我會 Z」 | SOP 補充 |
| 「啊我以前一直 X 是錯的」 | 規則候選（負向） |

### E. 自動 L1 摘要 SOP

每場 chat 結束時，AI 自動生成 L1 摘要，包含：

```markdown
## [YYYY-MM-DD] [主題]
- 流模式：A/B/C/D（混合則列多個）
- 核心 takeaways：3-5 條
- 結晶產出：[ADR/規則/decision] 列表
- 待結晶：[列表，給用戶下次回顧]
- 關聯 Thread：[active-threads.md 中的 Thread 名]
```

## Consequences

**正面：**
- 對話從易失資源變為可累積資產
- 4 種流模式提供清晰的處理路徑，避免「混亂對話」
- Active Threads 提供跨 session 連續性，避免每次重啟丟失上下文

**負面：**
- AI 對話增加結晶觸發信號識別負擔
- 用戶需要適應「對話會被結晶」的範式

**緩解：**
- L0 永遠是默認，結晶只在識別到信號時觸發
- 用戶可用 `[save-as=...]` 顯式指定結晶類型

## Constraints（紅線）

- L0 對話本身不寫入 memory（避免噪音）
- 結晶必須有明確類型標記（adr/rule/decision/sop）
- 單場對話超 3 條候選必須暫存，不得直接寫入
- ADR 提案必須走 ADR-001~004 的標準結構

## Implementation

1. AI 在對話開始時識別流模式並聲明
2. 識別結晶信號 → 提示用戶並引導結晶類型選擇
3. 每場 chat 結束時自動生成 L1 摘要到 `docs/chat-logs/`
4. L2 結晶根據類型寫入：
   - ADR → `docs/decision-records/`
   - 規則候選 → `domains/*/rules-candidates.json`
   - decision → `docs/decisions/[日期]-[主題].md`
   - SOP 變更 → 對應 SOP 文件
5. L3 Active Threads 由 ADR-009 + Step 3 機制維護（見 `memory/active-threads.md`）

## Related

- [[004-rule-promotion-gates.md]] 7 閘審查（對話來源候選仍需走閘）
- [[006-handwritten-fast-track.md]] 手寫快速通道（對話中手寫候選走此路徑）
- [[conversation-protocol.md]] 對話接口協議詳細 SOP
- [[active-threads.md]] 跨 session 連續性機制
