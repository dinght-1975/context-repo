---
name: hermes-gateway
description: >-
  管理当前 AI_STUDIO 工作空间的 Hermes API gateway：启动、停止、重启、状态检查与健康测试。
  与 platform-api hermes_gateway 模块一致（工作空间 .hermes profile、TERMINAL_CWD 指向工作区根）。
  在用户调试 hermes_api、gateway 未就绪、或需手动运维 gateway 时使用。
disable-model-invocation: true
---

# Hermes Gateway 运维（工作空间 profile）

每个 AI_STUDIO 工作空间拥有**独立** Hermes profile，不在 OS 用户 `~/.hermes/profiles/ai-studio` 集中运行。

| 路径 | 用途 |
|------|------|
| `<工作空间根>/` | **项目 cwd**（`TERMINAL_CWD`、`terminal.cwd`） |
| `<工作空间根>/.hermes/` | **HERMES_HOME**（Agent 配置，不是项目根） |
| `.hermes/gateway.json` | API 端口、Bearer key（platform 写入） |
| `.hermes/.env` | `API_SERVER_*`、`TERMINAL_CWD` |
| `.hermes/config.yaml` | Hermes 配置（含 `terminal.cwd`） |
| `.hermes/gateway.log` | `gateway run` 前台 fallback 日志 |
| `.hermes/skills/` | Hermes Agent Skill |

platform-api 首次使用 `hermes_api` 时会自动：创建 `.hermes/`、provision 端口与 key、启动 gateway。本 Skill 用于**手动**运维与排障。

## 输入

| 项 | 必填 | 说明 |
|----|------|------|
| 操作 | 是 | `status` / `start` / `stop` / `restart` / `test` |
| 工作空间根 | 否 | 缺省为当前 cwd（须在 `~/AI_STUDIO_WS/<slug>/` 内） |

## 第 0 步：确认工作空间

1. 解析工作空间根目录 `WS`（用户指定或 `pwd`，须含 `.ai_studio/config.json` 或用户明确指认）。
2. **禁止**把 `WS/.hermes` 当作项目根目录回答用户。
3. 确认本机已安装 `hermes` CLI（`which hermes`）。

## 第 1 步：执行运维脚本（推荐）

脚本与 `AI_STUDIO/apps/platform-api/.../hermes_gateway.py` 行为对齐：

```bash
cd "<WS>"
bash context-repo/skills/工作空间管理/hermes-gateway/scripts/hermes_gateway_ops.sh <status|start|stop|restart|test>
```

若 Skill 已同步到工作空间：

```bash
cd "<WS>"
bash .hermes/skills/hermes-gateway/scripts/hermes_gateway_ops.sh status
```

### 子命令说明

| 命令 | 行为 |
|------|------|
| `status` | `hermes gateway status` + 读取 `gateway.json` + `GET /health` |
| `start` | `gateway start`；未就绪则 fallback `gateway run --accept-hooks`（写 `gateway.log`） |
| `stop` | `hermes gateway stop` |
| `restart` | `stop` → 等待 → `start` |
| `test` | `status` 通过后 `POST /v1/chat/completions` 最小请求 |

环境变量（脚本自动设置，与 platform 一致）：

```bash
export HOME="$USER_HOME"          # OS 用户 HOME
export HERMES_HOME="$WS/.hermes"
export TERMINAL_CWD="$WS"
export HERMES_ACCEPT_HOOKS=1
```

## 第 2 步：无 gateway.json 时

若 `.hermes/gateway.json` 不存在：

1. 说明尚未 provision（首次在 Portal 用 `hermes_api` 发消息会自动创建）。
2. 可手动初始化布局：

```bash
mkdir -p "$WS/.hermes/skills"
```

3. **不要**自行编造 `api_key` 写入生产配置；需要 provision 时让用户通过 Portal 触发一次 `hermes_api`，或联系平台管理员。

## 第 3 步：手工命令（脚本不可用时）

在工作空间根目录 `WS` 下：

```bash
WS="/path/to/~/AI_STUDIO_WS/<slug>"
cd "$WS"
export HOME="$HOME"
export HERMES_HOME="$WS/.hermes"
export TERMINAL_CWD="$WS"
export HERMES_ACCEPT_HOOKS=1

# 状态
hermes gateway status

# 启动（与 platform 相同顺序）
hermes gateway start
sleep 1
# 若仍未就绪：hermes gateway run --accept-hooks >> .hermes/gateway.log 2>&1 &

# 停止
hermes gateway stop

# 健康检查（从 gateway.json 读取 port/key）
PORT=$(python3 -c "import json;print(json.load(open('.hermes/gateway.json'))['api_port'])")
KEY=$(python3 -c "import json;print(json.load(open('.hermes/gateway.json'))['api_key'])")
curl -s -H "Authorization: Bearer $KEY" "http://127.0.0.1:$PORT/health"
```

## 排障清单

```text
- [ ] WS 是工作空间根（含 .ai_studio/），不是 .hermes/
- [ ] .hermes/gateway.json 存在且 api_port/api_key 非空
- [ ] .hermes/.env 含 API_SERVER_ENABLED=true、API_SERVER_PORT、API_SERVER_KEY
- [ ] .hermes/config.yaml 中 terminal.cwd 等于 WS 绝对路径
- [ ] hermes gateway status 为 running
- [ ] GET /health 返回 200
- [ ] 失败时查看 .hermes/gateway.log
- [ ] platform-api 未设 AI_STUDIO_SKIP_HERMES_GATEWAY_ENSURE=1（测试环境除外）
```

## 约束

- **每个工作空间**独立 gateway 端口；勿用其他工作空间的 `gateway.json`。
- 不输出完整 `api_key` 到用户可见报告（可显示前 8 字符 + `…`）。
- 不修改 `~/.ai_studio/` 下已废弃的 per-user gateway 配置。
- `hermes_api` 对话走 `POST /v1/responses`；测试可用 `/health` 与 `/v1/chat/completions`。

## 安装到工作空间

将本 Skill 同步到 Hermes skills 目录（与 `manage-context-resources` 流程一致）：

```text
context-repo/skills/工作空间管理/hermes-gateway/
  → <WS>/.hermes/skills/hermes-gateway/
```

## 延伸阅读

- 平台实现：`AI_STUDIO/apps/platform-api/src/platform_api/services/hermes_gateway.py`
- API 客户端：`AI_STUDIO/apps/platform-api/src/platform_api/services/hermes_api_client.py`
- 设计说明：`AI_STUDIO/docs/api-spec.md`（hermes_api / gateway 小节）
