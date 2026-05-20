#!/usr/bin/env bash
set -euo pipefail

# check-health.sh — verify installed skills match source and combined files are intact

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

project_dir=""

usage() {
  cat <<'EOF'
Usage: ./check-health.sh [--project <path>]

Options:
  --project <path>   Also check cursor, copilot, gemini, and aider in this project dir.
  --help             Show this help message.

Checks performed:
  1. For claude and codex: SKILL.md in installed dir matches SKILL.md in source
     (md5 comparison). A mismatch means the install is stale — run update.sh.
  2. For copilot, gemini, and aider combined files: the AICodeReview section
     markers are present.
  3. For cursor: each .mdc file matches its source.

Output:
  PASS / WARN / FAIL per check.
  Exits non-zero if any check is FAIL or WARN.
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
SECTION_END="# >>> AICodeReview END <<<"

CLAUDE_SKILLS="${CLAUDE_HOME:-$HOME/.claude}/skills"
CODEX_SKILLS="${CODEX_HOME:-$HOME/.codex}/skills"

warns=0
fails=0

# ── Helpers ───────────────────────────────────────────────────────────────────

md5_of() {
  if command -v md5sum &>/dev/null; then
    md5sum "$1" | awk '{print $1}'
  else
    md5 -q "$1"
  fi
}

pass()  { echo "  PASS  $*"; }
warn()  { echo "  WARN  $*"; warns=$((warns + 1)); }
fail()  { echo "  FAIL  $*"; fails=$((fails + 1)); }

# ── Check global agent (claude / codex) ───────────────────────────────────────

check_global() {
  local label="$1"
  local base="$2"

  echo ""
  echo "── $label ──────────────────────────────────────────────"

  for skill in "${skills[@]}"; do
    local installed="$base/$skill/SKILL.md"
    local source="$ROOT_DIR/skills/$skill/SKILL.md"

    if [[ ! -f "$installed" ]]; then
      warn "$label/$skill: not installed (SKILL.md missing)"
      continue
    fi

    local h_installed h_source
    h_installed="$(md5_of "$installed")"
    h_source="$(md5_of "$source")"

    if [[ "$h_installed" == "$h_source" ]]; then
      pass "$label/$skill: SKILL.md up to date"
    else
      warn "$label/$skill: SKILL.md is stale (run ./update.sh)"
    fi
  done
}

# ── Check cursor .mdc files ────────────────────────────────────────────────────

check_cursor() {
  local rules_dir="$project_dir/.cursor/rules"

  echo ""
  echo "── cursor ───────────────────────────────────────────────"

  if [[ ! -d "$rules_dir" ]]; then
    warn "cursor: rules directory not found ($rules_dir)"
    return
  fi

  for skill in "${skills[@]}"; do
    local installed="$rules_dir/$skill.mdc"
    local source="$ROOT_DIR/skills/$skill/agents/cursor.mdc"

    if [[ ! -f "$installed" ]]; then
      warn "cursor/$skill: not installed (.mdc missing)"
      continue
    fi

    local h_installed h_source
    h_installed="$(md5_of "$installed")"
    h_source="$(md5_of "$source")"

    if [[ "$h_installed" == "$h_source" ]]; then
      pass "cursor/$skill: .mdc up to date"
    else
      warn "cursor/$skill: .mdc is stale (run ./update.sh --project <path>)"
    fi
  done
}

# ── Check combined file has section markers ───────────────────────────────────

check_combined_file() {
  local label="$1"
  local file="$2"

  echo ""
  echo "── $label ───────────────────────────────────────────────"

  if [[ ! -f "$file" ]]; then
    warn "$label: combined file not found ($file)"
    return
  fi

  if ! grep -qF "$SECTION_START" "$file"; then
    fail "$label: AICodeReview section START marker missing in $file"
    return
  fi

  if ! grep -qF "$SECTION_END" "$file"; then
    fail "$label: AICodeReview section END marker missing in $file"
    return
  fi

  pass "$label: section markers present in $file"

  # Warn if the section content looks truncated (END marker before START)
  local start_line end_line
  start_line="$(grep -n "$SECTION_START" "$file" | head -1 | cut -d: -f1)"
  end_line="$(grep -n "$SECTION_END"   "$file" | head -1 | cut -d: -f1)"

  if [[ "$end_line" -le "$start_line" ]]; then
    fail "$label: section END appears before START — file may be corrupted"
  else
    pass "$label: section markers are in correct order"
  fi
}

# ── Run checks ────────────────────────────────────────────────────────────────

echo "AICodeReview health check"
echo "Source: $ROOT_DIR"
echo ""

check_global "claude" "$CLAUDE_SKILLS"
check_global "codex"  "$CODEX_SKILLS"

if [[ -n "$project_dir" ]]; then
  if [[ ! -d "$project_dir" ]]; then
    echo "Error: project directory does not exist: $project_dir" >&2
    exit 1
  fi
  check_cursor
  check_combined_file "copilot" "$project_dir/.github/copilot-instructions.md"
  check_combined_file "gemini"  "$project_dir/GEMINI.md"
  check_combined_file "aider"   "$project_dir/CONVENTIONS.md"
else
  echo ""
  echo "Tip: pass --project <path> to also check cursor, copilot, gemini, and aider."
fi

# ── Summary ───────────────────────────────────────────────────────────────────

echo ""
echo "════════════════════════════════"
echo "Health check summary"
echo "════════════════════════════════"
echo "  WARN: $warns"
echo "  FAIL: $fails"

if [[ "$fails" -gt 0 ]]; then
  echo ""
  echo "One or more checks FAILED. Review output above."
  exit 1
elif [[ "$warns" -gt 0 ]]; then
  echo ""
  echo "Some installs are stale. Run ./update.sh to refresh."
  exit 1
else
  echo ""
  echo "All checks passed."
fi
