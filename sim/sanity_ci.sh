#!/usr/bin/env bash
set -euo pipefail

# Minimal UART sanity gate:
# 1) ensure VCS toolchain is available
# 2) clean stale outputs
# 3) build
# 4) run default sanity test
# 5) print concise pass/fail summary with log paths

repo_sim_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${repo_sim_dir}"

timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
echo "[sanity-ci] start: ${timestamp}"
echo "[sanity-ci] cwd: ${repo_sim_dir}"

ensure_vcs_ready() {
  if command -v vcs >/dev/null 2>&1; then
    return 0
  fi

  # Try to make "module" command available in non-login shells.
  if ! command -v module >/dev/null 2>&1; then
    if [[ -f /etc/profile.d/modules.sh ]]; then
      # shellcheck disable=SC1091
      source /etc/profile.d/modules.sh
    fi
  fi

  if command -v module >/dev/null 2>&1; then
    set +e
    module load vcs >/dev/null 2>&1
    local rc=$?
    set -e
    if [[ ${rc} -eq 0 ]] && command -v vcs >/dev/null 2>&1; then
      echo "[sanity-ci] loaded vcs module"
      return 0
    fi
  fi

  echo "[sanity-ci] ERROR: vcs not found." >&2
  echo "[sanity-ci] hint: run 'module load vcs' in your shell first." >&2
  return 1
}

ensure_vcs_ready

echo "[sanity-ci] step 1/3: make clean"
make clean

echo "[sanity-ci] step 2/3: make build"
make build

echo "[sanity-ci] step 3/3: make sim TEST=uart_sanity_test"
if make sim TEST=uart_sanity_test; then
  echo "[sanity-ci] PASS"
  echo "[sanity-ci] build log: logs/build.log"
  echo "[sanity-ci] sim log: logs/uart_sanity_test.log"
  exit 0
fi

echo "[sanity-ci] FAIL"
echo "[sanity-ci] inspect: logs/build.log logs/uart_sanity_test.log" >&2
exit 1
