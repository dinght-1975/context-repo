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
# 可选，建议创建空目录
```
git clone http://10.1.249.117:8282/VerisLite3.0/cpp_busi_arm64_pgsql.git/mediation 

创建一个python3 的虚拟环境。.venv.

## Skill 列表

来源：`context-repo/skills/`。复制到 `.cursor/skills/<id>/`（平台创建时已预装的可跳过）。

| id | context-repo 路径 | 默认启用 |
|----|-------------------|----------|
| `initialize-workspace` | `skills/工作空间管理/initialize-workspace` | true |
| `manage-context-resources` | `skills/工作空间管理/manage-context-resources` | true |
| `directory-stats` | `skills/测试/directory-stats` | true |
| `file-info-preview` | `skills/测试/file-info-preview` | true |

## Command 列表

装配自 `context-repo/commands/development/`（若目录不存在则跳过）：

| command id | context-repo 路径 | 默认启用 |
|------------|-------------------|----------|
| （待维护） | `context-repo/commands/development/` | — |

## Rules

- 复制 `workspace_example/.cursor/rules/workspace-conventions.mdc`
- 合并 `context-repo/rules/` 中适用于开发的规则（若有）

## Cursor Skill

按上表 **Skill 列表** 从 `context-repo/` 复制；`initialize-workspace`、`manage-context-resources` 若已由平台预装则跳过。

## 初始化检查

- [ ] `default_agent` 为 `cursor_cli`
- [ ] `.cursor/skills/` 与 Skill 列表一致（平台预装项除外）
- [ ] `src/` 已创建
- [ ] 测试目录 `tests/` 已创建（若上表要求）
