# development 主题初始化说明

## 概述

开发实现模式：编码、重构、联调与缺陷修复。

## config.json 差异项

| 字段 | 值 |
|------|-----|
| `theme` | `development` |
| `default_agent` | `cursor_cli` |
| `browse.show_hidden_files` | `false` |

## 初始目录

```text
docs/
src/
tests/          # 可选，建议创建空目录
```

## Skill 列表

| id | 默认启用 |
|----|----------|
| `dev-feature` | true |
| `dev-refactor` | true |
| `dev-bugfix` | false |

## Command 列表

装配自 `context-repo/commands/development/`（若目录不存在则跳过）：

| command id | context-repo 路径 | 默认启用 |
|------------|-------------------|----------|
| （待维护） | `context-repo/commands/development/` | — |

## Rules

- 复制 `workspace_example/.cursor/rules/workspace-conventions.mdc`
- 合并 `context-repo/rules/` 中适用于开发的规则（若有）

## Cursor Skill（可选）

从 `context-repo/skills/代码开发/` 按需装配。

## 初始化检查

- [ ] `default_agent` 为 `cursor_cli`
- [ ] `skills.json` 与上表一致（`dev-bugfix` 为 false 或未启用）
- [ ] `src/` 已创建
- [ ] 测试目录 `tests/` 已创建（若上表要求）
