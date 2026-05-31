# Claude Code Skills 整理

> 更新日期：2026-05-20

本文档整理了当前 Claude Code 配置中的所有可用 skill，共 **11 个**，覆盖设计生成、代码审查、AI 开发、配置管理、笔记归档五大方向。

---

## 设计 & 前端

### `ui-ux-pro-max`
UI/UX 设计智能助手。
- 支持 67 种风格、96 种配色、57 种字体搭配
- 覆盖 13 种技术栈：React、Next.js、Vue、Svelte、SwiftUI、React Native、Flutter、Tailwind、shadcn/ui 等
- 可生成网站、Landing Page、Dashboard、Admin Panel、移动端等各类界面
- 支持 glassmorphism、bento grid、brutalism、dark mode 等主流设计风格

### `chanjing-page-gen`
蝉镜 AI 项目（ai-person）专用页面生成器。
- 输出符合项目浅色主题设计规范的自包含 `.html` 原型文件
- PM 双击即可在浏览器预览，开发可直接翻译为 Vue SFC

---

## 代码质量

### `simplify`
审查已修改代码的复用性、质量和效率，并自动修复发现的问题。

### `security-review`
对当前分支的待提交变更做完整安全审查。

### `review`
Code Review，审查 Pull Request。

---

## Claude API / AI 开发

### `claude-api`
构建、调试、优化 Claude API / Anthropic SDK 应用。
- 默认集成提示缓存（prompt caching）
- 支持模型版本迁移：4.5 → 4.6 → 4.7
- 覆盖工具调用（tool use）、批处理、文件 API、citations、memory 等特性
- 触发条件：代码中出现 `anthropic` / `@anthropic-ai/sdk` 导入，或涉及 Opus/Sonnet/Haiku 模型配置

---

## 项目初始化

### `init`
为代码库自动生成 `CLAUDE.md` 文档，记录代码库结构、规范和上下文。

---

## 配置 & 快捷键

### `update-config`
修改 `settings.json`，适用于：
- 配置自动化 hook（"每次 X 时执行 Y"）
- 权限管理（allow/add permission）
- 环境变量设置
- hook 排查

> 注：自动化行为必须通过此 skill 写入 harness 配置，不能仅靠 memory/preferences 实现。

### `keybindings-help`
自定义键盘快捷键，修改 `~/.claude/keybindings.json`，支持和弦绑定（chord bindings）。

---

## 笔记 & 记录

### `obsidian-inbox`
将当前对话要点整理为结构化 Markdown，写入 Obsidian 的 `00-Inbox` 目录。
- 触发词：「记备忘」「存到 Obsidian」「存到收件箱」

### `knowledge-governance`
个人决策治理系统：7 闸规则晋升 + 6 类采集源 + 5 条紅线（含元层「不自我授权」）。
- 三个域：trading-discipline（投资）/ product-experience（产品）/ personal-capability（个人能力）+ book-digest（读书）+ curate（跨域策展）
- 真源（Obsidian / 笔记系统）和 CC repo（治理流程 staging）严格分离
- 7 闸：元认知 / 唯一性 / 可执行 / 痛感 / 频次 / 层级 / 个人化回测
- 触发场景：候选规则晋升、复盘提案、PRD audit、对话结晶
- 详见 `knowledge-governance/README.md`

---

## 任务调度

### `loop`
设置周期性任务，按指定间隔重复执行某个 prompt 或 skill。
- 示例：`/loop 5m /review` 每 5 分钟执行一次 review
- 默认间隔：10 分钟
- 适用于轮询部署状态、持续监控等场景

---

## 快速参考

| Skill | 分类 | 调用方式 |
|---|---|---|
| `ui-ux-pro-max` | 设计 | `/ui-ux-pro-max` |
| `chanjing-page-gen` | 设计 | `/chanjing-page-gen` |
| `simplify` | 代码质量 | `/simplify` |
| `security-review` | 代码质量 | `/security-review` |
| `review` | 代码质量 | `/review` |
| `claude-api` | AI 开发 | `/claude-api` |
| `init` | 项目初始化 | `/init` |
| `update-config` | 配置 | `/update-config` |
| `keybindings-help` | 配置 | `/keybindings-help` |
| `obsidian-inbox` | 笔记 | `/obsidian-inbox` |
| `loop` | 调度 | `/loop` |
