---
name: initialize-workspace
description: >-
  在 ~/AI_STUDIO_WS/ 下初始化 AI_STUDIO 工作空间。根据 theme 读取 themes/<theme>.md
  执行装配。在用户提供工作空间名称、要求开通/预置/新建工作空间时使用。
disable-model-invocation: true
---

# 工作空间初始化

将用户给定的工作空间名称落盘为 `~/AI_STUDIO_WS/<slug>/` 下的完整工作空间实例。

## 输入

| 项 | 必填 | 说明 |
|----|------|------|
| 工作空间名称 `name` | 是 | Portal 显示名 |
| slug | 否 | 目录名；缺省由 `name` 推导（小写、空格→`-`、仅 `[a-z0-9_-]`） |
| 主题 `theme` | 否 | 缺省 `standard` |

**slug 规则**：仅字母、数字、`_`、`-`；必须与目录名一致；不得覆盖已有工作空间（除非用户明确要求并备份）。

## 主题说明文档

**每个 theme 的 Skill 列表、Command 列表、初始目录、config 差异项，均在独立文档中维护，不在本 Skill 主体重复。**

确定 `theme` 后，**必须先完整阅读并严格按文档执行**（见下表 `themes/*.md`，**不是**本目录的 `SKILL.md`）。

| theme | 主题说明文档 |
|-------|--------------|
| `standard` | [themes/standard.md](themes/standard.md) |
| `development` | [themes/development.md](themes/development.md) |
| `testing` | [themes/testing.md](themes/testing.md) |
| `documentation` | [themes/documentation.md](themes/documentation.md) |
| `management` | [themes/management.md](themes/management.md) |
| `admin` | [themes/admin.md](themes/admin.md) |
| `skill` | [themes/skill-management.md](themes/skill-management.md) |

文档不存在或 `theme` 无效时 **停止**，请用户确认 theme 或补充对应 `themes/*.md`。

## 平台规范（只读）

执行前按需查阅，勿将其中主题差异写入本 Skill：

- `AI_STUDIO/docs/workspace-provisioning.md`
- `AI_STUDIO/workspace_example/` — 复制用 MVP 模板

## 执行流程

```text
- [ ] 1. 确认 name、slug、theme
- [ ] 2. 阅读 themes/<theme>.md
- [ ] 3. 复制 workspace_example 到 ~/AI_STUDIO_WS/<slug>/
- [ ] 4. 按主题文档写入 config.json、skills.json
- [ ] 5. 按主题文档装配 Command、Rules、Cursor Skill
- [ ] 6. 按主题文档创建初始目录
- [ ] 7. 校验并写入 docs/workspace-init-report.md
```

### 1. 确认输入

1. 确认 **name**、**slug**（推导须获用户确认）、**theme**（未指定则 `standard`）。
2. 目标路径：`$HOME/AI_STUDIO_WS/<slug>/`。
3. 若已存在 `.ai_studio/config.json` 且无重建授权 → **停止**。
4. `mkdir -p "$HOME/AI_STUDIO_WS"`。

### 2. 读取主题文档

打开 `themes/<theme>.md`，提取并用于后续步骤：

- **config 差异项**（`default_agent`、`browse` 等）
- **Skill 列表**（写入 `skills.json` 的启用项）
- **Command 列表**（从 `context-repo/commands/` 装配）
- **初始目录**（及占位文件）
- **初始化检查项**

### 3. 复制模板

定位 `AI_STUDIO_ROOT`（环境变量 → 用户指定 → 常见本地路径），复制：

```bash
cp -R "$AI_STUDIO_ROOT/workspace_example" "$HOME/AI_STUDIO_WS/<slug>"
```

删除 `.ai_studio/conversations/_example/`、`.ai_studio/tasks/_example/`；移除 `*.example` 配置文件。

### 4. 写入 config.json

基础字段：

```json
{
  "slug": "<slug>",
  "name": "<name>",
  "theme": "<theme>",
  "version": 1,
  "default_agent": "<见 themes/<theme>.md>",
  "browse": { "show_hidden_files": false }
}
```

**browse、default_agent 等覆盖项以 `themes/<theme>.md` 为准。**

### 5. 写入 skills.json

按 `themes/<theme>.md` 的 **Skill 列表** 生成 `enabled` 字段；勿在本 Skill 中硬编码各 theme 的 id。

### 6. 装配 Agent 资源

按 `themes/<theme>.md` 的 **Command 列表**、**Rules**、**Cursor Skill** 章节：

1. Command：从 `context-repo/commands/` 复制或链接到工作空间约定路径
2. Rules：确保 `.cursor/rules/` 存在；合并 `context-repo/rules/` 中主题文档指定的规则
3. Cursor Skill：按主题文档从 `context-repo/skills/` 装配

**Git**（clone / pull / commit / push）不在本 Skill 中执行。

### 7. 创建初始目录

严格按 `themes/<theme>.md` 的 **初始目录** 创建目录与占位文件。

### 8. 校验与报告

1. 对照 `themes/<theme>.md` 的 **初始化检查** 逐项验证。
2. 在 `docs/workspace-init-report.md` 记录：slug、name、theme、路径、已启用 Skill/Command、待办。
3. 向用户汇报路径与下一步建议。

## 约束

- 工作空间根：`$HOME/AI_STUDIO_WS/<slug>/`
- 面向人的说明使用 **中文**
- 不修改平台 `config/themes.yaml`；主题装配以 **本 Skill 目录下 `themes/<theme>.md`** 为执行依据
- 不手工写入 `.ai_studio/tasks/`、`.ai_studio/conversations/` 运行时数据
- 不写入密钥或 Token
