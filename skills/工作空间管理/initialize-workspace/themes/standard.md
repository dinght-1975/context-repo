# standard 主题初始化说明

## 概述

通用研发模式：文件浏览、Git、任务与对话均衡协作。

## config.json 差异项

| 字段 | 值 |
|------|-----|
| `theme` | `standard` |
| `default_agent` | `cursor_cli` |
| `browse.show_hidden_files` | `false` |

## 初始目录

```text
docs/
src/
```

可选占位：`docs/README.md`（工作空间说明）。

## Skill 列表

写入 `.ai_studio/skills.json` 的 `enabled`：

| id | 默认启用 |
|----|----------|
| `std-code-review` | true |
| `std-onboard` | true |
| `std-file-review` | true |

## Command 列表

装配自 `context-repo/commands/standard/`（若目录不存在则跳过）：

| command id | context-repo 路径 | 默认启用 |
|------------|-------------------|----------|
| （待维护） | `context-repo/commands/standard/` | — |

## Rules

- 复制 `workspace_example/.cursor/rules/workspace-conventions.mdc`
- 合并 `context-repo/rules/` 中标记适用于 `standard` 的规则（若有）

## Cursor Skill（可选）

从 `context-repo/skills/` 按团队规范选配；默认不批量复制。

## 初始化检查

- [ ] `config.json` 的 `slug` 与目录名一致
- [ ] `skills.json` 与上表默认启用项一致
- [ ] `docs/`、`src/` 已创建
- [ ] `.cursor/rules/` 非空
- [ ] 可运行 Theme Skill `std-onboard` 做导览验证
