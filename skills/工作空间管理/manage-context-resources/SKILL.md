---
name: manage-context-resources
description: >-
  在 context-repo 中编写、调试、同步 Skill/Command/MCP/SubAgent/Rules/context_actions 等资源，
  并按工作空间 Agent 配置同步到生效目录；支持 Git 提交或恢复远端版本。
  在用户维护 Agent 资源、同步 context-repo、调试 Skill/Command/MCP 或 Browse 上下文动作时使用。
disable-model-invocation: true
---

# Context 资源管理与同步

组织级 Agent 交互资源（Skill、Command、MCP、SubAgent、Rules、context_actions）的**唯一编辑源**是 `context-repo`。  
工作空间内 Agent 实际读取的是**同步后的本地目录**，改 context-repo 不会自动生效。

## context-repo 目录约定

```text
context-repo/
├── context_actions.yaml   # Browse / Portal 上下文动作（v2 schema）
├── skills/                # Cursor / Agent Skill（SKILL.md）
├── rules/                 # Agent Rules
├── commands/              # Command 定义
├── mcps/                  # MCP Server 配置与说明
└── sub_agents/            # SubAgent 角色定义
```

## 输入

| 项 | 必填 | 说明 |
|----|------|------|
| 操作类型 | 是 | `create` / `edit` / `delete` / `sync` / `debug` / `version` |
| 资源类型 | 视操作 | `skill` / `command` / `mcp` / `sub_agent` / `rules` / `context_actions` |
| context-repo 路径 | 否 | 缺省为 `<工作空间根>/context-repo/` |
| 目标 Agent | 否 | 缺省同步配置中全部可用 Agent |

## 第 0 步：确保 context-repo 存在

1. 检查 `<工作空间根>/context-repo/`（或用户指定路径）是否存在且含 `skills/`、`rules/` 等目录。
2. **不存在时**，在工作空间根下克隆：

```bash
git clone https://github.com/dinght-1975/context-repo.git
```

3. 克隆后确认 `git remote -v` 指向 `https://github.com/dinght-1975/context-repo.git`。
4. 已存在但非 git 仓库 → 停止，请用户确认是否重新克隆或指定正确路径。

**所有新建、修改、删除均在 context-repo 内完成**；禁止直接改工作空间 Agent 目录后再反向拷贝（紧急热修须用户明确授权，且事后补回 context-repo）。

## 第 1 步：在 context-repo 中编辑资源

按资源类型进入对应子目录操作：

| 资源类型 | 编辑位置 | 说明 |
|----------|----------|------|
| Skill | `context-repo/skills/` | 每个 Skill 一个子目录，含 `SKILL.md` |
| Rules | `context-repo/rules/` | `.mdc` 或项目约定格式 |
| Command | `context-repo/commands/` | 按主题或模块分子目录 |
| MCP | `context-repo/mcps/` | Server 定义、启用说明 |
| SubAgent | `context-repo/sub_agents/` | 角色 id、职责、约束 |
| context_actions | `context-repo/context_actions.yaml` | Browse 文件/目录 ⋮ 菜单绑定的 Skill 或 Command；同步目标见 `agents/<agent_id>.md` |

**删除**：在 context-repo 中删除文件或目录，再执行同步以移除工作空间副本。

**调试**：在 context-repo 改完后 **必须先 sync**，再在工作空间内触发 Agent 任务验证；未 sync 的改动不会生效。

编辑规范见 [reference/resource-conventions.md](reference/resource-conventions.md)（按需阅读）。

## 第 2 步：发现工作空间 Agent 列表

从**工作空间配置** + **平台 API** 获取当前主机下可用的 Agent，再决定同步目标：

1. 读取 `.ai_studio/config.json`：
   - `slug` — 工作空间 id（可选，用于 workspace 级主题接口）
   - `default_agent` — 实例缺省 Agent
   - `theme` — 主题 id（缺省 `standard`）
2. 调用平台 API 获取该主题的 Agent 列表（**优先于**本地读 `config/themes.yaml`）：

```bash
curl -s "http://localhost:8000/api/v1/themes/{theme_id}"
```

- `{theme_id}` 取上一步 `config.json` 的 `theme`
- **公开接口，无需登录**
- 从响应 `theme.default_agents` 得到当前主机下该主题**可使用的 Agent id 列表**
- 同时读取 `theme.default_agent` 作为主题缺省 Agent

响应字段示例见 [reference/platform-api.md](reference/platform-api.md)。

3. （可选）若 Portal 已登录且需核对实例级配置，可调用：

```bash
curl -s -H "Cookie: <session>" "http://localhost:8000/api/v1/workspaces/{slug}/theme"
```

合并 `default_agent`（工作空间实例）与 `theme.default_agents`（主题允许列表）。

4. API 不可用时：告知用户启动 platform-api（默认 `localhost:8000`），或经用户确认后回退读取本地 `AI_STUDIO/config/themes.yaml`（仅作兜底）。

5. **待同步 Agent 列表** = 步骤 2 的 `theme.default_agents`；确保包含 `config.json` 的 `default_agent`，否则 **停止** 并提示配置不一致。

将列表写入同步报告，供用户确认。

## 第 3 步：同步到工作空间（生效）

对每个待同步 Agent，**读取其映射文档**（不是在本 Skill 主体硬编码路径）：

| Agent id | 同步映射文档 |
|----------|--------------|
| `cursor_cli` | [agents/cursor_cli.md](agents/cursor_cli.md) |

其他 Agent：若 `agents/<agent_id>.md` 不存在 → **停止**，提示补充映射文档后再 sync。

通用同步原则：

1. **源**：`context-repo/<资源目录>/` 或根目录单文件（如 `context_actions.yaml`）
2. **目标**：映射文档中的 Agent context 目录（`cursor_cli` 为 `.cursor/`）
3. **方式**：复制或更新（保留映射文档指定的排除项）；默认不删除工作空间独有文件，**删除**类 sync 须映射文档允许且用户确认
4. 同步 `context_actions` 前，先确认其中引用的 Skill 已同步到同一 Agent 的 skills 目录
5. 同步完成后逐项核对映射文档中的 **生效检查**

未执行本步前，Portal / Agent **不会**加载 context-repo 中的最新内容。

## 第 4 步：版本管理（可选）

在 `context-repo` 目录下操作 Git：

### 提交到远端

```bash
cd context-repo
git status
git add <paths>
git commit -m "<说明>"
git push origin HEAD
```

仅当用户**明确要求提交/推送**时执行；不擅自 push。

### 恢复为服务器版本

用户要求放弃本地修改、与远端一致时：

```bash
cd context-repo
git fetch origin
git status
# 未提交改动：git restore .  或  git checkout -- .
# 已提交但未推送：与用户确认后 git reset --hard origin/<branch>
```

**恢复前必须**展示 `git status` / 将丢失的改动摘要，并获用户确认。禁止在未确认时 `reset --hard`。

## 执行清单

```text
- [ ] 0. context-repo 存在（否则 clone）
- [ ] 1. 在 context-repo 完成 create/edit/delete
- [ ] 2. 读 config.json + 调 GET /api/v1/themes/{theme_id} 得到 default_agents
- [ ] 3. 按 agents/<agent_id>.md 同步到工作空间（含 context_actions.yaml，若存在）
- [ ] 4. 生效检查（映射文档中的检查项；context_actions 须校验 skill id 已在 Agent 目录存在）
- [ ] 5. 调试运行（用户触发 Agent 验证）
- [ ] 6. 版本管理：push 或 restore（用户选择）
```

## 约束

- **context-repo 为源**，工作空间 Agent 目录为**派生副本**
- 不输出密钥、Token、MCP 凭据到日志或报告
- 不修改 `.ai_studio/tasks/`、`.ai_studio/conversations/` 等平台运行时数据（`mcp.json` 等配置除外，且须映射文档允许）
- Git 操作遵循用户仓库规范；不 `--force` push，除非用户明确要求

## 延伸阅读

- 资源编写约定：[reference/resource-conventions.md](reference/resource-conventions.md)
- Agent 同步映射：`agents/<agent_id>.md`
- 平台 API 说明：[reference/platform-api.md](reference/platform-api.md)
