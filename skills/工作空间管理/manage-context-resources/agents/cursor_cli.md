# cursor_cli Agent 资源同步映射

Agent id：`cursor_cli`  
适用：AI_STUDIO 平台 `config/ai_studio.yaml` 中 `type: cli`、`binary: cursor` 的 Cursor CLI Agent。

## 生效前提

- 工作空间 `.ai_studio/config.json` 的 `default_agent` 为 `cursor_cli`，或
- 该 Agent 出现在当前 `theme` 的 `default_agents` 列表中

## 同步映射

| context-repo 源 | 工作空间目标 | 说明 |
|-----------------|--------------|------|
| `skills/` | `.cursor/skills/` | 每个子目录含 `SKILL.md`；Cursor CLI 按目录发现 Skill |
| `rules/` | `.cursor/rules/` | Rules 文件（如 `*.mdc`） |
| `commands/` | `.cursor/commands/` | 自定义 Command（目录不存在则创建） |
| `mcps/` | `.cursor/` + `.ai_studio/mcp.json` | MCP Server 配置：物化到 Cursor 可读的 MCP 配置；启用列表写入 `.ai_studio/mcp.json`（见 mcps/ 内各 Server 说明） |
| `sub_agents/` | `.cursor/agents/` | SubAgent 定义（目录不存在则创建；格式见 sub_agents/ 内 README 或示例） |

## 推荐同步命令（示例）

在工作空间根 `<WS_ROOT>` 执行（路径按实际调整）：

```bash
CONTEXT=./context-repo
WS=<WS_ROOT>

rsync -a --delete "$CONTEXT/skills/" "$WS/.cursor/skills/"
rsync -a --delete "$CONTEXT/rules/" "$WS/.cursor/rules/"
rsync -a "$CONTEXT/commands/" "$WS/.cursor/commands/"    # 若 commands 源存在
rsync -a "$CONTEXT/sub_agents/" "$WS/.cursor/agents/"     # 若 sub_agents 源存在
# mcps：按 mcps/ 下各文件说明合并到 .cursor/mcp.json 与 .ai_studio/mcp.json
```

使用 `rsync --delete` 前须用户确认，避免误删工作空间独有文件。若用户仅同步单个 Skill，改为复制对应子目录即可。

## 排除项（勿覆盖）

- `.cursor/skills/README.md` 等工作空间本地说明（若存在且不在 context-repo 中）
- 用户明确标记为「仅本地」的文件

## 生效检查

- [ ] `.cursor/skills/<skill-name>/SKILL.md` 与 context-repo 一致
- [ ] `.cursor/rules/` 含预期 Rules
- [ ] 修改的 Command / MCP / SubAgent 在对应目标路径存在
- [ ] Portal 或 Cursor CLI 重新加载工作空间后可发现新 Skill（必要时重启 Agent 会话）
- [ ] 试跑一条依赖新资源的 Agent 任务，确认行为符合预期

## 调试建议

1. 单资源增量 sync，再运行最小验证任务
2. 失败时对比 context-repo 源文件与工作空间目标文件 diff
3. MCP 问题先查 `.ai_studio/mcp.json` 启用 id 是否与 `mcps/` 定义一致
