# book-digest SKILL

<!-- v0.1 骨架：當實現第一本書處理時，按需建立 schemas/ prompts/ references/ 子目錄；
     output 直接寫入 Obsidian wiki/資料摘要/ -->

## 職責

系統化讀書，產出結構化卡片，可餵入其他域評估體系。

## 卡片類型

| 類型 | 說明 |
|------|------|
| `book-overview` | 全書摘要，含核心論點與結構 |
| `person-profile` | 書中關鍵人物側寫 |
| `decision-node` | 書中重要決策節點拆解 |
| `methodology-extract` | 可複用的方法論提煉 |

## 輸入格式

接受 `pdf`、`epub`、`markdown`。

## 輸出目標

Obsidian `wiki/資料摘要/` 目錄下的 markdown 文件。

## 子目錄建立時機

- `schemas/`：第一本書處理完成、卡片格式穩定後建立
- `prompts/`：提煉出可複用的採集 prompt 後建立
- `references/`：需要跨書引用管理時建立
- `output-template/`：輸出格式固化後建立

在此之前，直接在此目錄下操作，避免空殼目錄污染倉庫。
