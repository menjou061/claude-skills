# 蝉镜 Design Tokens（浅色主题）

> 来源：`src/style/variable.scss` 的"新样式升级"段落 + `src/style/font.scss`
> 本文件提供 CSS 变量声明，可直接复制到 HTML 的 `<style>` 块中。
> 所有颜色/字号在生成 HTML 时**必须**通过 CSS 变量引用，禁止硬编码。

---

## 完整 CSS 变量声明（直接复制使用）

```css
:root {
  /* ============ 中性灰 gray-light ============ */
  --gray-light-01: #F7F8FA;  /* 填充_浅_禁用 */
  --gray-light-02: #EDEFF3;  /* 边框_浅 / 填充_一般_白底悬浮 / 线条_浅 */
  --gray-light-03: #E5E6EC;  /* 边框_一般 / 填充_深_灰底悬浮 / 线条_一般 */
  --gray-light-04: #DBDEE3;  /* 填充_重 */
  --gray-light-05: #C9CDD4;  /* 文字_置灰 / 填充_强调 / 主色禁用 / placeholder */
  --gray-light-06: #A9AEB8;  /* 边框_深 / 线条_深 */
  --gray-light-07: #86909C;  /* 文字_次要信息 / 边框_重 */
  --gray-light-08: #6B7785;  /* 描述 */
  --gray-light-09: #4E5969;  /* 文字_次强调_正文标题 / 主色 hover */
  --gray-light-10: #1D2129;  /* 文字_强调 / 主色 */

  /* ============ 品牌色 brand-light ============ */
  --primary-light-01: #FFF8F6;  /* 浅背景色 / 选中底色 */
  --primary-light-02: #FFF1EE;
  --primary-light-03: #FFE4DC;
  --primary-light-04: #FFD6CB;
  --primary-light-05: #FFC9BA;  /* 文字禁用 / 按钮禁用 */
  --primary-light-06: #FFA086;
  --primary-light-07: #FF9275;  /* hover */
  --primary-light-08: #FF7752;  /* 品牌色 / 默认色 / 强调色 */
  --primary-light-09: #E56B4A;  /* 点击 */
  --primary-light-10: #CC5F42;  /* 重色文字 */

  /* ============ 红色 red-light（错误/危险） ============ */
  --red-light-01: #F54B45;  /* 失败_常规 */
  --red-light-02: #F76E66;  /* 悬浮 */
  --red-light-03: #CB2C2B;  /* 点击 */
  --red-light-04: #FBB1A5;  /* 禁用 */
  --red-light-05: #FDD0C6;  /* 特殊场景 */
  --red-light-06: #FFEDE8;  /* 浅色背景 */

  /* ============ 字体家族 ============ */
  --font-family-regular: "PingFangSC-Regular", "Microsoft Yahei", Arial, sans-serif;
  --font-family-medium: "PingFangSC-Medium", "Microsoft Yahei", Arial, sans-serif;
  --font-family-light: "PingFangSC-Light", "Microsoft Yahei", Arial, sans-serif;
  --font-family-bold: "PingFangSC-Semibold", "PingFangSC-Regular", "Microsoft Yahei", Arial, sans-serif;

  /* ============ 字号 ============ */
  --font-size-12: 12px;
  --font-size-13: 13px;
  --font-size-14: 14px;  /* 默认正文 */
  --font-size-15: 15px;
  --font-size-16: 16px;
  --font-size-18: 18px;
  --font-size-20: 20px;
  --font-size-24: 24px;
  --font-size-26: 26px;

  /* ============ 圆角 ============ */
  --radius-sm: 4px;
  --radius-md: 6px;   /* 默认（按钮、输入框） */
  --radius-lg: 8px;   /* 大按钮、卡片 */
  --radius-xl: 12px;
  --radius-pill: 100px;

  /* ============ 间距（建议步长） ============ */
  --space-2: 2px;
  --space-4: 4px;
  --space-8: 8px;
  --space-12: 12px;
  --space-16: 16px;
  --space-20: 20px;
  --space-24: 24px;
  --space-32: 32px;
  --space-40: 40px;

  /* ============ Element Plus 主色覆盖 ============ */
  --el-color-primary: #FF7752;
}

/* ============ 全局基础 ============ */
body {
  font-family: var(--font-family-regular);
  font-size: var(--font-size-14);
  color: var(--gray-light-10);
  background: #fff;
  margin: 0;
  -webkit-font-smoothing: antialiased;
}
```

---

## 用法速查

### 文字颜色

| 用途 | 变量 |
|---|---|
| 主标题 / 强调正文 | `var(--gray-light-10)` |
| 次强调正文 / 副标题 | `var(--gray-light-09)` |
| 描述 / 二级文字 | `var(--gray-light-08)` |
| 次要信息 / 辅助文案 | `var(--gray-light-07)` |
| placeholder / 禁用文字 | `var(--gray-light-05)` |
| 品牌色文字 | `var(--primary-light-08)` |
| 错误提示 | `var(--red-light-01)` |

### 背景颜色

| 用途 | 变量 |
|---|---|
| 页面底色 | `#fff` |
| 卡片/区块底色 | `#fff` 或 `var(--gray-light-01)` |
| 浅灰背景（如输入框） | `var(--gray-light-01)` |
| hover 灰底 | `var(--gray-light-02)` |
| active 灰底 | `var(--gray-light-03)` |
| 品牌色浅背景 / 选中底 | `var(--primary-light-01)` |
| 错误浅背景 | `var(--red-light-06)` |

### 边框颜色

| 用途 | 变量 |
|---|---|
| 浅边框 / 分割线 | `var(--gray-light-02)` |
| 默认边框 | `var(--gray-light-03)` |
| 强调边框 | `var(--gray-light-06)` |
| 聚焦/品牌边框 | `var(--primary-light-08)` |
| 错误边框 | `var(--red-light-01)` |

### 字号语义

| 用途 | 变量 |
|---|---|
| 辅助/角标 | `var(--font-size-12)` |
| 正文（默认） | `var(--font-size-14)` |
| 副标题 | `var(--font-size-16)` |
| 区块标题 | `var(--font-size-18)` |
| 页面标题 | `var(--font-size-20)` 或 `var(--font-size-24)` |
| 大标题 | `var(--font-size-26)` |

---

## 示例

```html
<style>
  .page-title {
    font-size: var(--font-size-24);
    font-family: var(--font-family-bold);
    color: var(--gray-light-10);
    margin-bottom: var(--space-16);
  }
  .description {
    font-size: var(--font-size-14);
    color: var(--gray-light-08);
    line-height: 1.6;
  }
  .card {
    background: #fff;
    border: 1px solid var(--gray-light-02);
    border-radius: var(--radius-lg);
    padding: var(--space-24);
  }
</style>
```
