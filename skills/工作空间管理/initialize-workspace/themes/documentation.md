# documentation 主题初始化说明

## 概述

文档与知识模式：文档编写、审阅、设计文档生成与同步。

## config.json 差异项

| 字段 | 值 |
|------|-----|
| `theme` | `documentation` |
| `default_agent` | `cursor_cli` |
| `browse.show_hidden_files` | `false` |

## 初始目录

```text
docs/
```

占位：`docs/README.md`（文档索引说明）。

## Skill 列表

| id | 默认启用 |
|----|----------|
| `doc-readme` | true |
| `doc-changelog` | true |
| `doc-gen-module-design` | true |
| `doc-sync-module-design` | true |
| `doc-gen-business-design` | true |
| `doc-sync-business-design` | true |
| `doc-review-file` | true |
| `doc-polish-file` | true |

## Command 列表

装配自 `context-repo/commands/documentation/`（若目录不存在则跳过）：

| command id | context-repo 路径 | 默认启用 |
|------------|-------------------|----------|
| （待维护） | `context-repo/commands/documentation/` | — |

## Rules

- 复制 `workspace_example/.cursor/rules/workspace-conventions.mdc`
- 合并 `context-repo/rules/` 中文档类规则（若有）

## Cursor Skill（可选）

从 `context-repo/skills/文档操作/` 按需装配。

## 初始化检查

- [ ] `skills.json` 与上表一致
- [ ] `docs/` 及 `docs/README.md` 已创建
- [ ] Markdown 审阅类 Theme Skill 可在 Portal 启用
