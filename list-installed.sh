#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=aicodereview-lib.sh
source "$ROOT_DIR/aicodereview-lib.sh"
load_skills "$ROOT_DIR"

LEGACY_SECTION_START="# >>> AICodeReview START <<<"
LEGACY_SECTION_END="# >>> AICodeReview END <<<"

project_dir=""

usage() {
  cat <<'EOF_USAGE'
Usage: ./list-installed.sh [--project <path>]

Prints AGENT | SKILL | STATUS for every skill discovered under skills/.
Statuses are installed, legacy, unmanaged, or missing.
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

COL_AGENT=10
COL_SKILL=28
COL_STATUS=12
pad() { printf "%-${2}s" "$1"; }
header() {
  echo "$(pad AGENT $COL_AGENT) $(pad SKILL $COL_SKILL) STATUS"
  printf '%*s\n' $((COL_AGENT + COL_SKILL + COL_STATUS + 2)) '' | tr ' ' '-'
}
row() { echo "$(pad "$1" $COL_AGENT) $(pad "$2" $COL_SKILL) $3"; }

native_skill_status() {
  local path="$1"
  if [[ ! -e "$path" ]]; then
    printf 'missing'
  elif is_managed_skill_dir "$path"; then
    printf 'installed'
  else
    printf 'unmanaged'
  fi
}

check_native_agent() {
  local label="$1"
  local base="$2"
  local legacy_file="${3:-}"
  local legacy_state="absent"
  local skill status

  if [[ -n "$legacy_file" ]]; then
    legacy_state="$(managed_section_state "$legacy_file" "$LEGACY_SECTION_START" "$LEGACY_SECTION_END")"
  fi

  for skill in "${skills[@]}"; do
    status="$(native_skill_status "$base/$skill")"
    if [[ "$status" == "missing" && "$legacy_state" == "managed" ]]; then
      status="legacy"
    elif [[ "$status" == "missing" && "$legacy_state" == "corrupt" ]]; then
      status="unmanaged"
    fi
    row "$label" "$skill" "$status"
  done
}

check_cursor() {
  local rules_dir="$project_dir/.cursor/rules"
  local skill path

  for skill in "${skills[@]}"; do
    path="$rules_dir/$skill.mdc"
    if [[ ! -e "$path" ]]; then
      row "cursor" "$skill" "missing"
    elif is_managed_file "$path"; then
      row "cursor" "$skill" "installed"
    else
      row "cursor" "$skill" "unmanaged"
    fi
  done
}

check_aider() {
  local file="$project_dir/AICODEREVIEW.md"
  local legacy_state status skill

  legacy_state="$(managed_section_state "$project_dir/CONVENTIONS.md" "$LEGACY_SECTION_START" "$LEGACY_SECTION_END")"

  if [[ ! -e "$file" ]]; then
    if [[ "$legacy_state" == "managed" ]]; then
      status="legacy"
    elif [[ "$legacy_state" == "corrupt" ]]; then
      status="unmanaged"
    else
      status="missing"
    fi
  elif is_managed_file "$file"; then
    status="installed"
  else
    status="unmanaged"
  fi

  for skill in "${skills[@]}"; do
    if [[ "$status" == "installed" ]] && ! grep -qF "$skill" "$file"; then
      row "aider" "$skill" "missing"
    else
      row "aider" "$skill" "$status"
    fi
  done
}

header
check_native_agent "claude" "${CLAUDE_HOME:-$HOME/.claude}/skills"
check_native_agent "codex" "${CODEX_HOME:-$HOME/.codex}/skills"

if [[ -n "$project_dir" ]]; then
  if [[ ! -d "$project_dir" ]]; then
    echo "Error: project directory does not exist: $project_dir" >&2
    exit 1
  fi

  check_cursor
  check_native_agent "copilot" "$project_dir/.github/skills" "$project_dir/.github/copilot-instructions.md"
  check_native_agent "gemini" "$project_dir/.gemini/skills" "$project_dir/GEMINI.md"
  check_native_agent "opencode" "$project_dir/.opencode/skills"
  check_aider
else
  echo ""
  echo "Tip: pass --project <path> to include Cursor, Copilot, Gemini, OpenCode, and Aider."
fi
