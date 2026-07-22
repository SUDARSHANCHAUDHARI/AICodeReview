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

echo "── test-uninstall.sh ───────────────────────────────────"

project="$TMP_ROOT/project"
claude_home="$TMP_ROOT/claude"
codex_home="$TMP_ROOT/codex"
mkdir -p "$project"
env CLAUDE_HOME="$claude_home" CODEX_HOME="$codex_home" \
  "$ROOT_DIR/install.sh" --agent all --project "$project" >/dev/null
env CLAUDE_HOME="$claude_home" CODEX_HOME="$codex_home" \
  "$ROOT_DIR/uninstall.sh" --agent all --project "$project" >/dev/null

assert_not_exists "$claude_home/skills/code-review" "Managed Claude skill is removed from isolated test home"
assert_not_exists "$codex_home/skills/code-review" "Managed Codex skill is removed from isolated test home"
assert_not_exists "$project/.cursor/rules/code-review.mdc" "Managed Cursor rule is removed"
assert_not_exists "$project/.github/skills/code-review" "Managed Copilot skill is removed"
assert_not_exists "$project/.gemini/skills/code-review" "Managed Gemini skill is removed"
assert_not_exists "$project/.opencode/skills/code-review" "Managed OpenCode skill is removed"
assert_not_exists "$project/.aicodereview/skills/code-review" "Managed Aider selective skill is removed"
assert_not_exists "$project/.aicodereview" "Empty Aider skill root is removed"
assert_not_exists "$project/AICODEREVIEW.md" "Managed Aider catalog is removed"
assert_not_exists "$project/.aider.conf.yml" "Managed-only Aider config is removed"

unmanaged="$TMP_ROOT/unmanaged"
mkdir -p "$unmanaged/.github/skills/code-review"
printf 'keep\n' > "$unmanaged/.github/skills/code-review/custom.txt"
"$ROOT_DIR/uninstall.sh" --agent copilot --project "$unmanaged" >/dev/null 2>&1
assert_exists "$unmanaged/.github/skills/code-review/custom.txt" "Unmanaged Copilot skill is preserved"

unmanaged_aider="$TMP_ROOT/unmanaged-aider"
mkdir -p "$unmanaged_aider/.aicodereview/skills/code-review"
printf 'keep\n' > "$unmanaged_aider/.aicodereview/skills/code-review/custom.txt"
"$ROOT_DIR/uninstall.sh" --agent aider --project "$unmanaged_aider" >/dev/null 2>&1
assert_exists "$unmanaged_aider/.aicodereview/skills/code-review/custom.txt" "Unmanaged Aider skill is preserved"

legacy="$TMP_ROOT/legacy"
mkdir -p "$legacy/.github"
cat > "$legacy/.github/copilot-instructions.md" <<'EOF_LEGACY'
Keep this.

# >>> AICodeReview START <<<
Legacy.
# >>> AICodeReview END <<<
EOF_LEGACY
"$ROOT_DIR/uninstall.sh" --agent copilot --project "$legacy" >/dev/null
assert_exists "$legacy/.github/copilot-instructions.md" "Legacy file with user content remains"
grep -qF 'Keep this.' "$legacy/.github/copilot-instructions.md" && pass "Legacy uninstall preserves user content" || fail "Legacy uninstall removed user content"
if ! grep -qF '# >>> AICodeReview START <<<' "$legacy/.github/copilot-instructions.md"; then
  pass "Legacy managed section is removed"
else
  fail "Legacy managed section remains"
fi

echo ""
echo "test-uninstall.sh: $pass_count passed, $fail_count failed"
[[ "$fail_count" -eq 0 ]]
