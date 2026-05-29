#!/usr/bin/env bash
# 统计目录：文件数、目录数、总占用、最大的 3 个文件
set -euo pipefail

target="${1:-.}"
target="$(cd "$target" 2>/dev/null && pwd)" || {
  echo "ERROR: 目录不存在或无法访问: ${1:-.}" >&2
  exit 1
}

file_count=0
dir_count=0
declare -a denied=()

while IFS= read -r -d '' path; do
  file_count=$((file_count + 1))
done < <(find "$target" -type f -print0 2>/dev/null || true)

while IFS= read -r -d '' path; do
  if [[ "$path" != "$target" ]]; then
    dir_count=$((dir_count + 1))
  fi
done < <(find "$target" -type d -print0 2>/dev/null || true)

while IFS= read -r line; do
  [[ -n "$line" ]] && denied+=("$line")
done < <(find "$target" \( -type f -o -type d \) ! -readable -print 2>/dev/null || true)

total_size_human="$(du -sh "$target" 2>/dev/null | awk '{print $1}')"
total_size_bytes="$(du -sk "$target" 2>/dev/null | awk '{print $1 * 1024}')"

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

echo "TARGET=$target"
echo "FILE_COUNT=$file_count"
echo "DIR_COUNT=$dir_count"
echo "TOTAL_SIZE_HUMAN=$total_size_human"
echo "TOTAL_SIZE_BYTES=$total_size_bytes"
echo "---TOP_FILES---"

rank=0
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  rank=$((rank + 1))
  size="${line%% *}"
  path="${line#* }"
  echo "${rank}|$(human_size "$size")|${path}"
  [[ "$rank" -ge 3 ]] && break
done < <(
  find "$target" -type f -print0 2>/dev/null \
    | while IFS= read -r -d '' f; do
        if stat_out="$(stat -f '%z %N' "$f" 2>/dev/null)"; then
          echo "$stat_out"
        elif stat_out="$(stat -c '%s %n' "$f" 2>/dev/null)"; then
          echo "$stat_out"
        fi
      done \
    | sort -t' ' -k1,1nr \
    | head -3
)

if ((${#denied[@]} > 0)); then
  echo "---DENIED---"
  printf '%s\n' "${denied[@]}"
fi
