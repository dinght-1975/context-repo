# admin 主题初始化说明

## 概述

系统管理模式：工作空间配置巡检、平台对照与任务异常排查。

## config.json 差异项

| 字段 | 值 |
|------|-----|
| `theme` | `admin` |
| `default_agent` | `cursor_cli` |
| `browse.show_hidden_files` | `true` |

## 初始目录

```text
docs/
ops/            # 运维脚本与巡检记录
src/            # 可选，管理工具源码
```

## Skill 列表

| id | 默认启用 |
|----|----------|
| `admin-ws-checklist` | true |
| `admin-config-review` | true |
| `admin-task-triage` | true |

## Command 列表

装配自 `context-repo/commands/admin/`（若目录不存在则跳过）：

| command id | context-repo 路径 | 默认启用 |
|------------|-------------------|----------|
| （待维护） | `context-repo/commands/admin/` | — |

## Rules

- 复制 `workspace_example/.cursor/rules/workspace-conventions.mdc`
- 合并 `context-repo/rules/` 中运维/管理类规则（若有）

## Cursor Skill（可选）

从 `context-repo/skills/工作空间管理/` 按需装配。

## 初始化检查

- [ ] `browse.show_hidden_files` 为 `true`
- [ ] `skills.json` 与上表一致
- [ ] 可对照 `admin-ws-checklist` 做开通自检
- [ ] `config.json` 字段完整：slug、name、theme、default_agent、browse
