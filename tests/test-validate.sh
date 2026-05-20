#!/usr/bin/env bash
set -euo pipefail

# tests/test-validate.sh — scripts/validate.sh behaviour tests (pure bash, no external deps)

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

pass_count=0
fail_count=0

assert_exit_code() {
  local expected="$1"
  local description="$2"
  shift 2
  local actual

  set +e
  "$@"
  actual=$?
  set -e

  if [[ "$actual" -eq "$expected" ]]; then
    echo "  PASS  $description (exit $actual)"
    pass_count=$((pass_count + 1))
  else
    echo "  FAIL  $description (expected exit $expected, got $actual)"
    fail_count=$((fail_count + 1))
  fi
}

assert_file_exists() {
  local path="$1"
  local description="$2"

  if [[ -f "$path" ]]; then
    echo "  PASS  $description"
    pass_count=$((pass_count + 1))
  else
    echo "  FAIL  $description (file not found: $path)"
    fail_count=$((fail_count + 1))
  fi
}

assert_dir_exists() {
  local path="$1"
  local description="$2"

  if [[ -d "$path" ]]; then
    echo "  PASS  $description"
    pass_count=$((pass_count + 1))
  else
    echo "  FAIL  $description (directory not found: $path)"
    fail_count=$((fail_count + 1))
  fi
}

echo "── test-validate.sh ────────────────────────────────────"

# 1. validate.sh exits 0 on the current source tree
assert_exit_code 0 \
  "scripts/validate.sh exits 0 on current source tree" \
  "$ROOT_DIR/scripts/validate.sh"

# 2. Each skill dir has SKILL.md
agent_files=("SKILL.md" "agents/openai.yaml" "agents/cursor.mdc" "agents/copilot.md" "agents/gemini.md" "agents/aider.md")

while IFS= read -r skill_dir; do
  skill_name="$(basename "$skill_dir")"

  assert_dir_exists "$skill_dir" \
    "skill dir exists: $skill_name"

  for f in "${agent_files[@]}"; do
    assert_file_exists "$skill_dir/$f" \
      "$skill_name has $f"
  done

done < <(find "$ROOT_DIR/skills" -mindepth 1 -maxdepth 1 -type d | sort)

# 3. Each skill is referenced in install.sh
while IFS= read -r skill_dir; do
  skill_name="$(basename "$skill_dir")"

  if grep -qF "\"$skill_name\"" "$ROOT_DIR/install.sh"; then
    echo "  PASS  install.sh references $skill_name"
    pass_count=$((pass_count + 1))
  else
    echo "  FAIL  install.sh does not reference $skill_name"
    fail_count=$((fail_count + 1))
  fi

done < <(find "$ROOT_DIR/skills" -mindepth 1 -maxdepth 1 -type d | sort)

# 4. Each skill is referenced in uninstall.sh
while IFS= read -r skill_dir; do
  skill_name="$(basename "$skill_dir")"

  if grep -qF "\"$skill_name\"" "$ROOT_DIR/uninstall.sh"; then
    echo "  PASS  uninstall.sh references $skill_name"
    pass_count=$((pass_count + 1))
  else
    echo "  FAIL  uninstall.sh does not reference $skill_name"
    fail_count=$((fail_count + 1))
  fi

done < <(find "$ROOT_DIR/skills" -mindepth 1 -maxdepth 1 -type d | sort)

# 5. install.sh has no shell syntax errors
assert_exit_code 0 \
  "install.sh has no shell syntax errors" \
  bash -n "$ROOT_DIR/install.sh"

# 6. uninstall.sh has no shell syntax errors
assert_exit_code 0 \
  "uninstall.sh has no shell syntax errors" \
  bash -n "$ROOT_DIR/uninstall.sh"

# 7. validate.sh itself has no shell syntax errors
assert_exit_code 0 \
  "scripts/validate.sh has no shell syntax errors" \
  bash -n "$ROOT_DIR/scripts/validate.sh"

echo ""
echo "test-validate.sh: $pass_count passed, $fail_count failed"

[[ "$fail_count" -eq 0 ]]
