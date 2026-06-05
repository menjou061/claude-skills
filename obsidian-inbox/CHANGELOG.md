# Obsidian Inbox Skill 版本记录

遵循 [Semantic Versioning](https://semver.org/lang/zh-CN/)：

- **MAJOR**：不兼容的工作流变更（如改变输出格式、改变核心约束）
- **MINOR**：新增节模板/能力，向后兼容
- **PATCH**：修订配置值、修复规则措辞、补充文档

---

## v0.1.0 (2026-05-11)

**首发版本，最小可用集**。

### 新增

- **SKILL.md**：触发条件、强制工作流（6 步）、强制规则清单、输出格式
- **配置区**：`INBOX_PATH` / `FILENAME` / `DEFAULT_TAG` / `MAX_TAGS` 集中在文件顶部，一处修改全局生效
- **references/note-template.md**：标准笔记结构（frontmatter + 5 个内容节）
- **强制规则清单**：文件名、frontmatter、正文结构、安全四类规则

### 已知边界

- 仅支持单次手动触发，不含自动定时归档
- 不支持追加到已有笔记（每次生成新文件）
- 不含 Obsidian 模板变量（如 `{{date}}`）与 Templater 插件联动

### 后续路线（暂定）

- v0.2：支持"追加到今日日记"模式（Daily Note）
- v0.3：支持按话题自动归类到对应 vault 子目录
- v0.4：与 `chanjing-page-gen` 联动，生成页面原型后自动记录设计决策
- v1.0：支持多 vault 配置，通过参数切换目标路径
