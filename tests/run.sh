#!/bin/bash
set -u

ROOT=$(cd "$(dirname "$0")/.." && pwd)
FIXTURES="$ROOT/tests/fixtures"
PASS=0
FAIL=0

pass() { PASS=$((PASS + 1)); printf 'PASS: %s\n' "$1"; }
fail() { FAIL=$((FAIL + 1)); printf 'FAIL: %s\n' "$1"; }
assert_contains() { case "$1" in *"$2"*) pass "$3" ;; *) fail "$3 (missing: $2)" ;; esac; }
assert_not_contains() { case "$1" in *"$2"*) fail "$3 (unexpected: $2)" ;; *) pass "$3" ;; esac; }

make_fake_bin() {
  FAKE_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/aistat-test.XXXXXX")
  FAKE_BIN="$FAKE_ROOT/bin"
  mkdir -p "$FAKE_BIN"
  cat >"$FAKE_BIN/uname" <<'SH'
#!/bin/bash
case "${1:-}" in -m) echo arm64 ;; *) echo Darwin ;; esac
SH
  cat >"$FAKE_BIN/ollama" <<'SH'
#!/bin/bash
cat "$AISTAT_TEST_FIXTURES/ollama-ps.txt"
SH
  cat >"$FAKE_BIN/vm_stat" <<'SH'
#!/bin/bash
cat "$AISTAT_TEST_FIXTURES/vm_stat.txt"
SH
  cat >"$FAKE_BIN/sysctl" <<'SH'
#!/bin/bash
if [ "${1:-}" = "-n" ] && [ "${2:-}" = "hw.memsize" ]; then echo 38654705664; else echo 'vm.swapusage: total = 8.00G  used = 6.36G  free = 1.64G'; fi
SH
  cat >"$FAKE_BIN/memory_pressure" <<'SH'
#!/bin/bash
if [ -n "${FAKE_FREE_PERCENT:-}" ]; then echo "System-wide memory free percentage: ${FAKE_FREE_PERCENT}%"; else cat "$AISTAT_TEST_FIXTURES/memory_pressure.txt"; fi
SH
  cat >"$FAKE_BIN/docker" <<'SH'
#!/bin/bash
if [ "${FAKE_DOCKER_DOWN:-0}" = 1 ]; then exit 1; fi
case "${1:-}" in info) exit 0 ;; stats) cat "$AISTAT_TEST_FIXTURES/docker-stats.txt" ;; esac
SH
  cat >"$FAKE_BIN/powermetrics" <<'SH'
#!/bin/bash
cat "$AISTAT_TEST_FIXTURES/powermetrics.txt"
SH
  cat >"$FAKE_BIN/sudo" <<'SH'
#!/bin/bash
if [ "${1:-}" = "-n" ] && [ "${2:-}" = "true" ]; then [ "${FAKE_SUDO_OK:-0}" = 1 ]; exit; fi
if [ "${1:-}" = "-n" ]; then shift; fi
exec "$@"
SH
  chmod +x "$FAKE_BIN"/*
}

run_dashboard() {
  env PATH="$FAKE_BIN:/usr/bin:/bin" AISTAT_TEST_FIXTURES="$FIXTURES" NO_COLOR="${NO_COLOR-1}" AISTAT_FORCE_COLOR="${AISTAT_FORCE_COLOR:-0}" FAKE_FREE_PERCENT="${FAKE_FREE_PERCENT:-}" FAKE_DOCKER_DOWN="${FAKE_DOCKER_DOWN:-0}" FAKE_SUDO_OK="${FAKE_SUDO_OK:-0}" "$ROOT/aistat" "$@" 2>&1
}

make_fake_bin
OUT=$(run_dashboard)
assert_contains "$OUT" 'qwen3.6:35b-a3b-coding-nvfp4' '顯示 Ollama 模型'
assert_contains "$OUT" '100% GPU' '顯示 Ollama GPU'
assert_contains "$OUT" '65536' '顯示 Context'
assert_contains "$OUT" '3 minutes from now' '顯示 Until'
assert_contains "$OUT" '36.0 GiB' '顯示總記憶體'
assert_contains "$OUT" 'App        9.00 GiB' 'App 估算不重複計入 inactive 與 compressed'
assert_contains "$OUT" '6.36 GiB' '顯示 Swap'
assert_contains "$OUT" 'ollama-webui' '顯示 Docker 容器'
assert_contains "$OUT" '需要 sudo 權限' 'GPU 無權限時優雅降級'
assert_contains "$OUT" '正常' '顯示正常記憶體壓力'

FAKE_DOCKER_DOWN=1 OUT=$(run_dashboard)
assert_contains "$OUT" 'Docker 引擎未執行' 'Docker 未執行時優雅降級'

FAKE_SUDO_OK=1 OUT=$(run_dashboard)
assert_contains "$OUT" '16.67%' '解析 GPU 使用率'

for CASE in '25 正常 32' '15 注意 33' '5 嚴重 31'; do
  set -- $CASE
  FAKE_FREE_PERCENT=$1 AISTAT_FORCE_COLOR=1 NO_COLOR= OUT=$(run_dashboard)
  assert_contains "$OUT" "$2" "記憶體壓力 $2"
  assert_contains "$OUT" "$(printf '\033[%sm' "$3")" "記憶體壓力 $2 色彩"
done

NO_COLOR=1 AISTAT_FORCE_COLOR=1 OUT=$(run_dashboard)
assert_not_contains "$OUT" "$(printf '\033[')" 'NO_COLOR 停用 ANSI'

if "$ROOT/aistat" --help >/dev/null 2>&1; then pass '--help 成功'; else fail '--help 應成功'; fi
if "$ROOT/aistat" --unknown >/dev/null 2>&1; then fail '未知參數應失敗'; else pass '未知參數失敗'; fi

PREFIX="$FAKE_ROOT/install"
if "$ROOT/install.sh" --prefix "$PREFIX" >/dev/null 2>&1 && "$PREFIX/aistat" --help >/dev/null 2>&1; then pass '安裝後可執行'; else fail '安裝後應可執行'; fi
if "$ROOT/install.sh" --prefix "$PREFIX" >/dev/null 2>&1; then fail '未加 --force 不應覆蓋'; else pass '預設拒絕覆蓋'; fi
if "$ROOT/install.sh" --prefix "$PREFIX" --force >/dev/null 2>&1; then pass '--force 可覆蓋'; else fail '--force 應可覆蓋'; fi

if /bin/bash -n "$ROOT/aistat" "$ROOT/install.sh" "$ROOT/tests/run.sh"; then pass 'Shell 語法正確'; else fail 'Shell 語法錯誤'; fi

rm -rf "$FAKE_ROOT"
printf '\n%d passed, %d failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
