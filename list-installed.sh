#!/usr/bin/env bash
set -euo pipefail

# list-installed.sh — show which skills are installed for each agent

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

project_dir=""

usage() {
  cat <<'EOF'
Usage: ./list-installed.sh [--project <path>]

Options:
  --project <path>   Check cursor, copilot, gemini, and aider installs in this project dir.
  --help             Show this help message.

Output:
  Prints a table: AGENT | SKILL | STATUS
  STATUS is "installed" or "missing".
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project)
      project_dir="${2:-}"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

skills=(
  "code-review"
  "security-audit"
  "codebase-explainer"
  "review-fixer"
  "android-review"
  "ios-review"
  "web-review"
  "release-review"
  "pr-summary"
  "context-writer"
  "changelog-writer"
  "dependency-audit"
  "agent-config-review"
  "backend-review"
  "performance-review"
  "accessibility-audit"
  "database-review"
  "test-writer"
  "kmp-review"
  "docker-review"
  "ci-review"
  "api-design-review"
  "flutter-review"
  "refactor-planner"
)

SECTION_START="# >>> AICodeReview START <<<"

CLAUDE_SKILLS="${CLAUDE_HOME:-$HOME/.claude}/skills"
CODEX_SKILLS="${CODEX_HOME:-$HOME/.codex}/skills"

COL_AGENT=10
COL_SKILL=26
COL_STATUS=12

pad() {
  local str="$1"
  local width="$2"
  printf "%-${width}s" "$str"
}

header() {
  echo "$(pad AGENT $COL_AGENT) $(pad SKILL $COL_SKILL) STATUS"
  echo "$(printf '%.0s-' $(seq 1 $((COL_AGENT + COL_SKILL + COL_STATUS + 2))))"
}

row() {
  local agent="$1"
  local skill="$2"
  local status="$3"
  echo "$(pad "$agent" $COL_AGENT) $(pad "$skill" $COL_SKILL) $status"
}

# ── Check global agents (claude, codex) ──────────────────────────────────────

check_global() {
  local label="$1"
  local base="$2"

  for skill in "${skills[@]}"; do
    local path="$base/$skill/SKILL.md"
    if [[ -f "$path" ]]; then
      row "$label" "$skill" "installed"
    else
      row "$label" "$skill" "missing"
    fi
  done
}

# ── Check cursor ──────────────────────────────────────────────────────────────

check_cursor() {
  local rules_dir="$project_dir/.cursor/rules"
  for skill in "${skills[@]}"; do
    local path="$rules_dir/$skill.mdc"
    if [[ -f "$path" ]]; then
      row "cursor" "$skill" "installed"
    else
      row "cursor" "$skill" "missing"
    fi
  done
}

# ── Check combined-file agents (copilot, gemini, aider) ──────────────────────
# These combine all skills into one file; we only check the section marker once.

check_combined() {
  local label="$1"
  local file="$2"

  if [[ -f "$file" ]] && grep -qF "$SECTION_START" "$file"; then
    for skill in "${skills[@]}"; do
      # Search for the skill name within the AICodeReview section as a proxy
      if grep -qF "$skill" "$file"; then
        row "$label" "$skill" "installed"
      else
        row "$label" "$skill" "missing"
      fi
    done
  else
    for skill in "${skills[@]}"; do
      row "$label" "$skill" "missing"
    done
  fi
}

# ── Print table ───────────────────────────────────────────────────────────────

header

check_global "claude" "$CLAUDE_SKILLS"
check_global "codex"  "$CODEX_SKILLS"

if [[ -n "$project_dir" ]]; then
  if [[ ! -d "$project_dir" ]]; then
    echo "Error: project directory does not exist: $project_dir" >&2
    exit 1
  fi
  check_cursor
  check_combined "copilot" "$project_dir/.github/copilot-instructions.md"
  check_combined "gemini"  "$project_dir/GEMINI.md"
  check_combined "aider"   "$project_dir/CONVENTIONS.md"
else
  echo ""
  echo "Tip: pass --project <path> to also check cursor, copilot, gemini, and aider."
fi
