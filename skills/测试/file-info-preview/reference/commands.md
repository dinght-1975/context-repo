# 手工预览命令

脚本不可用时，在 macOS / Linux 下等价执行：

```bash
FILE="<文件路径>"

# 绝对路径（macOS）
realpath "$FILE" 2>/dev/null || python3 -c 'import os,sys; print(os.path.abspath(sys.argv[1]))' "$FILE"

# 大小（macOS）
stat -f '%z' "$FILE"

# 大小（Linux）
stat -c '%s' "$FILE"

# 类型描述
file -b "$FILE"

# MIME 类型
file -b --mime-type "$FILE"
```

字节数转人类可读：除以 1024 得 KiB，再除以 1024 得 MiB，以此类推。
