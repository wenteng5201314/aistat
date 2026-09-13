#!/bin/bash

set -u

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PREFIX=''
FORCE=0

usage() {
  cat <<'EOF'
Usage: ./install.sh [--prefix DIR] [--force]

  --prefix DIR  安裝目錄（例如 $HOME/.local/bin）
  --force       覆蓋既有 aistat
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --prefix) [ $# -ge 2 ] || { printf '%s\n' '--prefix 需要目錄' >&2; exit 2; }; PREFIX=$2; shift ;;
    --force) FORCE=1 ;;
    --help|-h) usage; exit 0 ;;
    *) printf '未知參數：%s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

if [ -z "$PREFIX" ]; then
  if [ -d /usr/local/bin ] && [ -w /usr/local/bin ]; then PREFIX=/usr/local/bin
  else PREFIX="$HOME/.local/bin"; fi
fi

mkdir -p "$PREFIX" || { printf '無法建立安裝目錄：%s\n' "$PREFIX" >&2; exit 1; }
TARGET="$PREFIX/aistat"
if [ -e "$TARGET" ] && [ "$FORCE" -ne 1 ]; then
  printf '目標已存在：%s（如要覆蓋，請加 --force）\n' "$TARGET" >&2
  exit 1
fi
install -m 0755 "$SCRIPT_DIR/aistat" "$TARGET"
printf '已安裝：%s\n' "$TARGET"
case ":$PATH:" in *":$PREFIX:"*) ;; *) printf '提醒：%s 尚未在 PATH 中。\n' "$PREFIX" ;; esac
