# cursor_cli Agent 资源同步映射

Agent id：`cursor_cli`  
适用：AI_STUDIO 平台 `config/ai_studio.yaml` 中 `type: cli`、`binary: cursor` 的 Cursor CLI Agent。

## 生效前提

- 工作空间 `.ai_studio/config.json` 的 `default_agent` 为 `cursor_cli`，或
- `cursor_cli` 出现在 `GET /api/v1/themes/{theme_id}` 返回的 `theme.default_agents` 中（`theme_id` 取自 `config.json` 的 `theme`）

## 同步映射

| context-repo 源 | 工作空间目标 | 说明 |
|-----------------|--------------|------|
| `skills/` | `.cursor/skills/` | 每个 Skill 一个子目录，含 `SKILL.md`；Cursor CLI **不支持**分类嵌套，须将 `skills/<分类>/<skill-name>/` **平铺**为 `.cursor/skills/<skill-name>/` |
| `rules/` | `.cursor/rules/` | Rules 文件（如 `*.mdc`） |
| `commands/` | `.cursor/commands/` | 自定义 Command（目录不存在则创建） |
| `mcps/` | `.cursor/` + `.ai_studio/mcp.json` | MCP Server 配置：物化到 Cursor 可读的 MCP 配置；启用列表写入 `.ai_studio/mcp.json`（见 mcps/ 内各 Server 说明） |
| `sub_agents/` | `.cursor/agents/` | SubAgent 定义（目录不存在则创建；格式见 sub_agents/ 内 README 或示例） |
| `context_actions.yaml` | `.cursor/context_actions.yaml` | Browse / Portal 上下文动作；**优先于**平台 `config/context_actions.yaml`；亦支持 `context_actions.json` |

平台通过 `agent_context_actions_path(ws, agent_id)` 解析路径；当前 MVP 仅 `cursor_cli` → `.cursor/`。

## 推荐同步命令（示例）

在工作空间根 `<WS_ROOT>` 执行（路径按实际调整）：

```bash
CONTEXT=./context-repo
WS=<WS_ROOT>

# skills：平铺到 .cursor/skills/<skill-name>/（跳过 context-repo 的 <分类>/ 层级）
while IFS= read -r skill_dir; do
  name="$(basename "$skill_dir")"
  rsync -a "$skill_dir/" "$WS/.cursor/skills/$name/"
done < <(find "$CONTEXT/skills" -mindepth 2 -maxdepth 2 -type f -name SKILL.md -exec dirname {} \;)

# context_actions：工作空间级 Browse 动作绑定
if [[ -f "$CONTEXT/context_actions.yaml" ]]; then
  cp "$CONTEXT/context_actions.yaml" "$WS/.cursor/context_actions.yaml"
elif [[ -f "$CONTEXT/context_actions.json" ]]; then
  cp "$CONTEXT/context_actions.json" "$WS/.cursor/context_actions.json"
fi

rsync -a --delete "$CONTEXT/rules/" "$WS/.cursor/rules/"
rsync -a "$CONTEXT/commands/" "$WS/.cursor/commands/"    # 若 commands 源存在
rsync -a "$CONTEXT/sub_agents/" "$WS/.cursor/agents/"     # 若 sub_agents 源存在
# mcps：按 mcps/ 下各文件说明合并到 .cursor/mcp.json 与 .ai_studio/mcp.json
```

使用 `rsync --delete` 前须用户确认，避免误删工作空间独有文件。

**单资源增量 sync** 示例：

```bash
# 仅同步 context_actions
cp "$CONTEXT/context_actions.yaml" "$WS/.cursor/context_actions.yaml"

# 仅同步单个 Skill（平铺，不带 context-repo 分类目录）
rsync -a "$CONTEXT/skills/测试/directory-stats/" "$WS/.cursor/skills/directory-stats/"
```

## 排除项（勿覆盖）

- `.cursor/skills/README.md` 等工作空间本地说明（若存在且不在 context-repo 中）
- 用户明确标记为「仅本地」的文件

## 生效检查

- [ ] `.cursor/skills/<skill-name>/SKILL.md` 与 context-repo 一致
- [ ] `.cursor/rules/` 含预期 Rules
- [ ] 修改的 Command / MCP / SubAgent 在对应目标路径存在
- [ ] `.cursor/context_actions.yaml` 与 context-repo 一致（若已配置）
- [ ] `context_actions` 中引用的 `skill_id` / `id` 在 `.cursor/skills/<skill-name>/` 已存在且已同步
- [ ] Portal Browse 文件/目录行 ⋮ 菜单出现预期动作（可 `GET .../browse` 核对 `actions` 字段）
- [ ] Portal 或 Cursor CLI 重新加载工作空间后可发现新 Skill（必要时重启 Agent 会话）
- [ ] 试跑一条依赖新资源的 Agent 任务，确认行为符合预期

## 调试建议

1. 单资源增量 sync，再运行最小验证任务
2. 失败时对比 context-repo 源文件与工作空间目标文件 diff
3. MCP 问题先查 `.ai_studio/mcp.json` 启用 id 是否与 `mcps/` 定义一致
