# Presets — 統一預設機制

> 6 類採集源的默認動作、配額、閘配置、覆蓋標記完整 spec。
> 設計哲學：**最低破壞性原則 + 規則庫主權保護 > 提案便利性**。

---

## 全局默認

```yaml
strict: mid
level: P2
philosophy: 默認都偏「不入庫 / 補充案例 / audit」，真要新增需明確信號
```

---

## 採集源默認動作矩陣

| 來源 | 默認動作 | 默認層級 | 默認配額 | 閘配置 | 覆蓋標記 |
|------|---------|---------|---------|--------|---------|
| 📚 書 | 全閘審查 | P2 | 3-7/書 | 0+1+2+3+4+5+6 | `[tier=A|B|C]` |
| 📝 復盤 | 歸因 + 候選 | P2 | 1-2/篇 | 0+1+2+5（3/4/6 自帶） | `[mode=attribution-only]` |
| ✋ 手寫 | 快速通道 | P2 | 1/次 | 0+1+2+5（3/4/6 豁免） | `[level=P1|P2|P3]` |
| 🎙️ 片段 | 補充案例優先 | P3 | 5/月全域 | 0+1+2+5（3/4/6 AI 質詢） | `[mode=new-rule]` |
| 📄 工作產物 | audit 為主 | P2 | 0-2/份 | 視 mode | `[mode=audit|extract-only]` `[strict=high|mid|low]` |
| 💬 對話 | L1 摘要 + L2 結晶 | P2/P3 | 3/場 + 5 ADR/月 | 視結晶類型 | `[save-as=adr|rule|decision]` |

---

## 1. 書籍採集（📚）

**默認**：Tier 未指定 → AI 主動詢問
**配額**：3-7 條晉升/書（超過必須說明理由）

| 子場景 | 處理 |
|--------|------|
| `[tier=A]` 未讀 | 暫停採集 |
| `[tier=A]` 讀完 | 正常 7 閘 |
| `[tier=A]` 部分讀 | 提取後用戶必補讀段落再 Gate 5/6 |
| `[tier=B]` | AI 提取 + 用戶回讀段落 + Gate 5/6 |
| `[tier=C]` | 摘要入 wiki/資料摘要/，不入候選 |

詳見 [[ADR-005]]。

---

## 2. 復盤採集（📝）

**默認**：歸因 + 候選
**配額**：1-2 條晉升/篇

| mode | 動作 |
|------|------|
| 默認 | 規則歸因 + 候選提取 |
| `[mode=attribution-only]` | 只做規則歸因，不提候選 |

復盤天然有歷史證據（閘 3）、頻次（閘 4）、回測（閘 6），故只走 0+1+2+5。

---

## 3. 手寫採集（✋）

**默認**：快速通道（4 閘）
**配額**：1/次

| 場景 | 處理 |
|------|------|
| 默認 | 走 0+1+2+5，3/4/6 豁免 |
| `[level=P1]` | 用戶直接指定 P1（仍需閘 0 驗證） |

閘 0 五子項必過：
- A 支撐證據 ≥ 3 案例（< 3 → 弱證據暫存）
- B 情緒中性（否則 24h 冷卻）
- C 反例/邊界（AI 強制質詢）
- D 時間檢驗（一週後仍會這麼寫？）
- E 邏輯閉環（AI 強制質詢）

詳見 [[ADR-006]]。

---

## 4. 片段採集（🎙️）

**默認**：補充案例優先
**配額**：月度全域 5 條晉升（補充案例無上限）

**用戶 Step 2 三問**（必填）：
- Q1. 對應的個人案例是什麼？
- Q2. 跟既有哪條規則衝突/印證？
- Q3. 一週前會有同樣觸動嗎？

**AI Step 4 三問強制質詢**：
- Q1. 用戶案例是否真支撐？（防金句拉郎配）
- Q2. 既有規則庫是否已隱含？
- Q3. 反例/邊界？

**預期分佈**：75% 補充案例 / 20% 候選 / 5% 晉升

詳見 [[ADR-007]]。

---

## 5. 工作產物採集（📄）

**默認**：audit 為主（strict=mid）
**配額**：0-2 條候選/份

| mode | 動作 |
|------|------|
| 默認 / `[mode=audit]` | retrieve rules → 對 PRD 逐節掃描 → 輸出 audit 報告 |
| `[mode=extract-only]` | 跳過 audit，只提取背景想法中的「我意識到 X」型語句 |

**strict 嚴格度**：

| 模式 | P1 | P2 | P3 | 跨域 |
|------|----|----|----|------|
| `strict=high` | 必修 | 必修 | 必修 | 必修 |
| **`strict=mid`（默認）** | 必修 | 建議 | 忽略 | 必修 |
| `strict=low` | 必修 | 忽略 | 忽略 | 建議 |

**紅線**：不修改 PRD 原文，不寫 rules.json。

詳見 [[ADR-008]]。

---

## 6. 對話採集（💬）

**默認**：L0 對話歸零 + L1 自動摘要 + L2 識別信號時結晶
**配額**：3 候選/場 + 5 ADR/月 + 10 規則候選/月

**4 種流模式**：

| 模式 | 信號 | 路徑 |
|------|------|------|
| A 貼料流 | 「這篇文章/書/播客...」 | 對應採集源 SOP |
| B 設計流 | 「設計 X」「建立 Y 機制」 | ADR 候選 |
| C 諮詢流 | 「該怎麼做 X」「Y 違反規則嗎」 | retrieve audit |
| D 反思流 | 「剛踩了個坑」「總結這次...」 | 復盤 SOP |

**save-as 顯式結晶**：

| 標記 | 寫入位置 |
|------|---------|
| `[save-as=adr]` | `docs/decision-records/` |
| `[save-as=rule]` | `domains/*/rules-candidates.json` |
| `[save-as=decision]` | `docs/decisions/` |

詳見 [[ADR-009]] 和 [[docs/conversation-protocol.md]]。

---

## 覆蓋標記速查表

| 標記 | 完整 spec | 適用 |
|------|----------|------|
| `[tier=A]` | 規則級書，必親讀 | 書 |
| `[tier=B]` | 參考類，回讀段落 | 書 |
| `[tier=C]` | 消遣類，不入候選 | 書 |
| `[mode=attribution-only]` | 只歸因不提案 | 復盤/片段 |
| `[mode=new-rule]` | 強制走新候選路徑 | 片段 |
| `[mode=audit]` | 對 PRD 做 audit | 工作產物 |
| `[mode=extract-only]` | 只提背景想法 | 工作產物 |
| `[strict=high]` | P1+P2+P3+跨域全必修 | 工作產物 |
| `[strict=mid]` | P1+跨域必修，P2 建議 | 工作產物（默認） |
| `[strict=low]` | 僅 P1 必修 | 工作產物 |
| `[level=P1]` | 直接指定生存鐵律 | 手寫 |
| `[level=P2]` | 直接指定戰術（默認） | 手寫 |
| `[level=P3]` | 直接指定風格偏好 | 手寫 |
| `[save-as=adr]` | 結晶為 ADR | 對話 |
| `[save-as=rule]` | 結晶為規則候選 | 對話 |
| `[save-as=decision]` | 結晶為決策記錄 | 對話 |

---

## 配額紅線（ADR-004）

| 域 | P1+P2 上限 |
|----|-----------|
| trading-discipline | ≤ 30 |
| product-experience | ≤ 25 |
| personal-capability | ≤ 20 |
| 跨域原則（curate） | ≤ 7 |

| 來源 | 配額 |
|------|------|
| 書 | 3-7/書 |
| 復盤 | 1-2/篇 |
| 手寫 | 1/次 |
| 片段 | 5/月全域 |
| 工作產物 | 0-2/份 |
| 對話 | 3/場 + 5 ADR/月 + 10 規則/月 |

超配額 → 進 parking-lot，下月優先評審。

---

## 關聯文件

- [[SKILL.md]] 頂層說明
- [[rule-promotion-process.md]] 7 閘審查 SOP
- [[conversation-protocol.md]] 對話接口協議
- [[decision-records/004-rule-promotion-gates.md]] 閘 1-6
- [[decision-records/005-book-tier-protocol.md]] 書籍分級
- [[decision-records/006-handwritten-fast-track.md]] 閘 0
- [[decision-records/007-snippet-collection.md]] 片段機制
- [[decision-records/008-work-artifact-bidirectional.md]] 工作產物
- [[decision-records/009-conversation-as-interface.md]] 對話接口
