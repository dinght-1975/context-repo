#!/usr/bin/env bash
# 预览文件：绝对路径、大小、类型、MIME
set -euo pipefail

input="${1:-}"
if [[ -z "$input" ]]; then
  echo "ERROR: 请指定文件路径" >&2
  exit 1
fi

resolve_path() {
  local p="$1"
  if [[ -L "$p" ]]; then
    local target
    target="$(readlink "$p" 2>/dev/null || true)"
    if [[ -z "$target" ]]; then
      echo "ERROR: 无法解析符号链接: $p" >&2
      exit 1
    fi
    if [[ "$target" != /* ]]; then
      target="$(cd "$(dirname "$p")" && pwd)/$target"
    fi
    p="$target"
  fi
  if [[ ! -e "$p" ]]; then
    echo "ERROR: 文件不存在: ${1}" >&2
    exit 1
  fi
  if [[ -d "$p" ]]; then
    echo "ERROR: 目标是目录而非文件: ${1}" >&2
    exit 1
  fi
  if [[ ! -f "$p" ]]; then
    echo "ERROR: 不是普通文件: ${1}" >&2
    exit 1
  fi
  if [[ "$p" != /* ]]; then
    p="$(cd "$(dirname "$p")" && pwd)/$(basename "$p")"
  fi
  printf '%s' "$p"
}

human_size() {
  local bytes="$1"
  if (( bytes >= 1073741824 )); then
    awk -v b="$bytes" 'BEGIN { printf "%.2f GiB", b/1073741824 }'
  elif (( bytes >= 1048576 )); then
    awk -v b="$bytes" 'BEGIN { printf "%.2f MiB", b/1048576 }'
  elif (( bytes >= 1024 )); then
    awk -v b="$bytes" 'BEGIN { printf "%.2f KiB", b/1024 }'
  else
    echo "${bytes} B"
  fi
}

file_path="$(resolve_path "$input")"

size_bytes=""
if size_bytes="$(stat -f '%z' "$file_path" 2>/dev/null)"; then
  :
elif size_bytes="$(stat -c '%s' "$file_path" 2>/dev/null)"; then
  :
else
  echo "ERROR: 无法读取文件大小: $file_path" >&2
  exit 1
fi

file_type="$(file -b "$file_path" 2>/dev/null || echo "未知")"
mime_type="$(file -b --mime-type "$file_path" 2>/dev/null || echo "")"

echo "PATH=$file_path"
echo "SIZE_BYTES=$size_bytes"
echo "SIZE_HUMAN=$(human_size "$size_bytes")"
echo "FILE_TYPE=$file_type"
echo "MIME_TYPE=$mime_type"
