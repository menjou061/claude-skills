# 上传新 Skill 到仓库

## 前置：配置 git remote（每台设备一次性）

```bash
git clone https://github.com/menjou061/claude-skills.git ~/claude-skills
cd ~/claude-skills
git remote set-url origin https://<YOUR_TOKEN>@github.com/menjou061/claude-skills.git
```

Token 在 https://github.com/settings/tokens/new 生成，勾选 `repo` 权限。

---

## 上传一个新 Skill

### 1. 拉取最新代码

```bash
cd ~/claude-skills && git pull
```

### 2. 创建 skill 目录

目录名用 skill 的 `name` 字段，小写加连字符：

```bash
mkdir ~/claude-skills/my-new-skill
```

### 3. 必须包含的文件

**`SKILL.md`**（Claude Code 加载入口，必须有 frontmatter）：

```markdown
---
name: my-new-skill
description: '一句话描述触发条件，Claude 用这个判断何时调用此 skill'
---

# Skill 标题

具体指令内容...
```

**`README.md`**（人类可读说明）：

```markdown
# my-new-skill

一句话说明这个 skill 做什么。

## 触发条件
## 核心逻辑
## 依赖
## 文件
```

### 4. 提交并推送

```bash
cd ~/claude-skills
git add my-new-skill/
git commit -m "Add my-new-skill: 一句话说明"
git push
```

### 5. 在本机软链接（让 Claude Code 识别）

```bash
ln -s ~/claude-skills/my-new-skill ~/.claude/skills/my-new-skill
```

---

## 更新已有 Skill

```bash
cd ~/claude-skills
git pull                          # 先同步
# 编辑文件...
git add my-skill/
git commit -m "Update my-skill: 说明改了什么"
git push
```

---

## 目录结构规范

```
my-new-skill/
├── SKILL.md        # 必须，Claude Code 加载入口
├── README.md       # 必须，人类可读说明
└── references/     # 可选，补充参考文档（较长的上下文单独放这里）
    └── xxx.md
```

如果 skill 依赖外部 git 仓库（如第三方工具），用 submodule 而不是直接复制：

```bash
git submodule add https://github.com/xxx/yyy my-new-skill
```

---

## 注意事项

- **不要提交 token、API key、密码**，这些放在本机环境变量里
- **不要提交本机绝对路径**（如 `/Users/yourname/...`），路径写成 `~/...` 或相对路径
- `prompts/` 和 `scripts/` 目录同理，新增文件后 push，其他设备 `git pull` 即可同步
