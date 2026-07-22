#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
# shellcheck source=../aicodereview-lib.sh
source "$ROOT_DIR/aicodereview-lib.sh"
load_skills "$ROOT_DIR"

failures=0
fail() { echo "FAIL: $*" >&2; failures=$((failures + 1)); }
check_file() { [[ -f "$1" ]] || fail "Missing file: $1"; }
check_nonempty() { [[ -s "$1" ]] || fail "Missing or empty file: $1"; }

required_files=(
  "bin/aicodereview.js"
  "src/runtime.ts"
  "tsconfig.json"
  "package.json"
  ".github/workflows/validate.yml"
  "scripts/validate.sh"
  "tests/node-cli.test.js"
  "tests/node-maintenance.test.js"
)
for file in "${required_files[@]}"; do check_file "$file"; done

node --check bin/aicodereview.js || fail "bin/aicodereview.js has JavaScript syntax errors"
node --check tests/node-cli.test.js || fail "tests/node-cli.test.js has JavaScript syntax errors"
node --check tests/node-maintenance.test.js || fail "tests/node-maintenance.test.js has JavaScript syntax errors"

for skill in "${skills[@]}"; do
  skill_dir="skills/$skill"
  check_nonempty "$skill_dir/SKILL.md"
  check_nonempty "$skill_dir/agents/openai.yaml"
  for obsolete in cursor.mdc copilot.md gemini.md aider.md; do
    [[ ! -e "$skill_dir/agents/$obsolete" ]] || fail "Obsolete adapter remains: $skill_dir/agents/$obsolete"
  done
done

if command -v npm >/dev/null 2>&1; then
  npm run build >/dev/null || fail "TypeScript build failed"
  node bin/aicodereview.js validate >/dev/null || fail "Node repository validation failed"
else
  fail "npm is required for repository validation"
fi

grep -qF "dist', 'runtime.js" bin/aicodereview.js || fail "npm entrypoint does not load dist/runtime.js"
if grep -qF "execFileSync('bash'" bin/aicodereview.js; then fail "npm entrypoint still delegates to Bash"; fi
grep -qF 'windows-latest' .github/workflows/validate.yml || fail "CI does not include Windows"
grep -qF 'tests/node-maintenance.test.js' package.json || fail "package tests omit maintenance commands"
grep -qF 'npm pack --dry-run' package.json || fail "package validation does not inspect publish contents"
for runtime_file in install.sh uninstall.sh update.sh list-installed.sh check-health.sh scripts/skill_artifacts.py aicodereview-lib.sh; do
  if grep -qF "\"$runtime_file\"" package.json; then fail "npm package still publishes legacy runtime file: $runtime_file"; fi
done

if [[ "$failures" -gt 0 ]]; then
  echo
  echo "$failures validation failure(s)."
  exit 1
fi

echo "Validation passed."
