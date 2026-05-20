#!/usr/bin/env bash
set -euo pipefail

# tests/test-install.sh — install.sh behaviour tests (pure bash, no external deps)

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

pass_count=0
fail_count=0

assert_exit_code() {
  local expected="$1"
  local description="$2"
  shift 2
  local actual

  set +e
  "$@"
  actual=$?
  set -e

  if [[ "$actual" -eq "$expected" ]]; then
    echo "  PASS  $description (exit $actual)"
    pass_count=$((pass_count + 1))
  else
    echo "  FAIL  $description (expected exit $expected, got $actual)"
    fail_count=$((fail_count + 1))
  fi
}

assert_output_contains() {
  local expected_pattern="$1"
  local description="$2"
  shift 2
  local output

  set +e
  output=$("$@" 2>&1)
  set -e

  if echo "$output" | grep -qF -- "$expected_pattern"; then
    echo "  PASS  $description"
    pass_count=$((pass_count + 1))
  else
    echo "  FAIL  $description (pattern '$expected_pattern' not found in output)"
    echo "        Output was: $output"
    fail_count=$((fail_count + 1))
  fi
}

echo "── test-install.sh ─────────────────────────────────────"

# 1. --dry-run exits 0 (default agent = global)
assert_exit_code 0 \
  "--dry-run exits 0 (default agent)" \
  "$ROOT_DIR/install.sh" --dry-run

# 2. --agent claude --dry-run exits 0
assert_exit_code 0 \
  "--agent claude --dry-run exits 0" \
  "$ROOT_DIR/install.sh" --agent claude --dry-run

# 3. --agent codex --dry-run exits 0
assert_exit_code 0 \
  "--agent codex --dry-run exits 0" \
  "$ROOT_DIR/install.sh" --agent codex --dry-run

# 4. --agent all without --project exits non-zero
assert_exit_code 1 \
  "--agent all without --project exits non-zero" \
  "$ROOT_DIR/install.sh" --agent all --dry-run

# 5. --agent all without --project shows helpful error message
assert_output_contains "--project" \
  "--agent all without --project prints helpful error about --project" \
  "$ROOT_DIR/install.sh" --agent all --dry-run

# 6. --agent cursor without --project exits non-zero
assert_exit_code 1 \
  "--agent cursor without --project exits non-zero" \
  "$ROOT_DIR/install.sh" --agent cursor --dry-run

# 7. --agent copilot without --project exits non-zero
assert_exit_code 1 \
  "--agent copilot without --project exits non-zero" \
  "$ROOT_DIR/install.sh" --agent copilot --dry-run

# 8. --agent gemini without --project exits non-zero
assert_exit_code 1 \
  "--agent gemini without --project exits non-zero" \
  "$ROOT_DIR/install.sh" --agent gemini --dry-run

# 9. --agent aider without --project exits non-zero
assert_exit_code 1 \
  "--agent aider without --project exits non-zero" \
  "$ROOT_DIR/install.sh" --agent aider --dry-run

# 10. --agent unknown exits non-zero
assert_exit_code 1 \
  "--agent unknown exits non-zero" \
  "$ROOT_DIR/install.sh" --agent unknown --dry-run

# 11. Unknown flag exits non-zero
assert_exit_code 1 \
  "unknown flag exits non-zero" \
  "$ROOT_DIR/install.sh" --bad-flag

# 12. --help exits 0
assert_exit_code 0 \
  "--help exits 0" \
  "$ROOT_DIR/install.sh" --help

# 13. Dry run output mentions skills
assert_output_contains "code-review" \
  "--dry-run output mentions code-review skill" \
  "$ROOT_DIR/install.sh" --agent claude --dry-run

# 14. --project pointing to non-existent dir exits non-zero
assert_exit_code 1 \
  "--project with non-existent dir exits non-zero" \
  "$ROOT_DIR/install.sh" --agent cursor --project "/tmp/nonexistent-dir-for-test-$$"

echo ""
echo "test-install.sh: $pass_count passed, $fail_count failed"

[[ "$fail_count" -eq 0 ]]
