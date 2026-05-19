#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

failures=0

fail() {
  echo "FAIL: $*" >&2
  failures=$((failures + 1))
}

check_file() {
  local path="$1"
  [[ -f "$path" ]] || fail "Missing file: $path"
}

check_file "install.sh"
check_file "uninstall.sh"

bash -n install.sh || fail "install.sh has shell syntax errors"
bash -n uninstall.sh || fail "uninstall.sh has shell syntax errors"
bash -n scripts/validate.sh || fail "scripts/validate.sh has shell syntax errors"

while IFS= read -r skill_dir; do
  skill_name="$(basename "$skill_dir")"
  skill_file="$skill_dir/SKILL.md"
  metadata_file="$skill_dir/agents/openai.yaml"

  check_file "$skill_file"
  check_file "$metadata_file"

  if [[ -f "$skill_file" ]]; then
    grep -q '^---$' "$skill_file" || fail "$skill_file missing frontmatter fence"
    grep -q '^name: ' "$skill_file" || fail "$skill_file missing name metadata"
    grep -q '^description: ' "$skill_file" || fail "$skill_file missing description metadata"
  fi

  grep -q "\"$skill_name\"" install.sh || fail "install.sh does not reference $skill_name"
  grep -q "\"$skill_name\"" uninstall.sh || fail "uninstall.sh does not reference $skill_name"
done < <(find skills -mindepth 1 -maxdepth 1 -type d | sort)

if [[ "$failures" -gt 0 ]]; then
  echo
  echo "$failures validation failure(s)."
  exit 1
fi

echo "Validation passed."
