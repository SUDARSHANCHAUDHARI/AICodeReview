#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
pass_count=0
fail_count=0
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/aicodereview-install-test.XXXXXX")"
trap 'rm -rf "$TMP_ROOT"' EXIT

pass() { echo "  PASS  $*"; pass_count=$((pass_count + 1)); }
fail() { echo "  FAIL  $*"; fail_count=$((fail_count + 1)); }

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

assert_exists() {
  [[ -e "$1" ]] && pass "$2" || fail "$2 (missing: $1)"
}

assert_not_exists() {
  [[ ! -e "$1" ]] && pass "$2" || fail "$2 (unexpected: $1)"
}

assert_contains() {
  local file="$1" text="$2" description="$3"
  [[ -f "$file" ]] && grep -qF "$text" "$file" && pass "$description" || fail "$description"
}

echo "── test-install.sh ─────────────────────────────────────"

assert_exit_code 0 "default dry-run succeeds" "$ROOT_DIR/install.sh" --dry-run
assert_exit_code 0 "Claude dry-run succeeds" "$ROOT_DIR/install.sh" --agent claude --dry-run
assert_exit_code 0 "Codex dry-run succeeds" "$ROOT_DIR/install.sh" --agent codex --dry-run
assert_exit_code 1 "project agent requires --project" "$ROOT_DIR/install.sh" --agent cursor --dry-run
assert_exit_code 1 "unknown agent fails" "$ROOT_DIR/install.sh" --agent unknown --dry-run
assert_exit_code 1 "unknown flag fails" "$ROOT_DIR/install.sh" --bad-flag
assert_exit_code 0 "help succeeds" "$ROOT_DIR/install.sh" --help

claude_home="$TMP_ROOT/claude"
CLAUDE_HOME="$claude_home" "$ROOT_DIR/install.sh" --agent claude >/dev/null
assert_exists "$claude_home/skills/code-review/SKILL.md" "native skill is copied"
assert_contains "$claude_home/skills/code-review/.aicodereview-managed" "source=SUDARSHANCHAUDHARI/AICodeReview" "native skill ownership marker is written"

unmanaged_home="$TMP_ROOT/unmanaged-claude"
mkdir -p "$unmanaged_home/skills/code-review"
printf 'user-owned\n' > "$unmanaged_home/skills/code-review/custom.txt"
CLAUDE_HOME="$unmanaged_home" "$ROOT_DIR/install.sh" --agent claude --force >/dev/null
backup="$(find "$unmanaged_home/skills" -maxdepth 1 -name 'code-review.aicodereview-backup-*' -print -quit)"
[[ -n "$backup" ]] && pass "force install backs up unmanaged conflicts" || fail "force install did not create an unmanaged backup"
[[ -n "$backup" ]] && assert_contains "$backup/custom.txt" "user-owned" "unmanaged backup preserves original content"
assert_contains "$unmanaged_home/skills/code-review/.aicodereview-managed" "skill=code-review" "replacement is marked as managed"

project="$TMP_ROOT/project"
mkdir -p "$project"
"$ROOT_DIR/install.sh" --agent cursor --project "$project" >/dev/null
assert_exists "$project/.cursor/rules/code-review.mdc" "Cursor rule is installed"
assert_exists "$project/.cursor/rules/code-review.mdc.aicodereview-managed" "Cursor ownership marker is written"

corrupt_project="$TMP_ROOT/corrupt-project"
mkdir -p "$corrupt_project/.github"
printf '# >>> AICodeReview START <<<\noriginal\n' > "$corrupt_project/.github/copilot-instructions.md"
assert_exit_code 1 "corrupt combined markers are rejected" "$ROOT_DIR/install.sh" --agent copilot --project "$corrupt_project"
assert_contains "$corrupt_project/.github/copilot-instructions.md" "original" "corrupt combined file remains unchanged"
assert_not_exists "$corrupt_project/.github/copilot-instructions.md.aicodereview-backup" "no misleading combined backup is created"

output="$(CLAUDE_HOME="$claude_home" CODEX_HOME="$TMP_ROOT/empty-codex" "$ROOT_DIR/list-installed.sh")"
if printf '%s\n' "$output" | grep -q 'onboarding-writer.*installed'; then
  pass "maintenance inventory includes the final discovered skill"
else
  fail "maintenance inventory omitted onboarding-writer"
fi

echo ""
echo "test-install.sh: $pass_count passed, $fail_count failed"
[[ "$fail_count" -eq 0 ]]
