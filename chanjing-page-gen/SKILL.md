---
name: chanjing-page-gen
description: 当用户描述要生成蝉镜 AI 项目（ai-person）的页面、弹窗或原型，需要符合项目浅色主题设计规范的可预览 HTML 草稿时使用。生成自包含 .html 文件，PM 双击即可在浏览器预览，开发拿来作为高保真设计稿二次翻译为 Vue SFC。
---

# 蝉镜页面生成 Skill

**版本：v0.1.0**
**适用项目：ai-person（蝉镜 AI）**
**主题：浅色（light）**

---

## 触发条件

当用户消息中包含以下任一类关键词时，**必须**使用此 Skill：

- "生成页面" / "生成原型" / "做一个页面" / "做个原型"
- "做一个弹窗" / "做个对话框"
- "蝉镜风格" / "符合项目设计规范" / "项目内的样式"
- 描述要新建/搭建某个具体页面（如"我要做一个数字人创建页"）

如果用户提供了 Figma 链接，**优先**与已有的 `figma-cdn-auto-upload` skill 配合使用，先从 Figma 提取布局/资源，再走本 skill 的输出规则。

---

## 工作流程（严格按顺序执行）

### 步骤 1：理解需求

询问或确认（如未明确）：
- 页面类型（列表 / 详情 / 表单 / 弹窗 / 向导 / 仪表盘）
- 主要数据（展示什么）
- 主要操作（用户能做什么）
- 是否有参考（Figma 链接 / 已有页面）

如果是非常简单的需求，可跳过询问直接进入步骤 2。

### 步骤 2：阅读参考资料（按顺序）

1. **必读**：[`references/page-template.html`](./references/page-template.html) — 基础骨架，复制它作为新文件起点
2. **必读**：[`references/design-tokens.md`](./references/design-tokens.md) — 颜色/字号/间距/圆角 token
3. **必读**：[`references/component-styles.md`](./references/component-styles.md) — button/input 用法
4. **建议**：[`references/examples/form-page.html`](./references/examples/form-page.html) — 完整示例，参考其结构、命名、TODO 标签写法

### 步骤 3：生成 HTML

基于 `page-template.html` 复制并扩展，输出**单个自包含 .html 文件**。

文件名规则：`<feature>-page.html` 或 `<feature>-dialog.html`，如：
- `digital-human-create-page.html`
- `voice-clone-dialog.html`

输出位置：默认输出到当前工作目录下的 `chanjing-prototype/` 子目录（如不存在则提示用户确认）。如用户指定位置，按用户指定。

### 步骤 4：自检（输出后必做）

输出完成后，**必须**对照下方"强制规则清单"自检一遍，确保全部满足。如有违反，立即修正。

---

## 强制规则清单（必须全部满足）

### CSS / 样式

- [ ] **必须**所有颜色通过 CSS 变量引用（`var(--gray-light-10)` 等），**禁止**裸写 `#1D2129`、`#FF7752` 等色值
- [ ] **必须**所有字号通过 CSS 变量引用（`var(--font-size-14)` 等），**禁止**裸写 `14px`、`16px` 等
- [ ] **禁止**加载 UnoCSS、Tailwind、SCSS、Less、任何预处理器
- [ ] **禁止**引用 `~@cdn?xxx` 或项目特有的资源协议（HTML 在项目外预览，无法解析）
- [ ] 所有 CSS 写在文件内单一 `<style>` 块中

### 组件

- [ ] **必须**用 `<el-button class="cj-button" type="...">` 而不是裸 `<button>`
- [ ] **必须**用 `<el-input class="cj-input">` / `<el-input class="cj-textarea" type="textarea">` 而不是裸 `<input>` / `<textarea>`
- [ ] button 的 type 仅可使用以下值（其他值会无样式）：
  `primary` / `brand` / `brandAlt` / `border` / `brandBorder` / `danger` / `dangerBorder` / `white` / 不传（默认灰）
- [ ] 不使用本 skill 未抽离的项目自定义组件（如 FlexDialog、YiLiMaterialSelectBtn 等）。需要类似功能时用 Element Plus 原生组件 + 自定义样式实现近似外观

### 响应式

- [ ] **必须**包含至少 2 个媒体查询断点：`@media (max-width: 1024px)` 和 `@media (max-width: 768px)`
- [ ] **必须**使用 flex / grid / 百分比，避免大量绝对像素
- [ ] 表单/卡片在小屏自动堆叠（flex-direction: column）
- [ ] 操作按钮在小屏占满宽度

### 业务接入点

- [ ] 所有需要接入接口的位置用 `// TODO[API]: 描述` 标注（HTML 注释里用 `<!-- TODO[API]: ... -->`）
- [ ] 所有需要接入 store 的位置用 `// TODO[STORE]: 描述`
- [ ] 所有需要路由跳转的位置用 `// TODO[ROUTE]: 描述`
- [ ] 列表/选项数据用 mock 写死，**禁止**编造真实接口路径

### 文件结构

- [ ] 文件顶部必须有 HTML 注释块，包含：版本号、用途、二次开发提示
- [ ] `<template>` 段落用 `<!-- ====================== TEMPLATE 段开始 ====================== -->` / `结束` 注释包裹
- [ ] `<script>` 段落用同样的开始/结束注释包裹
- [ ] 单文件不超过 600 行；超过则建议用户拆分（如大表单拆成多步骤、列表与详情分开）

### 代码风格

- [ ] Vue 用 Composition API 写法（`setup()` + `ref` / `reactive`）— 方便开发改成 `<script setup>`
- [ ] 命名贴近项目习惯：变量 camelCase、组件名 PascalCase、CSS 类名 kebab-case
- [ ] 中文文案：用真实但通用的中文示例（如"请输入"、"保存"、"创建"），避免 Lorem Ipsum

---

## 输出格式

生成完成后，向用户输出：

1. **生成结果**：文件路径
2. **预览方式**：`双击 xxx.html，或在 Cursor 中右键选择"Open with Live Preview"`
3. **包含的功能要点**：简要列 3-5 条（如"3 个表单卡片 / 响应式适配 / 4 个操作按钮"）
4. **TODO 项汇总**：列出所有 `TODO[API]` / `TODO[STORE]` / `TODO[ROUTE]` 的数量和大致用途，方便开发对接
5. **二次开发提示**：提醒开发可直接复制 `<template>` 和 `<script>` 段，cj-button/cj-input class 名在项目内生效

---

## 不确定时先问

遇到以下情况**必须先询问用户**：

- 页面类型不明确（不知道是列表还是详情）
- 用户需求很大（涉及多个页面），不确定是一次生成还是拆分
- 用户提到了本 skill 未抽离的复杂业务组件，不确定用什么近似实现
- 颜色/字体规范在 design-tokens.md 中找不到对应项

---

## 适用边界（哪些情况不该用本 skill）

- 用户要直接修改项目内 `.vue` 文件 → 不用本 skill，按项目规范直接编辑
- 用户要生成可立即合并到项目的代码 → 本 skill 输出的是预览 HTML，不直接合并
- 用户需要复杂业务逻辑（真实 API 调用、状态管理、多页面联动） → 本 skill 只生成 UI 骨架，业务逻辑由开发补全

---

## 版本历史

详见 [`CHANGELOG.md`](./CHANGELOG.md)。
