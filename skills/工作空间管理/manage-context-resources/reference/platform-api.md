# 平台 API（Agent / Theme 发现）

平台默认地址：`http://localhost:8000`（platform-api 未启动时，Theme/Agent 发现步骤失败，需提示用户启动服务）。

API 前缀：`/api/v1`

## GET /themes/{theme_id}

获取单个主题定义；**公开接口，无需认证**。

```bash
curl -s "http://localhost:8000/api/v1/themes/standard"
```

响应示例：

```json
{
  "theme": {
    "id": "standard",
    "display_name": "通用研发",
    "tagline": "...",
    "default_models": ["kimi-k2.6"],
    "default_agents": ["cursor_cli"],
    "default_agent": "cursor_cli",
    "capabilities": [],
    "resources": []
  }
}
```

**同步 Agent 资源时使用**：

| 字段 | 用途 |
|------|------|
| `theme.default_agents` | 当前主机下该主题可用的 Agent id 列表（同步目标） |
| `theme.default_agent` | 主题缺省 Agent |
| `theme.default_models` | 主题缺省模型（调试任务时参考） |

`404` 表示 `theme_id` 无效，停止并提示用户修正 `.ai_studio/config.json` 的 `theme`。

## GET /themes

列出全部主题（公开）。

```bash
curl -s "http://localhost:8000/api/v1/themes"
```

## GET /workspaces/{slug}/theme

返回某工作空间的**生效主题 + 实例 default_agent**；需登录（携带 Portal session Cookie）。

```bash
curl -s -H "Cookie: <session>" \
  "http://localhost:8000/api/v1/workspaces/admin-ops/theme"
```

响应含 `workspace`、`theme`（同 `/themes/{id}` 结构）、`default_agent`（实例级，来自 `.ai_studio/config.json`）。

## GET /agents

列出当前主机已注册的 Agent 与模型（公开）。

```bash
curl -s "http://localhost:8000/api/v1/agents"
```

可用于校验 `default_agents` 中的 id 在本机是否真实可用。

## 与本地配置文件的关系

| 来源 | 角色 |
|------|------|
| `GET /api/v1/themes/{theme_id}` | **首选**：反映当前运行中平台配置 |
| `AI_STUDIO/config/themes.yaml` | API 不可用且用户同意时的兜底 |
| `.ai_studio/config.json` | 工作空间实例：slug、name、theme、default_agent |
