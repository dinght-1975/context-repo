# 手工统计命令

脚本不可用时，在 macOS / Linux 下等价执行：

```bash
TARGET="<目标目录>"

# 文件数
find "$TARGET" -type f 2>/dev/null | wc -l | tr -d ' '

# 目录数（不含 TARGET 自身）
find "$TARGET" -mindepth 1 -type d 2>/dev/null | wc -l | tr -d ' '

# 总占用
du -sh "$TARGET"

# 最大的 3 个文件（macOS）
find "$TARGET" -type f -exec stat -f '%z %N' {} \; 2>/dev/null \
  | sort -t' ' -k1,1nr | head -3

# 最大的 3 个文件（Linux）
find "$TARGET" -type f -exec stat -c '%s %n' {} \; 2>/dev/null \
  | sort -t' ' -k1,1nr | head -3
```

字节数转人类可读：除以 1024 得 KiB，再除以 1024 得 MiB，以此类推。
