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

## SubAgent（`sub_agents/`）

建议每个角色一个定义文件，包含：

- `subagent_id`、职责、允许工具/路径
- 与 Skill 的分工说明（Skill = 怎么做，SubAgent = 谁来做）

## 版本管理

- 每次可发布变更在 context-repo 内 `git commit`
- commit message 说明资源类型与 id，便于审计与回滚
