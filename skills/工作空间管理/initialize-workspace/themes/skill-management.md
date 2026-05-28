# skill 主题初始化说明（theme id: `skill`）

## 概述

Skill 管理模式：Skill 草案编写、合格性评审与版本治理。

## config.json 差异项

| 字段 | 值 |
|------|-----|
| `theme` | `skill` |
| `default_agent` | `cursor_cli` |
| `browse.show_hidden_files` | `false` |

## 初始目录

```text
docs/
skills/         # 本地 Skill 草案目录
reviews/        # 评审记录
```

## Skill 列表

| id | 默认启用 |
|----|----------|
| `skill-author` | true |
| `skill-review` | true |

## Command 列表

装配自 `context-repo/commands/skill/`（若目录不存在则跳过）：

| command id | context-repo 路径 | 默认启用 |
|------------|-------------------|----------|
| （待维护） | `context-repo/commands/skill/` | — |

## Rules

- 复制 `workspace_example/.cursor/rules/workspace-conventions.mdc`
- 合并 `context-repo/rules/` 中 Skill 编写规范（若有）

## Cursor Skill（可选）

链接或复制 `context-repo/skills/` 结构作为参考；工作空间内 `skills/` 用于试写草案。

## 初始化检查

- [ ] `skills.json` 与上表一致
- [ ] 工作空间内 `skills/`、`reviews/` 已创建
- [ ] Theme Skill 试跑入口可用
