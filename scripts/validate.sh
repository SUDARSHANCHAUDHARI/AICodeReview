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
  "src/hooks.ts"
  "src/eval.ts"
  "hooks/runner.js"
  "evals/manifest.json"
  "evals/README.md"
  "tsconfig.json"
  "package.json"
  ".github/workflows/validate.yml"
  "tests/node-cli.test.js"
  "tests/node-maintenance.test.js"
  "tests/hooks-eval.test.js"
)
for file in "${required_files[@]}"; do check_file "$file"; done

node --check bin/aicodereview.js || fail "bin/aicodereview.js has JavaScript syntax errors"
node --check hooks/runner.js || fail "hooks/runner.js has JavaScript syntax errors"
for test_file in tests/node-cli.test.js tests/node-maintenance.test.js tests/hooks-eval.test.js; do
  node --check "$test_file" || fail "$test_file has JavaScript syntax errors"
done

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
  node bin/aicodereview.js eval --validate >/dev/null || fail "Evaluation fixtures are invalid"
else
  fail "npm is required for repository validation"
fi

grep -qF "moduleName = command === 'hooks'" bin/aicodereview.js || fail "npm entrypoint does not dispatch hooks"
grep -qF "command === 'eval'" bin/aicodereview.js || fail "npm entrypoint does not dispatch evaluations"
if grep -qF "execFileSync('bash'" bin/aicodereview.js; then fail "npm entrypoint still delegates to Bash"; fi
grep -qF 'windows-latest' .github/workflows/validate.yml || fail "CI does not include Windows"
grep -qF 'tests/hooks-eval.test.js' package.json || fail "package tests omit hooks and evaluations"
grep -qF '"hooks/"' package.json || fail "npm package omits hook runner"
grep -qF '"evals/"' package.json || fail "npm package omits evaluation fixtures"
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
