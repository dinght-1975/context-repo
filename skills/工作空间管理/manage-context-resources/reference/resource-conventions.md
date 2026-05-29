# Context 资源编写约定

供 `manage-context-resources` Skill 在 create/edit 时参考。

## 通用原则

- 面向 Agent 的说明优先 **中文**（与组织规范一致）
- 单文件 Skill 主体建议 **500 行以内**；细节放 `reference.md` / `agents/*.md`
- 不在资源文件中硬编码密钥；凭据用环境变量或平台密钥管理

## Skill（`skills/`）

```text
skills/<分类>/<skill-name>/SKILL.md
```

- 必须含 YAML frontmatter：`name`、`description`
- `name`：小写字母、数字、连字符，≤64 字符
- `description`：第三人称，说明 **做什么** 与 **何时使用**

## Rules（`rules/`）

- 使用 `.mdc`，含 frontmatter（如 `description`、`alwaysApply`）
- 一条 Rule 聚焦一类约束，避免重复 Skill 中的流程说明

## Command（`commands/`）

建议结构：

```text
commands/<theme-or-module>/<command-id>.md
```

记录：command id、说明、参数、底层实现（shell / 转调 Skill）、权限与审计要点。

## MCP（`mcps/`）

建议每个 Server 一个子目录或单文件，包含：

- Server id、显示名、传输方式
- 工具清单与风险等级
- 同步到 `.ai_studio/mcp.json` 的 `enabled` 字段说明
- 凭据来源（勿写明文 secret）

## context_actions（`context_actions.yaml`）

工作空间级 Browse / Portal **上下文动作**配置，覆盖平台默认 `config/context_actions.yaml`。

- **编辑位置**：`context-repo/context_actions.yaml`（根目录单文件；亦可用 `.json`）
- **同步目标**：见 `agents/<agent_id>.md`（`cursor_cli` → `.cursor/context_actions.yaml`）
- **schema**：`version: 2`，按 `themes.<theme_id>.files|directories` 分组
- **skill 引用**：`skills[].id`（或 `skill_id`）须与 `.cursor/skills/<skill-name>/` 目录名一致，且该 Skill 已同步
- **文件匹配**：`files[].suffix` 或 `suffixes`（如 `.md`、`.py`）
- **目录匹配**：`directories[]` 直接列出目录级 Skill 动作（如 documentation 主题）

示例：

```yaml
version: 2
themes:
  admin:
    directories:
      - id: directory-stats
        label: 目录统计
```

编辑后须 **sync** 到 Agent context 目录；仅改 context-repo 不会在 Portal 生效。

## SubAgent（`sub_agents/`）

建议每个角色一个定义文件，包含：

- `subagent_id`、职责、允许工具/路径
- 与 Skill 的分工说明（Skill = 怎么做，SubAgent = 谁来做）

## 版本管理

- 每次可发布变更在 context-repo 内 `git commit`
- commit message 说明资源类型与 id，便于审计与回滚
