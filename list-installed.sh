#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=aicodereview-lib.sh
source "$ROOT_DIR/aicodereview-lib.sh"
load_skills "$ROOT_DIR"

SECTION_START="# >>> AICodeReview START <<<"
SECTION_END="# >>> AICodeReview END <<<"

project_dir=""

usage() {
  cat <<'EOF_USAGE'
Usage: ./list-installed.sh [--project <path>]

Prints AGENT | SKILL | STATUS for every skill discovered under skills/.
Statuses are installed, unmanaged, or missing.
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

check_native_agent() {
  local label="$1"
  local base="$2"
  local skill path

  for skill in "${skills[@]}"; do
    path="$base/$skill"
    if [[ ! -e "$path" ]]; then
      row "$label" "$skill" "missing"
    elif is_managed_skill_dir "$path"; then
      row "$label" "$skill" "installed"
    else
      row "$label" "$skill" "unmanaged"
    fi
  done
}

check_cursor() {
  local rules_dir="$project_dir/.cursor/rules"
  local skill path

  for skill in "${skills[@]}"; do
    path="$rules_dir/$skill.mdc"
    if [[ ! -e "$path" ]]; then
      row "cursor" "$skill" "missing"
    elif is_managed_cursor_rule "$path"; then
      row "cursor" "$skill" "installed"
    else
      row "cursor" "$skill" "unmanaged"
    fi
  done
}

check_combined() {
  local label="$1"
  local file="$2"
  local state section skill

  state="$(managed_section_state "$file" "$SECTION_START" "$SECTION_END")"
  if [[ "$state" != "managed" ]]; then
    for skill in "${skills[@]}"; do
      row "$label" "$skill" "$([[ "$state" == "unmanaged" || "$state" == "corrupt" ]] && echo unmanaged || echo missing)"
    done
    return
  fi

  section="$(mktemp "${TMPDIR:-/tmp}/aicodereview-list.XXXXXX")"
  awk -v start="$SECTION_START" -v end="$SECTION_END" '
    $0 == start { capture=1 }
    capture { print }
    $0 == end { exit }
  ' "$file" > "$section"

  for skill in "${skills[@]}"; do
    if grep -qF "$skill" "$section"; then
      row "$label" "$skill" "installed"
    else
      row "$label" "$skill" "missing"
    fi
  done
  rm -f "$section"
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
  check_combined "copilot" "$project_dir/.github/copilot-instructions.md"
  check_combined "gemini" "$project_dir/GEMINI.md"
  check_combined "aider" "$project_dir/CONVENTIONS.md"
else
  echo ""
  echo "Tip: pass --project <path> to include Cursor, Copilot, Gemini, and Aider."
fi
