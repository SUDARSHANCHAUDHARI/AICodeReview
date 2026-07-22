#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
pass_count=0
fail_count=0

pass() { echo "  PASS  $*"; pass_count=$((pass_count + 1)); }
fail() { echo "  FAIL  $*"; fail_count=$((fail_count + 1)); }

echo "── test-validate.sh ────────────────────────────────────"

if "$ROOT_DIR/scripts/validate.sh" >/dev/null; then
  pass "validation succeeds on the source tree"
else
  fail "validation fails on the source tree"
fi

for script in aicodereview-lib.sh install.sh uninstall.sh update.sh list-installed.sh check-health.sh scripts/validate.sh tests/run-all.sh; do
  if [[ -f "$ROOT_DIR/$script" ]] && bash -n "$ROOT_DIR/$script"; then
    pass "$script exists and parses"
  else
    fail "$script is missing or has shell syntax errors"
  fi
done

skill_count="$(find "$ROOT_DIR/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
temp_home="$(mktemp -d "${TMPDIR:-/tmp}/aicodereview-list-test.XXXXXX")"
trap 'rm -rf "$temp_home"' EXIT
listed_count="$(HOME="$temp_home" "$ROOT_DIR/list-installed.sh" | awk '$1 == "claude" { count++ } END { print count + 0 }')"
if [[ "$listed_count" -eq "$skill_count" ]]; then
  pass "list-installed derives the complete skill inventory dynamically"
else
  fail "list-installed reported $listed_count Claude skills; expected $skill_count"
fi

for script in install.sh uninstall.sh check-health.sh list-installed.sh; do
  if grep -q 'load_skills' "$ROOT_DIR/$script"; then
    pass "$script uses the shared dynamic inventory"
  else
    fail "$script does not use the shared dynamic inventory"
  fi
done

echo ""
echo "test-validate.sh: $pass_count passed, $fail_count failed"
[[ "$fail_count" -eq 0 ]]
