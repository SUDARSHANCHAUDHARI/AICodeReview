#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
pass_count=0
fail_count=0

pass() { echo "  PASS  $*"; pass_count=$((pass_count + 1)); }
fail() { echo "  FAIL  $*"; fail_count=$((fail_count + 1)); }

echo "── test-validate.sh ────────────────────────────────────"

if "$ROOT_DIR/scripts/validate.sh" >/dev/null; then pass "Validation passes"; else fail "Validation fails"; fi

for path in \
  '.github/skills' \
  '.gemini/skills' \
  '.opencode/skills' \
  'AICODEREVIEW.md'; do
  if grep -qF "$path" "$ROOT_DIR/install.sh"; then pass "Installer references $path"; else fail "Installer misses $path"; fi
done

if ! grep -q 'install_combined "copilot.md"' "$ROOT_DIR/install.sh"; then
  pass "Copilot no longer uses combined persistent instructions"
else
  fail "Copilot still uses combined persistent instructions"
fi

if ! grep -q 'install_combined "gemini.md"' "$ROOT_DIR/install.sh"; then
  pass "Gemini no longer uses combined persistent context"
else
  fail "Gemini still uses combined persistent context"
fi

echo ""
echo "test-validate.sh: $pass_count passed, $fail_count failed"
[[ "$fail_count" -eq 0 ]]
