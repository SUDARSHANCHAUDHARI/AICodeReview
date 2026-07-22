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
Usage: ./check-health.sh [--project <path>]

Checks managed Claude, Codex, Cursor, Copilot, Gemini, and Aider adapters.
The command reports unmanaged conflicts, stale files, missing ownership markers,
and corrupt combined-file marker sections.
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

same_file() {
  cmp -s "$1" "$2"
}

check_native_agent() {
  local label="$1"
  local base="$2"
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

    if [[ -f "$source/agents/openai.yaml" ]]; then
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

  if [[ ! -d "$rules_dir" ]]; then
    warn "cursor: rules directory not found ($rules_dir)"
    return
  fi

  for skill in "${skills[@]}"; do
    installed="$rules_dir/$skill.mdc"
    source="$ROOT_DIR/skills/$skill/agents/cursor.mdc"

    if [[ ! -f "$installed" ]]; then
      warn "cursor/$skill: rule is missing"
      continue
    fi

    if ! is_managed_cursor_rule "$installed"; then
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

build_expected_section() {
  local agent_file="$1"
  local output="$2"
  local skill source

  : > "$output"
  printf '%s\n\n' "$SECTION_START" >> "$output"
  for skill in "${skills[@]}"; do
    source="$ROOT_DIR/skills/$skill/agents/$agent_file"
    cat "$source" >> "$output"
    printf '\n\n' >> "$output"
  done
  printf '%s\n' "$SECTION_END" >> "$output"
}

check_combined_file() {
  local label="$1"
  local file="$2"
  local agent_file="$3"
  local state expected actual

  echo ""
  echo "── $label ───────────────────────────────────────────────"

  state="$(managed_section_state "$file" "$SECTION_START" "$SECTION_END")"
  case "$state" in
    absent)
      warn "$label: file not found ($file)"
      return
      ;;
    unmanaged)
      warn "$label: file exists without an AICodeReview section"
      return
      ;;
    corrupt)
      fail "$label: managed section markers are corrupt"
      return
      ;;
  esac

  expected="$(mktemp "${TMPDIR:-/tmp}/aicodereview-expected.XXXXXX")"
  actual="$(mktemp "${TMPDIR:-/tmp}/aicodereview-actual.XXXXXX")"
  build_expected_section "$agent_file" "$expected"

  awk -v start="$SECTION_START" -v end="$SECTION_END" '
    $0 == start { capture=1 }
    capture { print }
    $0 == end { exit }
  ' "$file" > "$actual"

  if same_file "$actual" "$expected"; then
    pass "$label: managed section is current"
  else
    warn "$label: managed section is stale"
  fi

  rm -f "$expected" "$actual"
}

echo "AICodeReview health check"
echo "Source: $ROOT_DIR"

check_native_agent "claude" "${CLAUDE_HOME:-$HOME/.claude}/skills"
check_native_agent "codex" "${CODEX_HOME:-$HOME/.codex}/skills"

if [[ -n "$project_dir" ]]; then
  if [[ ! -d "$project_dir" ]]; then
    echo "Error: project directory does not exist: $project_dir" >&2
    exit 1
  fi
  check_cursor
  check_combined_file "copilot" "$project_dir/.github/copilot-instructions.md" "copilot.md"
  check_combined_file "gemini" "$project_dir/GEMINI.md" "gemini.md"
  check_combined_file "aider" "$project_dir/CONVENTIONS.md" "aider.md"
else
  echo ""
  echo "Tip: pass --project <path> to also check Cursor, Copilot, Gemini, and Aider."
fi

echo ""
echo "════════════════════════════════"
echo "Health check summary"
echo "════════════════════════════════"
echo "  WARN: $warns"
echo "  FAIL: $fails"

if [[ "$fails" -gt 0 ]]; then
  exit 1
elif [[ "$warns" -gt 0 ]]; then
  exit 1
fi

echo "All checks passed."
