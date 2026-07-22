#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
# shellcheck source=../aicodereview-lib.sh
source "$ROOT_DIR/aicodereview-lib.sh"
load_skills "$ROOT_DIR"

failures=0
warnings=0
fail() { echo "FAIL: $*" >&2; failures=$((failures + 1)); }
warn() { echo "WARN: $*" >&2; warnings=$((warnings + 1)); }
check_file() { [[ -f "$1" ]] || fail "Missing file: $1"; }
check_nonempty() { [[ -s "$1" ]] || fail "Missing or empty file: $1"; }

root_scripts=(
  "aicodereview-lib.sh"
  "install.sh"
  "uninstall.sh"
  "update.sh"
  "list-installed.sh"
  "check-health.sh"
  "scripts/validate.sh"
  "tests/run-all.sh"
  "tests/test-install.sh"
  "tests/test-uninstall.sh"
  "tests/test-validate.sh"
)

for script in "${root_scripts[@]}"; do
  check_file "$script"
  if [[ -f "$script" ]] && ! bash -n "$script"; then
    fail "$script has shell syntax errors"
  fi
done

validate_skill_frontmatter() {
  local skill="$1"
  local file="skills/$skill/SKILL.md"
  local first_line frontmatter name description

  first_line="$(head -n 1 "$file")"
  [[ "$first_line" == "---" ]] || fail "$file must start with YAML frontmatter"

  frontmatter="$(awk 'NR == 1 { next } /^---$/ { exit } { print }' "$file")"
  name="$(printf '%s\n' "$frontmatter" | sed -n 's/^name:[[:space:]]*//p' | head -1)"
  description="$(printf '%s\n' "$frontmatter" | sed -n 's/^description:[[:space:]]*//p' | head -1)"

  [[ "$name" == "$skill" ]] || fail "$file name '$name' does not match directory '$skill'"
  [[ "$skill" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || fail "$skill is not valid kebab-case"
  [[ -n "$description" ]] || fail "$file has an empty description"
  [[ "${#description}" -le 1024 ]] || fail "$file description exceeds 1024 characters"
}

for skill in "${skills[@]}"; do
  skill_dir="skills/$skill"
  skill_file="$skill_dir/SKILL.md"
  check_nonempty "$skill_file"
  [[ -s "$skill_file" ]] && validate_skill_frontmatter "$skill"

  for agent_file in openai.yaml cursor.mdc copilot.md gemini.md aider.md; do
    check_nonempty "$skill_dir/agents/$agent_file"
  done

  cursor_file="$skill_dir/agents/cursor.mdc"
  if [[ -s "$cursor_file" ]]; then
    [[ "$(head -n 1 "$cursor_file")" == "---" ]] || fail "$cursor_file must start with frontmatter"
    grep -q '^description:' "$cursor_file" || fail "$cursor_file missing description metadata"
    grep -q '^alwaysApply:' "$cursor_file" || fail "$cursor_file missing alwaysApply metadata"
  fi

  openai_file="$skill_dir/agents/openai.yaml"
  if [[ -s "$openai_file" ]] && ! grep -q '^interface:' "$openai_file"; then
    warn "$openai_file uses legacy top-level UI metadata; migrate it under interface: in Phase 1"
  fi
done

for script in install.sh uninstall.sh check-health.sh list-installed.sh; do
  grep -q 'load_skills' "$script" || fail "$script does not load the dynamic skill inventory"
done

grep -qF '.github/skills' install.sh || fail "install.sh missing native Copilot skills path"
grep -qF '.gemini/skills' install.sh || fail "install.sh missing native Gemini skills path"
grep -qF '.opencode/skills' install.sh || fail "install.sh missing native OpenCode skills path"
grep -qF 'AICODEREVIEW.md' install.sh || fail "install.sh missing managed Aider conventions file"
grep -qF '.github/skills' uninstall.sh || fail "uninstall.sh missing native Copilot cleanup"
grep -qF '.gemini/skills' uninstall.sh || fail "uninstall.sh missing native Gemini cleanup"
grep -qF '.opencode/skills' uninstall.sh || fail "uninstall.sh missing native OpenCode cleanup"

if grep -q 'install_combined "copilot.md"' install.sh; then
  fail "Copilot still installs a combined persistent instruction section"
fi
if grep -q 'install_combined "gemini.md"' install.sh; then
  fail "Gemini still installs a combined persistent context section"
fi

if [[ "$failures" -gt 0 ]]; then
  echo ""
  echo "$failures validation failure(s), $warnings warning(s)."
  exit 1
fi

echo "Validation passed with $warnings warning(s)."
