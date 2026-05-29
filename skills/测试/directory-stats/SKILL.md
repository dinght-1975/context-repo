---
name: directory-stats
description: >-
  收集指定目录下的文件与目录数量、总占用空间，并列出最大的 3 个文件。
  在用户要求统计目录信息、查看目录大小、分析磁盘占用或找出大文件时使用。
disable-model-invocation: true
---

# 统计目录信息

扫描目标目录，汇总文件系统占用并输出结构化报告。

## 输入

| 项 | 必填 | 说明 |
|----|------|------|
| 目标目录 `target` | 否 | 缺省为当前工作空间根目录；用户指定路径时使用绝对路径 |

## 执行步骤

1. 确认 `target` 存在且为目录；不存在则停止并提示用户。
2. 运行统计脚本（优先，保证结果一致）：

```bash
bash "<本 Skill 目录>/scripts/stat_directory.sh" "<target>"
```

`<本 Skill 目录>` 指本文件所在目录（`.../directory-stats/`）。编辑源在 `context-repo/skills/测试/directory-stats/`；同步到工作空间后为 `.cursor/skills/directory-stats/`（**不含** context-repo 的分类子目录）。

3. 脚本不可用时，按 [reference/commands.md](reference/commands.md) 中的等价命令手动执行并汇总。
4. 将脚本输出整理为下方 **报告模板** 呈现给用户；数值须与脚本一致，勿臆造。

## 统计口径

- **文件数**：`target` 下所有普通文件（`-type f`），含子目录，不含符号链接指向的外部对象。
- **目录数**：`target` 下所有子目录（`-type d`），**不含** `target` 自身。
- **总占用**：`target` 目录树磁盘占用（`du -sh` 语义，块大小对齐）。
- **最大文件**：按单文件字节数降序，取前 3 个；并列时按路径字典序。

## 报告模板

```markdown
# 目录统计：{target}

## 概览

| 指标 | 数值 |
|------|------|
| 文件数 | {file_count} |
| 目录数 | {dir_count} |
| 总占用 | {total_size_human} |

## 最大的 3 个文件

| 排名 | 大小 | 路径 |
|------|------|------|
| 1 | {size_1} | `{path_1}` |
| 2 | {size_2} | `{path_2}` |
| 3 | {size_3} | `{path_3}` |
```

若文件不足 3 个，只列出实际存在的行，并在概览下注明「仅 {n} 个文件」。

## 约束

- 不读取文件内容；仅统计元数据与大小。
- 遇权限拒绝时跳过该路径并在报告末尾列出「无法访问的路径」摘要，不中断整体统计。
- 不对 `.git`、`.ai_studio` 等目录做特殊排除，除非用户明确要求。

## 延伸阅读

- 手工命令与平台差异：[reference/commands.md](reference/commands.md)
