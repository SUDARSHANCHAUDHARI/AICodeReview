#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=aicodereview-lib.sh
source "$ROOT_DIR/aicodereview-lib.sh"

project_dir=""
dry_run=false

usage() {
  cat <<'EOF_USAGE'
Usage: ./update.sh [--project <path>] [--dry-run]

Options:
  --project <path>   Include project-scoped adapters in detection.
  --dry-run          Show what would happen without writing files.
  --help             Show this help message.

Detection supports native paths, selective Aider skills, and legacy managed
sections so existing integrations migrate during update.
EOF_USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project)
      [[ $# -ge 2 ]] || { echo "Error: --project requires a value" >&2; exit 1; }
      project_dir="$2"
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

LEGACY_SECTION_START="# >>> AICodeReview START <<<"
LEGACY_SECTION_END="# >>> AICodeReview END <<<"
PROBE_SKILL="code-review"

cd "$ROOT_DIR"

if [[ "$dry_run" == true ]]; then
  echo "[dry-run] Would run: git pull origin main"
else
  echo "Pulling latest from origin main..."
  git pull origin main
  echo ""
fi

detected_agents=()
CLAUDE_SKILLS="${CLAUDE_HOME:-$HOME/.claude}/skills"
CODEX_SKILLS="${CODEX_HOME:-$HOME/.codex}/skills"

[[ -f "$CLAUDE_SKILLS/$PROBE_SKILL/SKILL.md" ]] && detected_agents+=("claude")
[[ -f "$CODEX_SKILLS/$PROBE_SKILL/SKILL.md" ]] && detected_agents+=("codex")

legacy_is_managed() {
  [[ "$(managed_section_state "$1" "$LEGACY_SECTION_START" "$LEGACY_SECTION_END")" == "managed" ]]
}

if [[ -n "$project_dir" ]]; then
  [[ -f "$project_dir/.cursor/rules/$PROBE_SKILL.mdc" ]] && detected_agents+=("cursor")

  if [[ -f "$project_dir/.github/skills/$PROBE_SKILL/SKILL.md" ]] || \
     legacy_is_managed "$project_dir/.github/copilot-instructions.md"; then
    detected_agents+=("copilot")
  fi

  if [[ -f "$project_dir/.gemini/skills/$PROBE_SKILL/SKILL.md" ]] || \
     legacy_is_managed "$project_dir/GEMINI.md"; then
    detected_agents+=("gemini")
  fi

  [[ -f "$project_dir/.opencode/skills/$PROBE_SKILL/SKILL.md" ]] && detected_agents+=("opencode")

  if [[ -f "$project_dir/AICODEREVIEW.md" ]] || \
     [[ -f "$project_dir/.aicodereview/skills/$PROBE_SKILL/SKILL.md" ]] || \
     legacy_is_managed "$project_dir/CONVENTIONS.md"; then
    detected_agents+=("aider")
  fi
fi

if [[ "${#detected_agents[@]}" -eq 0 ]]; then
  echo "No installed agents detected."
  if [[ -z "$project_dir" ]]; then
    echo "Tip: pass --project <path> to detect project-scoped adapters."
  fi
  exit 0
fi

echo "Detected agents: ${detected_agents[*]}"
echo ""

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

echo "════════════════════════════════"
echo "Update summary"
echo "════════════════════════════════"

for ag in "${updated[@]}"; do
  echo "  OK   $ag"
done
for ag in "${failed[@]}"; do
  echo "  FAIL $ag"
done

echo ""
if [[ "$dry_run" == true ]]; then
  echo "Dry run complete. No files were changed."
elif [[ "${#failed[@]}" -gt 0 ]]; then
  echo "Update finished with ${#failed[@]} failure(s). Check output above."
  exit 1
else
  echo "All detected agents updated successfully."
fi
