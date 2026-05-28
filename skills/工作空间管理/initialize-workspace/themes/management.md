# management 主题初始化说明

## 概述

规划与管理模式：需求拆解、进度跟踪与协作汇总。

## config.json 差异项

| 字段 | 值 |
|------|-----|
| `theme` | `management` |
| `default_agent` | `cursor_cli` |
| `browse.show_hidden_files` | `false` |

## 初始目录

```text
plans/
notes/
docs/           # 可选，存放纪要导出
```

## Skill 列表

| id | 默认启用 |
|----|----------|
| `mgmt-breakdown` | true |
| `mgmt-status` | true |

## Command 列表

装配自 `context-repo/commands/management/`（若目录不存在则跳过）：

| command id | context-repo 路径 | 默认启用 |
|------------|-------------------|----------|
| （待维护） | `context-repo/commands/management/` | — |

## Rules

- 复制 `workspace_example/.cursor/rules/workspace-conventions.mdc`
- 合并 `context-repo/rules/` 中管理类规则（若有）

## Cursor Skill（可选）

从 `context-repo/skills/工作空间管理/` 按需装配（勿包含本初始化 Skill 自身循环复制）。

## 初始化检查

- [ ] `skills.json` 与上表一致
- [ ] `plans/`、`notes/` 已创建
- [ ] Portal 任务中心与对话入口可用（依赖平台 theme 资源）
