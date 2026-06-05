# 蝉镜组件样式（CSS 复刻版）

> 来源：`src/style/cj/button.scss`、`src/style/cj/input.scss`
> 用途：覆盖 Element Plus 默认样式，使其匹配蝉镜浅色主题。
> 用法：将下方 CSS 直接复制进 HTML 的 `<style>` 块，配合 `<el-button class="cj-button">`、`<el-input class="cj-input">` 使用。
> 前置依赖：必须先引入 `design-tokens.md` 中的 CSS 变量。

---

## Button（.cj-button）

### 用法

```html
<!-- 默认（灰色背景） -->
<el-button class="cj-button">默认</el-button>

<!-- 主按钮（深色） -->
<el-button class="cj-button" type="primary">主按钮</el-button>

<!-- 品牌色按钮（橙色渐变） -->
<el-button class="cj-button" type="brand">品牌</el-button>

<!-- 品牌弱化（橙底浅色） -->
<el-button class="cj-button" type="brandAlt">品牌弱</el-button>

<!-- 边框按钮 -->
<el-button class="cj-button" type="border">边框</el-button>

<!-- 品牌描边 -->
<el-button class="cj-button" type="brandBorder">品牌描边</el-button>

<!-- 危险按钮 -->
<el-button class="cj-button" type="danger">危险</el-button>

<!-- 危险描边 -->
<el-button class="cj-button" type="dangerBorder">危险描边</el-button>

<!-- 白色按钮（用于深色背景上） -->
<el-button class="cj-button" type="white">白色</el-button>

<!-- 文字按钮（任意 type 加 text 属性） -->
<el-button class="cj-button" text>文字按钮</el-button>
<el-button class="cj-button" type="brand" text>品牌文字</el-button>

<!-- 尺寸：small(28) / 默认(32) / large(36) / xlarge(40) -->
<el-button class="cj-button" size="small">小</el-button>
<el-button class="cj-button">默认</el-button>
<el-button class="cj-button" size="large">大</el-button>
<el-button class="cj-button cj-button--xlarge">超大</el-button>

<!-- 形状：圆角 / 圆形 / 方形（图标按钮） -->
<el-button class="cj-button" round>圆角</el-button>
<el-button class="cj-button" circle>i</el-button>

<!-- 禁用 -->
<el-button class="cj-button" disabled>禁用</el-button>
```

### 样式定义

```css
.cj-button {
  --el-button-size: 32px;
  border-radius: var(--radius-md);
  padding: 0 14px;
  color: var(--gray-light-10);
  background-color: var(--gray-light-02);
  border-color: transparent;
  font-size: var(--font-size-14);
  font-family: var(--font-family-regular);
  transition: background-color 0.15s, color 0.15s, border-color 0.15s;
}
.cj-button:hover { background: var(--gray-light-03); }
.cj-button:active { background: var(--gray-light-04); }
.cj-button.is-disabled,
.cj-button.is-disabled:hover {
  color: var(--gray-light-05);
  background: var(--gray-light-01);
  cursor: not-allowed;
}

/* 文字按钮通用 */
.cj-button.is-text {
  background: none;
  color: var(--gray-light-09);
  padding: 0 4px;
}
.cj-button.is-text:hover { color: var(--gray-light-07); background: none; }
.cj-button.is-text:active { color: var(--gray-light-10); background: none; }
.cj-button.is-text.is-disabled { color: var(--gray-light-05); background: none; }

/* 尺寸 */
.cj-button.el-button--small { --el-button-size: 28px; padding: 0 12px; font-size: var(--font-size-14); }
.cj-button.el-button--large { --el-button-size: 36px; border-radius: var(--radius-lg); }
.cj-button.cj-button--xlarge { --el-button-size: 40px; height: var(--el-button-size); padding: 0 16px; border-radius: var(--radius-lg); }

/* 形状 */
.cj-button.is-round { border-radius: var(--radius-pill); }
.cj-button.is-circle { width: var(--el-button-size); border-radius: 50%; padding: 0; }

/* ============ 变体 ============ */

/* primary：深色 */
.cj-button.el-button--primary,
.cj-button[type="primary"] {
  color: #fff;
  background-color: var(--gray-light-10);
  border-color: transparent;
}
.cj-button.el-button--primary:hover,
.cj-button[type="primary"]:hover { background-color: var(--gray-light-09); }
.cj-button.el-button--primary:active,
.cj-button[type="primary"]:active { background-color: var(--gray-light-09); }
.cj-button.el-button--primary.is-disabled {
  color: #fff;
  background: var(--gray-light-05);
  border: 1px solid var(--gray-light-05);
}

/* brand：橙色渐变 */
.cj-button.el-button--brand,
.cj-button[type="brand"] {
  color: #fff;
  background: linear-gradient(90deg, #FE653D 21.5%, #FF382B 100%);
  background-origin: border-box;
  border-color: transparent;
}
.cj-button.el-button--brand:hover,
.cj-button[type="brand"]:hover {
  background: linear-gradient(90deg, #E55C38 0%, #E53228 100%);
}
.cj-button.el-button--brand:active,
.cj-button[type="brand"]:active {
  background: linear-gradient(90deg, #E55C38 0%, #E53228 100%);
}
.cj-button.el-button--brand.is-disabled {
  background: linear-gradient(90deg, #FFC1B1 0%, #FFAFAA 100%);
}
.cj-button.el-button--brand.is-text,
.cj-button[type="brand"].is-text {
  background: none;
  color: var(--primary-light-08);
}
.cj-button.el-button--brand.is-text:hover,
.cj-button[type="brand"].is-text:hover { color: var(--primary-light-07); }
.cj-button.el-button--brand.is-text:active,
.cj-button[type="brand"].is-text:active { color: var(--primary-light-09); }
.cj-button.el-button--brand.is-text.is-disabled { color: var(--primary-light-05); }

/* brandAlt：橙底浅色 */
.cj-button.el-button--brandAlt,
.cj-button[type="brandAlt"] {
  color: var(--primary-light-08);
  background: var(--primary-light-01);
  border-color: transparent;
}
.cj-button.el-button--brandAlt:hover,
.cj-button[type="brandAlt"]:hover {
  color: var(--primary-light-07);
  background: var(--primary-light-02);
}
.cj-button.el-button--brandAlt:active,
.cj-button[type="brandAlt"]:active {
  color: var(--primary-light-09);
  background: var(--primary-light-02);
}
.cj-button.el-button--brandAlt.is-disabled {
  color: var(--primary-light-05);
  background: var(--primary-light-01);
}

/* border：白底灰边 */
.cj-button.el-button--border,
.cj-button[type="border"] {
  color: var(--gray-light-10);
  background-color: #fff;
  border: 1px solid var(--gray-light-02);
}
.cj-button.el-button--border:hover,
.cj-button[type="border"]:hover {
  background-color: var(--gray-light-01);
  border-color: var(--gray-light-06);
}
.cj-button.el-button--border:active,
.cj-button[type="border"]:active {
  background-color: var(--gray-light-02);
  border-color: var(--gray-light-07);
}
.cj-button.el-button--border.is-disabled {
  color: var(--gray-light-05);
  background: #fff;
  border: 1px solid var(--gray-light-02);
}

/* brandBorder：白底橙边 */
.cj-button.el-button--brandBorder,
.cj-button[type="brandBorder"] {
  color: var(--primary-light-08);
  background-color: #fff;
  border: 1px solid var(--primary-light-08);
}
.cj-button.el-button--brandBorder:hover,
.cj-button[type="brandBorder"]:hover {
  color: var(--primary-light-07);
  border-color: var(--primary-light-07);
}
.cj-button.el-button--brandBorder:active,
.cj-button[type="brandBorder"]:active {
  color: var(--primary-light-09);
  border-color: var(--primary-light-09);
}
.cj-button.el-button--brandBorder.is-disabled {
  color: var(--primary-light-05);
  border: 1px solid var(--primary-light-05);
  background: #fff;
}

/* danger：红色 */
.cj-button.el-button--danger,
.cj-button[type="danger"] {
  color: #fff;
  background: var(--red-light-01);
  border-color: transparent;
}
.cj-button.el-button--danger:hover,
.cj-button[type="danger"]:hover { background: var(--red-light-02); }
.cj-button.el-button--danger:active,
.cj-button[type="danger"]:active { background: var(--red-light-03); }
.cj-button.el-button--danger.is-disabled { background: var(--red-light-04); }

/* dangerBorder：白底红边 */
.cj-button.el-button--dangerBorder,
.cj-button[type="dangerBorder"] {
  color: var(--red-light-01);
  background-color: #fff;
  border: 1px solid var(--red-light-01);
}
.cj-button.el-button--dangerBorder:hover,
.cj-button[type="dangerBorder"]:hover {
  background-color: var(--red-light-06);
  border-color: var(--red-light-02);
}
.cj-button.el-button--dangerBorder:active,
.cj-button[type="dangerBorder"]:active {
  background-color: var(--red-light-06);
  border-color: var(--red-light-03);
}
.cj-button.el-button--dangerBorder.is-disabled {
  color: var(--primary-light-05);
  background-color: #fff;
  border: 1px solid var(--primary-light-05);
}

/* white：白底（用于深色背景上） */
.cj-button.el-button--white,
.cj-button[type="white"] {
  color: var(--gray-light-10);
  background-color: #fff;
  border-color: transparent;
}
.cj-button.el-button--white:hover,
.cj-button[type="white"]:hover { background-color: var(--gray-light-02); }
.cj-button.el-button--white:active,
.cj-button[type="white"]:active { background-color: var(--gray-light-03); }
```

---

## Input / Textarea（.cj-input / .cj-textarea）

### 用法

```html
<!-- 默认 input（高度 32） -->
<el-input class="cj-input" v-model="value" placeholder="请输入" />

<!-- 尺寸：small(28) / 默认(32) / medium(36) / large(40) -->
<el-input class="cj-input" size="small" placeholder="小输入框" />
<el-input class="cj-input" placeholder="默认 32" />
<el-input class="cj-input" size="medium" placeholder="36" />
<el-input class="cj-input" size="large" placeholder="40" />

<!-- 禁用 -->
<el-input class="cj-input" disabled placeholder="禁用" />

<!-- 带清空 -->
<el-input class="cj-input" v-model="value" clearable placeholder="可清空" />

<!-- textarea -->
<el-input class="cj-textarea" type="textarea" :rows="4" v-model="value" placeholder="多行文本" />

<!-- textarea 带字数统计 -->
<el-input class="cj-textarea" type="textarea" :rows="4" maxlength="200" show-word-limit v-model="value" />
```

### 样式定义

```css
/* ============ Input ============ */
/* 重要：在 flex 容器中使用时需要 100% 宽度 + min-width:0，
   否则 el-input 会按 placeholder 内容计算宽度，导致 flex 撑开换行 */
.cj-input,
.cj-input.el-input { width: 100%; min-width: 0; }

.cj-input {
  --el-input-height: 32px;
}
.cj-input .el-input__wrapper {
  border-radius: var(--radius-md);
  background: var(--gray-light-01);
  box-shadow: 0 0 0 1px var(--gray-light-01) inset;
  transition: background 0.15s, box-shadow 0.15s;
}
.cj-input .el-input__inner { color: var(--gray-light-10); }
.cj-input .el-input__wrapper:hover {
  background: transparent;
  box-shadow: 0 0 0 1px var(--primary-light-08) inset;
}
.cj-input .el-input__wrapper.is-focus {
  background: transparent;
  box-shadow: 0 0 0 1px var(--primary-light-08) inset;
}
.cj-input input::placeholder { color: var(--gray-light-05); }

/* 尺寸 */
.cj-input.el-input--small { --el-input-height: 28px; }
.cj-input.el-input--medium { --el-input-height: 36px; }
.cj-input.el-input--large { --el-input-height: 40px; }

/* 禁用 */
.cj-input.is-disabled .el-input__wrapper,
.cj-input.is-disabled .el-input__wrapper:hover {
  background: var(--gray-light-02);
  box-shadow: 0 0 0 1px var(--gray-light-02) inset;
}
.cj-input.is-disabled .el-input__inner { color: var(--gray-light-05); }

/* ============ Textarea ============ */
.cj-textarea,
.cj-textarea.el-textarea { width: 100%; min-width: 0; }

.cj-textarea .el-textarea__inner {
  background: var(--gray-light-01);
  box-shadow: 0 0 0 1px var(--gray-light-01) inset;
  color: var(--gray-light-10);
  border: none;
  border-radius: var(--radius-md);
  resize: none;
  font-family: var(--font-family-regular);
  transition: background 0.15s, box-shadow 0.15s;
}
.cj-textarea .el-textarea__inner:hover {
  background: transparent;
  box-shadow: 0 0 0 1px var(--primary-light-08) inset;
}
.cj-textarea .el-textarea__inner:focus {
  background: transparent;
  box-shadow: 0 0 0 1px var(--primary-light-08) inset;
}
.cj-textarea textarea::placeholder { color: var(--gray-light-05); }
.cj-textarea .el-input__count {
  color: var(--gray-light-07);
  background: transparent;
}
.cj-textarea.is-disabled .el-textarea__inner,
.cj-textarea.is-disabled .el-textarea__inner:hover {
  background: var(--gray-light-02);
  box-shadow: 0 0 0 1px var(--gray-light-02) inset;
  color: var(--gray-light-05);
}
```

---

## 二次开发提示（给开发的备注）

- HTML 中的 `<el-button class="cj-button">` 在项目内可直接保留
- HTML 中的 `<el-input class="cj-input">` 在项目内可直接保留
- 项目内 cj-button/cj-input 的真实样式来自 `src/style/cj/button.scss` 和 `src/style/cj/input.scss`，已带 `!important` 覆盖 Element Plus 默认样式，开发时只需保留 class 名即可生效
- `type="brand"` / `type="brandAlt"` / `type="border"` / `type="brandBorder"` / `type="dangerBorder"` / `type="white"` 是项目自定义类型，Element Plus 不识别但通过属性选择器 `[type="..."]` 命中样式
