#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
pass_count=0
fail_count=0
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/aicodereview-uninstall-test.XXXXXX")"
trap 'rm -rf "$TMP_ROOT"' EXIT

pass() { echo "  PASS  $*"; pass_count=$((pass_count + 1)); }
fail() { echo "  FAIL  $*"; fail_count=$((fail_count + 1)); }
assert_exists() { [[ -e "$1" ]] && pass "$2" || fail "$2"; }
assert_not_exists() { [[ ! -e "$1" ]] && pass "$2" || fail "$2"; }
assert_exit_code() {
  local expected="$1" description="$2"
  shift 2
  local actual
  set +e
  "$@" >/dev/null 2>&1
  actual=$?
  set -e
  [[ "$actual" -eq "$expected" ]] && pass "$description" || fail "$description (expected $expected, got $actual)"
}

echo "── test-uninstall.sh ───────────────────────────────────"

claude_home="$TMP_ROOT/claude"
CLAUDE_HOME="$claude_home" "$ROOT_DIR/install.sh" --agent claude >/dev/null
CLAUDE_HOME="$claude_home" "$ROOT_DIR/uninstall.sh" --agent claude >/dev/null
assert_not_exists "$claude_home/skills/code-review" "managed native skill is removed"

unmanaged_home="$TMP_ROOT/unmanaged"
mkdir -p "$unmanaged_home/skills/code-review"
printf 'keep\n' > "$unmanaged_home/skills/code-review/custom.txt"
CLAUDE_HOME="$unmanaged_home" "$ROOT_DIR/uninstall.sh" --agent claude >/dev/null 2>&1
assert_exists "$unmanaged_home/skills/code-review/custom.txt" "unmanaged native skill is preserved"

project="$TMP_ROOT/project"
mkdir -p "$project"
"$ROOT_DIR/install.sh" --agent cursor --project "$project" >/dev/null
"$ROOT_DIR/uninstall.sh" --agent cursor --project "$project" >/dev/null
assert_not_exists "$project/.cursor/rules/code-review.mdc" "managed Cursor rule is removed"
assert_not_exists "$project/.cursor/rules/code-review.mdc.aicodereview-managed" "Cursor ownership marker is removed"

combined_project="$TMP_ROOT/combined"
mkdir -p "$combined_project"
"$ROOT_DIR/install.sh" --agent gemini --project "$combined_project" >/dev/null
"$ROOT_DIR/uninstall.sh" --agent gemini --project "$combined_project" >/dev/null
assert_not_exists "$combined_project/GEMINI.md" "managed-only Gemini file is removed when empty"

corrupt_project="$TMP_ROOT/corrupt"
mkdir -p "$corrupt_project"
printf '# >>> AICodeReview START <<<\nkeep\n' > "$corrupt_project/GEMINI.md"
assert_exit_code 1 "uninstall rejects corrupt markers" "$ROOT_DIR/uninstall.sh" --agent gemini --project "$corrupt_project"
assert_exists "$corrupt_project/GEMINI.md" "corrupt file remains untouched"

echo ""
echo "test-uninstall.sh: $pass_count passed, $fail_count failed"
[[ "$fail_count" -eq 0 ]]
