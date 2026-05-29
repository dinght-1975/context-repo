---
name: file-info-preview
description: >-
  根据指定文件路径预览文件的大小、类型与绝对路径。
  在用户要求查看文件信息、预览文件元数据、确认文件大小或类型时使用。
disable-model-invocation: true
---

# File Info Preview

读取目标文件的元数据，输出大小、类型与路径，不读取文件内容。

## 输入

| 项 | 必填 | 说明 |
|----|------|------|
| 文件路径 `file` | 是 | 用户指定的文件；可为相对或绝对路径 |

## 执行步骤

1. 确认 `file` 已提供；未提供则停止并提示用户。
2. 确认路径存在且为**普通文件**（非目录）；不存在或为目录则停止并说明原因。
3. 运行预览脚本（优先，保证结果一致）：

```bash
bash "<本 Skill 目录>/scripts/preview_file_info.sh" "<file>"
```

`<本 Skill 目录>` 指本文件所在目录（`.../file-info-preview/`）。编辑源在 `context-repo/skills/测试/file-info-preview/`；同步到工作空间后为 `.cursor/skills/file-info-preview/`（**不含** context-repo 的分类子目录）。

4. 脚本不可用时，按 [reference/commands.md](reference/commands.md) 中的等价命令手动执行并汇总。
5. 将脚本输出整理为下方 **报告模板** 呈现给用户；数值须与脚本一致，勿臆造。

## 统计口径

- **路径**：解析为绝对路径（`realpath` 或 `cd` + `pwd` 语义）。
- **大小**：单文件字节数（`stat`）；同时给出人类可读格式（B / KiB / MiB / GiB，1024 进制）。
- **类型**：`file` 命令的简要描述（如 `ASCII text`、`PNG image`）；另附 MIME 类型（如 `text/plain`、`image/png`）。

## 报告模板

```markdown
# File Info Preview

| 项 | 值 |
|----|-----|
| 路径 | `{path}` |
| 大小 | {size_human}（{size_bytes} 字节） |
| 类型 | {file_type} |
| MIME | {mime_type} |
```

若无法解析 MIME（极少数环境），在 MIME 行注明「不可用」，类型行仍须给出 `file` 描述。

## 约束

- 不读取、不展示文件内容。
- 遇权限拒绝时停止并提示「无法访问该文件」，不猜测元数据。
- 符号链接：按链接目标文件统计；若链接断裂则停止并提示。

## 延伸阅读

- 手工命令与平台差异：[reference/commands.md](reference/commands.md)
