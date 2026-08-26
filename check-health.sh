#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=aicodereview-lib.sh
source "$ROOT_DIR/aicodereview-lib.sh"
load_skills "$ROOT_DIR"

LEGACY_SECTION_START="# >>> AICodeReview START <<<"
LEGACY_SECTION_END="# >>> AICodeReview END <<<"
AIDER_CONFIG_START="# >>> AICodeReview Aider read START <<<"
AIDER_CONFIG_END="# <<< AICodeReview Aider read END <<<"

project_dir=""

usage() {
  cat <<'EOF_USAGE'
Usage: ./check-health.sh [--project <path>]

Checks managed Claude, Codex, Cursor, Copilot, Gemini, OpenCode, and Aider adapters.
Reports stale content, unmanaged conflicts, incomplete migrations, and corrupt markers.
EOF_USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project)
      [[ $# -ge 2 ]] || { echo "Error: --project requires a value" >&2; exit 1; }
      project_dir="$2"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

warns=0
fails=0
pass() { echo "  PASS  $*"; }
warn() { echo "  WARN  $*"; warns=$((warns + 1)); }
fail() { echo "  FAIL  $*"; fails=$((fails + 1)); }
same_file() { cmp -s "$1" "$2"; }

check_native_agent() {
  local label="$1"
  local base="$2"
  local check_openai="${3:-false}"
  local skill installed source

  echo ""
  echo "── $label ──────────────────────────────────────────────"

  for skill in "${skills[@]}"; do
    installed="$base/$skill"
    source="$ROOT_DIR/skills/$skill"

    if [[ ! -d "$installed" ]]; then
      warn "$label/$skill: not installed"
      continue
    fi

    if ! is_managed_skill_dir "$installed"; then
      warn "$label/$skill: directory exists but is not AICodeReview-managed"
      continue
    fi

    if [[ ! -f "$installed/SKILL.md" ]]; then
      fail "$label/$skill: installed SKILL.md is missing"
      continue
    fi

    if same_file "$installed/SKILL.md" "$source/SKILL.md"; then
      pass "$label/$skill: SKILL.md is current"
    else
      warn "$label/$skill: SKILL.md is stale"
    fi

    if [[ "$check_openai" == true && -f "$source/agents/openai.yaml" ]]; then
      if [[ ! -f "$installed/agents/openai.yaml" ]]; then
        warn "$label/$skill: agents/openai.yaml is missing"
      elif same_file "$installed/agents/openai.yaml" "$source/agents/openai.yaml"; then
        pass "$label/$skill: agents/openai.yaml is current"
      else
        warn "$label/$skill: agents/openai.yaml is stale"
      fi
    fi
  done
}

check_cursor() {
  local rules_dir="$project_dir/.cursor/rules"
  local skill installed source

  echo ""
  echo "── cursor ───────────────────────────────────────────────"

  for skill in "${skills[@]}"; do
    installed="$rules_dir/$skill.mdc"
    source="$ROOT_DIR/skills/$skill/agents/cursor.mdc"

    if [[ ! -f "$installed" ]]; then
      warn "cursor/$skill: rule is missing"
      continue
    fi

    if ! is_managed_file "$installed"; then
      warn "cursor/$skill: rule exists but is not AICodeReview-managed"
      continue
    fi

    if same_file "$installed" "$source"; then
      pass "cursor/$skill: rule is current"
    else
      warn "cursor/$skill: rule is stale"
    fi
  done
}

check_legacy_removed() {
  local label="$1"
  local file="$2"
  local state

  state="$(managed_section_state "$file" "$LEGACY_SECTION_START" "$LEGACY_SECTION_END")"
  case "$state" in
    managed)
      warn "$label: legacy managed section still exists in $file; rerun install with --force to migrate"
      ;;
    corrupt)
      fail "$label: legacy markers are corrupt in $file"
      ;;
  esac
}

build_expected_aider_file() {
  local output="$1"
  local skill source

  {
    echo "# AICodeReview"
    echo
    echo "Generated review conventions. This file is managed by AICodeReview."
    echo
  } > "$output"

  for skill in "${skills[@]}"; do
    source="$ROOT_DIR/skills/$skill/agents/aider.md"
    cat "$source" >> "$output"
    printf '\n\n' >> "$output"
  done
}

aider_config_references_file() {
  local config_file="$1"
  [[ -f "$config_file" ]] && grep -qF "AICODEREVIEW.md" "$config_file"
}

check_aider() {
  local file="$project_dir/AICODEREVIEW.md"
  local config="$project_dir/.aider.conf.yml"
  local expected state

  echo ""
  echo "── aider ────────────────────────────────────────────────"

  if [[ ! -f "$file" ]]; then
    warn "aider: AICODEREVIEW.md is missing"
  elif ! is_managed_file "$file"; then
    warn "aider: AICODEREVIEW.md exists but is not AICodeReview-managed"
  else
    expected="$(mktemp "${TMPDIR:-/tmp}/aicodereview-aider-health.XXXXXX")"
    build_expected_aider_file "$expected"
    if same_file "$file" "$expected"; then
      pass "aider: AICODEREVIEW.md is current"
    else
      warn "aider: AICODEREVIEW.md is stale"
    fi
    rm -f "$expected"
  fi

  state="$(managed_section_state "$config" "$AIDER_CONFIG_START" "$AIDER_CONFIG_END")"
  if [[ "$state" == "corrupt" ]]; then
    fail "aider: managed read markers are corrupt in $config"
  elif aider_config_references_file "$config"; then
    pass "aider: AICODEREVIEW.md is referenced by .aider.conf.yml"
  else
    warn "aider: AICODEREVIEW.md is not auto-loaded; add it to the read list in .aider.conf.yml"
  fi

  check_legacy_removed "aider" "$project_dir/CONVENTIONS.md"
}

echo "AICodeReview health check"
echo "Source: $ROOT_DIR"

check_native_agent "claude" "${CLAUDE_HOME:-$HOME/.claude}/skills"
check_native_agent "codex" "${CODEX_HOME:-$HOME/.codex}/skills" true

if [[ -n "$project_dir" ]]; then
  if [[ ! -d "$project_dir" ]]; then
    echo "Error: project directory does not exist: $project_dir" >&2
    exit 1
  fi

  check_cursor
  check_native_agent "copilot" "$project_dir/.github/skills"
  check_legacy_removed "copilot" "$project_dir/.github/copilot-instructions.md"
  check_native_agent "gemini" "$project_dir/.gemini/skills"
  check_legacy_removed "gemini" "$project_dir/GEMINI.md"
  check_native_agent "opencode" "$project_dir/.opencode/skills"
  check_aider
else
  echo ""
  echo "Tip: pass --project <path> to also check Cursor, Copilot, Gemini, OpenCode, and Aider."
fi

echo ""
echo "════════════════════════════════"
echo "Health check summary"
echo "════════════════════════════════"
echo "  WARN: $warns"
echo "  FAIL: $fails"

if [[ "$fails" -gt 0 || "$warns" -gt 0 ]]; then
  exit 1
fi

echo "All checks passed."
