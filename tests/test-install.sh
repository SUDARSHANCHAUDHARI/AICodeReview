#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
pass_count=0
fail_count=0
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/aicodereview-install-test.XXXXXX")"
trap 'rm -rf "$TMP_ROOT"' EXIT

pass() { echo "  PASS  $*"; pass_count=$((pass_count + 1)); }
fail() { echo "  FAIL  $*"; fail_count=$((fail_count + 1)); }
assert_exists() { [[ -e "$1" ]] && pass "$2" || fail "$2 (missing: $1)"; }
assert_not_exists() { [[ ! -e "$1" ]] && pass "$2" || fail "$2 (unexpected: $1)"; }
assert_contains() {
  local file="$1" text="$2" description="$3"
  [[ -f "$file" ]] && grep -qF "$text" "$file" && pass "$description" || fail "$description"
}
assert_not_contains() {
  local file="$1" text="$2" description="$3"
  if [[ ! -f "$file" ]] || ! grep -qF "$text" "$file"; then pass "$description"; else fail "$description"; fi
}
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

echo "── test-install.sh ─────────────────────────────────────"

assert_exit_code 0 "default dry-run succeeds" "$ROOT_DIR/install.sh" --dry-run
assert_exit_code 1 "project adapter requires --project" "$ROOT_DIR/install.sh" --agent copilot --dry-run
assert_exit_code 0 "OpenCode dry-run succeeds" "$ROOT_DIR/install.sh" --agent opencode --project "$TMP_ROOT" --dry-run
assert_exit_code 1 "unknown agent fails" "$ROOT_DIR/install.sh" --agent unknown --dry-run

claude_home="$TMP_ROOT/claude"
CLAUDE_HOME="$claude_home" "$ROOT_DIR/install.sh" --agent claude >/dev/null
assert_exists "$claude_home/skills/code-review/SKILL.md" "Claude native skill is installed"
assert_contains "$claude_home/skills/code-review/.aicodereview-managed" "source=SUDARSHANCHAUDHARI/AICodeReview" "Claude skill is ownership-marked"

copilot_project="$TMP_ROOT/copilot"
mkdir -p "$copilot_project/.github"
cat > "$copilot_project/.github/copilot-instructions.md" <<'EOF_LEGACY'
Keep this user instruction.

# >>> AICodeReview START <<<
Legacy review context.
# >>> AICodeReview END <<<
EOF_LEGACY
"$ROOT_DIR/install.sh" --agent copilot --project "$copilot_project" >/dev/null
assert_exists "$copilot_project/.github/skills/code-review/SKILL.md" "Copilot native skill is installed"
assert_contains "$copilot_project/.github/copilot-instructions.md" "Keep this user instruction." "Copilot migration preserves user instructions"
assert_not_contains "$copilot_project/.github/copilot-instructions.md" "# >>> AICodeReview START <<<" "Copilot legacy section is removed"

gemini_project="$TMP_ROOT/gemini"
mkdir -p "$gemini_project"
"$ROOT_DIR/install.sh" --agent gemini --project "$gemini_project" >/dev/null
assert_exists "$gemini_project/.gemini/skills/code-review/SKILL.md" "Gemini native skill is installed"

opencode_project="$TMP_ROOT/opencode"
mkdir -p "$opencode_project"
"$ROOT_DIR/install.sh" --agent opencode --project "$opencode_project" >/dev/null
assert_exists "$opencode_project/.opencode/skills/code-review/SKILL.md" "OpenCode native skill is installed"

cursor_project="$TMP_ROOT/cursor"
mkdir -p "$cursor_project"
"$ROOT_DIR/install.sh" --agent cursor --project "$cursor_project" >/dev/null
assert_exists "$cursor_project/.cursor/rules/code-review.mdc" "Cursor installs the first generated rule"
assert_exists "$cursor_project/.cursor/rules/onboarding-writer.mdc" "Cursor installs the final generated rule"
assert_contains "$cursor_project/.cursor/rules/code-review.mdc" "# Code Review" "Cursor rule contains canonical workflow content"

aider_project="$TMP_ROOT/aider"
mkdir -p "$aider_project"
"$ROOT_DIR/install.sh" --agent aider --project "$aider_project" >/dev/null
assert_exists "$aider_project/AICODEREVIEW.md" "Aider conventions file is installed"
assert_exists "$aider_project/AICODEREVIEW.md.aicodereview-managed" "Aider conventions file is ownership-marked"
assert_contains "$aider_project/.aider.conf.yml" "AICODEREVIEW.md" "Aider is auto-configured when no read setting exists"

aider_existing="$TMP_ROOT/aider-existing"
mkdir -p "$aider_existing"
printf 'read:\n  - USER.md\n' > "$aider_existing/.aider.conf.yml"
"$ROOT_DIR/install.sh" --agent aider --project "$aider_existing" >/dev/null
assert_contains "$aider_existing/.aider.conf.yml" "USER.md" "Existing Aider read setting is preserved"
assert_not_contains "$aider_existing/.aider.conf.yml" "# >>> AICodeReview Aider read START <<<" "No duplicate Aider read key is appended"

corrupt_project="$TMP_ROOT/corrupt"
mkdir -p "$corrupt_project/.github"
printf '# >>> AICodeReview START <<<\nlegacy\n' > "$corrupt_project/.github/copilot-instructions.md"
assert_exit_code 1 "Corrupt legacy markers block migration" "$ROOT_DIR/install.sh" --agent copilot --project "$corrupt_project"
assert_not_exists "$corrupt_project/.github/skills/code-review" "Corrupt migration fails before native skill changes"

all_project="$TMP_ROOT/all-preflight"
all_claude="$TMP_ROOT/all-claude"
all_codex="$TMP_ROOT/all-codex"
mkdir -p "$all_project"
printf '# >>> AICodeReview START <<<\nlegacy\n' > "$all_project/GEMINI.md"
assert_exit_code 1 "All-agent install rejects a later corrupt adapter during preflight" env CLAUDE_HOME="$all_claude" CODEX_HOME="$all_codex" "$ROOT_DIR/install.sh" --agent all --project "$all_project"
assert_not_exists "$all_claude/skills/code-review" "All-agent preflight prevents partial Claude installation"
assert_not_exists "$all_codex/skills/code-review" "All-agent preflight prevents partial Codex installation"
assert_not_exists "$all_project/.cursor/rules/code-review.mdc" "All-agent preflight prevents partial project installation"

conflict_project="$TMP_ROOT/conflict"
mkdir -p "$conflict_project/.github/skills/code-review"
printf 'user-owned\n' > "$conflict_project/.github/skills/code-review/custom.txt"
"$ROOT_DIR/install.sh" --agent copilot --project "$conflict_project" --force >/dev/null
backup="$(find "$conflict_project/.github/skills" -maxdepth 1 -name 'code-review.aicodereview-backup-*' -print -quit)"
[[ -n "$backup" ]] && pass "Force migration backs up unmanaged native conflicts" || fail "Force migration did not create a backup"
[[ -n "$backup" ]] && assert_contains "$backup/custom.txt" "user-owned" "Native conflict backup preserves user content"

output="$(CLAUDE_HOME="$claude_home" CODEX_HOME="$TMP_ROOT/empty-codex" "$ROOT_DIR/list-installed.sh" --project "$opencode_project")"
printf '%s\n' "$output" | grep -q 'opencode.*code-review.*installed' && pass "Inventory reports OpenCode native skills" || fail "Inventory omitted OpenCode native skills"
printf '%s\n' "$output" | grep -q 'onboarding-writer' && pass "Inventory includes every discovered skill" || fail "Inventory omitted a discovered skill"

echo ""
echo "test-install.sh: $pass_count passed, $fail_count failed"
[[ "$fail_count" -eq 0 ]]
