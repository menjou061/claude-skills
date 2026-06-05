# 蝉镜页面生成 Skill 版本记录

遵循 [Semantic Versioning](https://semver.org/lang/zh-CN/)：

- **MAJOR**：不兼容的工作流变更（如改变输出格式、改变核心约束）
- **MINOR**：新增组件/示例/能力，向后兼容
- **PATCH**：修订 token、修复样式 bug、补充文档

---

## v0.1.0 (2026-04-23)

**首发版本，最小可用集**。

### 新增

- **设计 token**（浅色主题）
  - 中性灰：`gray-light-01` ~ `gray-light-10`
  - 品牌色：`primary-light-01` ~ `primary-light-10`
  - 红色：`red-light-01` ~ `red-light-06`
  - 字体家族：PingFang SC 系列（Regular / Medium / Light / Bold）
  - 字号：12 / 13 / 14 / 15 / 16 / 18 / 20 / 24 / 26
  - 圆角、间距、Element Plus 主色覆盖
- **组件样式**
  - `cj-button`：8 个变体（primary / brand / brandAlt / border / brandBorder / danger / dangerBorder / white）+ 4 个尺寸 + 3 个形状 + 文字按钮
  - `cj-input` / `cj-textarea`：4 个尺寸 + hover / focus / disabled 状态
- **基础页面模板**：`references/page-template.html`，加载 Vue 3 + Element Plus CDN，自包含可双击预览
- **完整示例**：`references/examples/form-page.html`，演示新建数字人配置表单页
- **SKILL.md**：触发条件、强制工作流、强制规则清单、输出格式

### 已知边界

- 仅支持浅色主题
- 仅抽离 button、input/textarea 两类组件，其他组件需用 Element Plus 原生 + 自定义样式近似
- 不包含项目自定义业务组件（FlexDialog、YiLiMaterialSelectBtn 等）的 stub
- 不支持暗色主题
- 不支持自动 SCSS 同步，token 手工维护

### 后续路线（暂定）

- v0.2：补充 select、dialog、message 等高频组件
- v0.3：补充常用页面模式（列表页、详情页、向导）
- v0.4：常见业务组件 stub
- v0.5：与 Figma MCP 联动，从 URL 直接生成
- v1.0：自动 SCSS → token 同步脚本，暗色主题
