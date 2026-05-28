# testing 主题初始化说明

## 概述

测试与质量模式：测试设计、用例编写与质量分析。

## config.json 差异项

| 字段 | 值 |
|------|-----|
| `theme` | `testing` |
| `default_agent` | `cursor_cli` |
| `browse.show_hidden_files` | `false` |

## 初始目录

```text
docs/
tests/
reports/        # 可选
```

## Skill 列表

| id | 默认启用 |
|----|----------|
| `test-plan` | true |
| `test-unit` | true |

## Command 列表

装配自 `context-repo/commands/testing/`（若目录不存在则跳过）：

| command id | context-repo 路径 | 默认启用 |
|------------|-------------------|----------|
| （待维护） | `context-repo/commands/testing/` | — |

## Rules

- 复制 `workspace_example/.cursor/rules/workspace-conventions.mdc`
- 合并 `context-repo/rules/` 中适用于测试的规则（若有）

## Cursor Skill（可选）

从 `context-repo/skills/功能测试/` 按需装配。

## 初始化检查

- [ ] `skills.json` 与上表一致
- [ ] `tests/` 已创建
- [ ] 项目测试框架可在后续 Agent 任务中识别（本步仅建目录）
