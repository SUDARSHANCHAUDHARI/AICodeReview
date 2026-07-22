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
  "src/cli.ts"
  "tsconfig.json"
  "package.json"
  "aicodereview-lib.sh"
  "install.sh"
  "uninstall.sh"
  "update.sh"
  "list-installed.sh"
  "check-health.sh"
  "scripts/skill_artifacts.py"
  "scripts/validate.sh"
  "tests/node-cli.test.js"
  "tests/run-all.sh"
  "tests/test-artifacts.sh"
  "tests/test-install.sh"
  "tests/test-uninstall.sh"
  "tests/test-validate.sh"
)

for file in "${required_files[@]}"; do
  check_file "$file"
done

for script in install.sh uninstall.sh update.sh list-installed.sh check-health.sh scripts/validate.sh tests/run-all.sh tests/test-artifacts.sh tests/test-install.sh tests/test-uninstall.sh tests/test-validate.sh; do
  [[ ! -f "$script" ]] || bash -n "$script" || fail "$script has shell syntax errors"
done

node --check bin/aicodereview.js || fail "bin/aicodereview.js has JavaScript syntax errors"
node --check tests/node-cli.test.js || fail "tests/node-cli.test.js has JavaScript syntax errors"

python3 - "$ROOT_DIR/scripts/skill_artifacts.py" <<'PYEOF' || fail "scripts/skill_artifacts.py has Python syntax errors"
import pathlib
import sys
path = pathlib.Path(sys.argv[1])
compile(path.read_text(encoding="utf-8"), str(path), "exec")
PYEOF

validate_skill_frontmatter() {
  local skill="$1"
  local file="skills/$skill/SKILL.md"
  local frontmatter name description

  [[ "$(head -n 1 "$file")" == "---" ]] || fail "$file must start with YAML frontmatter"
  frontmatter="$(awk 'NR == 1 { next } /^---$/ { exit } { print }' "$file")"
  name="$(printf '%s\n' "$frontmatter" | sed -n 's/^name:[[:space:]]*//p' | head -1)"
  description="$(printf '%s\n' "$frontmatter" | sed -n 's/^description:[[:space:]]*//p' | head -1)"
  [[ "$name" == "$skill" ]] || fail "$file name '$name' does not match directory '$skill'"
  [[ "$skill" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || fail "$skill is not valid kebab-case"
  [[ -n "$description" ]] || fail "$file has an empty description"
}

for skill in "${skills[@]}"; do
  skill_dir="skills/$skill"
  check_nonempty "$skill_dir/SKILL.md"
  check_nonempty "$skill_dir/agents/openai.yaml"
  [[ ! -s "$skill_dir/SKILL.md" ]] || validate_skill_frontmatter "$skill"

  for obsolete in cursor.mdc copilot.md gemini.md aider.md; do
    [[ ! -e "$skill_dir/agents/$obsolete" ]] || fail "Obsolete adapter remains: $skill_dir/agents/$obsolete"
  done
done

python3 scripts/skill_artifacts.py validate || fail "Canonical artifact validation failed"
python3 scripts/skill_artifacts.py sync-openai --check || fail "OpenAI metadata is stale"

for script in install.sh uninstall.sh check-health.sh list-installed.sh; do
  grep -q 'load_skills' "$script" || fail "$script does not load the dynamic skill inventory"
done

grep -qF 'render-cursor' install.sh || fail "install.sh does not generate Cursor rules"
grep -qF 'render-aider' install.sh || fail "install.sh does not generate the Aider catalog"
grep -qF 'sync-openai --check' install.sh || fail "install.sh does not verify OpenAI metadata"
grep -qF "require(compiledCli)" bin/aicodereview.js || fail "npm entrypoint does not load the compiled Node CLI"
if grep -qF "execFileSync('bash'" bin/aicodereview.js; then
  fail "npm entrypoint still delegates to Bash"
fi
grep -qF 'windows-latest' .github/workflows/validate.yml || fail "CI does not include Windows"
grep -qF 'dist/' package.json || fail "package.json does not publish compiled CLI output"
grep -qF 'src/' package.json || fail "package.json does not publish TypeScript source"

if [[ "$failures" -gt 0 ]]; then
  echo
  echo "$failures validation failure(s)."
  exit 1
fi

echo "Validation passed."
