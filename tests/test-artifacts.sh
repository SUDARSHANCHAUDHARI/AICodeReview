#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/aicodereview-artifacts-test.XXXXXX")"
trap 'rm -rf "$TMP_ROOT"' EXIT

pass_count=0
fail_count=0
pass() { echo "  PASS  $*"; pass_count=$((pass_count + 1)); }
fail() { echo "  FAIL  $*"; fail_count=$((fail_count + 1)); }

echo "── test-artifacts.sh ───────────────────────────────────"

if python3 "$ROOT_DIR/scripts/skill_artifacts.py" validate >/dev/null; then
  pass "canonical skills validate"
else
  fail "canonical skills did not validate"
fi

if python3 "$ROOT_DIR/scripts/skill_artifacts.py" sync-openai --check >/dev/null; then
  pass "OpenAI metadata is synchronized"
else
  fail "OpenAI metadata is stale"
fi

cursor="$TMP_ROOT/code-review.mdc"
python3 "$ROOT_DIR/scripts/skill_artifacts.py" render-cursor --skill code-review --output "$cursor"
grep -q '^description: ' "$cursor" && pass "Cursor rule contains generated description" || fail "Cursor description missing"
grep -q '^alwaysApply: false$' "$cursor" && pass "Cursor rule is on-demand" || fail "Cursor alwaysApply metadata is wrong"
grep -q '^# Code Review$' "$cursor" && pass "Cursor rule contains canonical workflow" || fail "Cursor rule omitted canonical workflow"

aider="$TMP_ROOT/AICODEREVIEW.md"
python3 "$ROOT_DIR/scripts/skill_artifacts.py" render-aider --output "$aider"
grep -q '^## Code Review$' "$aider" && pass "Aider output contains Code Review" || fail "Aider output omitted Code Review"
grep -q '^## Onboarding Writer$' "$aider" && pass "Aider output contains final discovered skill" || fail "Aider output omitted final skill"

openai="$ROOT_DIR/skills/code-review/agents/openai.yaml"
grep -q '^interface:$' "$openai" && pass "OpenAI metadata uses interface structure" || fail "OpenAI interface missing"
grep -q '\$code-review' "$openai" && pass "OpenAI prompt invokes the skill" || fail "OpenAI prompt does not invoke the skill"

echo
echo "test-artifacts.sh: $pass_count passed, $fail_count failed"
[[ "$fail_count" -eq 0 ]]
