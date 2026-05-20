#!/usr/bin/env bash
set -euo pipefail

# update.sh — pull latest and reinstall for detected agents

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

project_dir=""
dry_run=false

usage() {
  cat <<'EOF'
Usage: ./update.sh [--project <path>] [--dry-run]

Options:
  --project <path>   Required for cursor, copilot, gemini, and aider detection.
  --dry-run          Show what would happen without writing files.
  --help             Show this help message.

Description:
  Pulls the latest changes from git and re-runs install.sh for every
  agent that is currently detected as installed.

  Detection logic:
    claude   ~/.claude/skills/code-review/SKILL.md exists
    codex    ~/.codex/skills/code-review/SKILL.md exists
    cursor   <project>/.cursor/rules/code-review.mdc exists
    copilot  <project>/.github/copilot-instructions.md contains AICodeReview section
    gemini   <project>/GEMINI.md contains AICodeReview section
    aider    <project>/CONVENTIONS.md contains AICodeReview section
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project)
      project_dir="${2:-}"
      shift 2
      ;;
    --dry-run)
      dry_run=true
      shift
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

SECTION_START="# >>> AICodeReview START <<<"
PROBE_SKILL="code-review"

# ── 1. Pull latest ───────────────────────────────────────────────────────────

cd "$ROOT_DIR"

if [[ "$dry_run" == true ]]; then
  echo "[dry-run] Would run: git pull origin main"
else
  echo "Pulling latest from origin main..."
  git pull origin main
  echo ""
fi

# ── 2. Detect installed agents ───────────────────────────────────────────────

detected_agents=()

CLAUDE_SKILLS="${CLAUDE_HOME:-$HOME/.claude}/skills"
CODEX_SKILLS="${CODEX_HOME:-$HOME/.codex}/skills"

[[ -f "$CLAUDE_SKILLS/$PROBE_SKILL/SKILL.md" ]] && detected_agents+=("claude")
[[ -f "$CODEX_SKILLS/$PROBE_SKILL/SKILL.md" ]]  && detected_agents+=("codex")

if [[ -n "$project_dir" ]]; then
  [[ -f "$project_dir/.cursor/rules/$PROBE_SKILL.mdc" ]] && detected_agents+=("cursor")

  if [[ -f "$project_dir/.github/copilot-instructions.md" ]]; then
    grep -qF "$SECTION_START" "$project_dir/.github/copilot-instructions.md" \
      && detected_agents+=("copilot")
  fi

  if [[ -f "$project_dir/GEMINI.md" ]]; then
    grep -qF "$SECTION_START" "$project_dir/GEMINI.md" \
      && detected_agents+=("gemini")
  fi

  if [[ -f "$project_dir/CONVENTIONS.md" ]]; then
    grep -qF "$SECTION_START" "$project_dir/CONVENTIONS.md" \
      && detected_agents+=("aider")
  fi
fi

# ── 3. Report detection ──────────────────────────────────────────────────────

if [[ "${#detected_agents[@]}" -eq 0 ]]; then
  echo "No installed agents detected."
  if [[ -z "$project_dir" ]]; then
    echo "Tip: pass --project <path> to detect cursor, copilot, gemini, and aider."
  fi
  exit 0
fi

echo "Detected agents: ${detected_agents[*]}"
echo ""

# ── 4. Reinstall for each detected agent ─────────────────────────────────────

project_flags=()
[[ -n "$project_dir" ]] && project_flags=("--project" "$project_dir")
dry_flags=()
[[ "$dry_run" == true ]] && dry_flags=("--dry-run")

updated=()
failed=()

for ag in "${detected_agents[@]}"; do
  echo "── Reinstalling: $ag ──"

  install_args=("--agent" "$ag" "--force" "${project_flags[@]+"${project_flags[@]}"}" "${dry_flags[@]+"${dry_flags[@]}"}")

  if "$ROOT_DIR/install.sh" "${install_args[@]}"; then
    updated+=("$ag")
  else
    failed+=("$ag")
    echo "ERROR: install failed for agent '$ag'" >&2
  fi

  echo ""
done

# ── 5. Summary ───────────────────────────────────────────────────────────────

echo "════════════════════════════════"
echo "Update summary"
echo "════════════════════════════════"

if [[ "${#updated[@]}" -gt 0 ]]; then
  for ag in "${updated[@]}"; do
    echo "  OK   $ag"
  done
fi

if [[ "${#failed[@]}" -gt 0 ]]; then
  for ag in "${failed[@]}"; do
    echo "  FAIL $ag"
  done
fi

echo ""
if [[ "$dry_run" == true ]]; then
  echo "Dry run complete. No files were changed."
elif [[ "${#failed[@]}" -gt 0 ]]; then
  echo "Update finished with ${#failed[@]} failure(s). Check output above."
  exit 1
else
  echo "All agents updated successfully."
fi
