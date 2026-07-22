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

agent=""
project_dir=""
dry_run=false

usage() {
  cat <<'EOF_USAGE'
Usage: ./uninstall.sh [--agent <agent>] [--project <path>] [--dry-run]

Agents:
  claude    Remove managed skills from ~/.claude/skills/
  codex     Remove managed skills from ~/.codex/skills/
  global    Remove managed claude + codex skills (default)
  cursor    Remove managed project rules from <project>/.cursor/rules/
  copilot   Remove managed native skills from <project>/.github/skills/
  gemini    Remove managed native skills from <project>/.gemini/skills/
  opencode  Remove managed native skills from <project>/.opencode/skills/
  aider     Remove managed Aider catalog, selective skills, and managed config
  all       Remove every current adapter (requires --project)

Safety:
  Native skill directories and generated files are deleted only when an
  AICodeReview ownership marker is present. User-managed files are preserved.
EOF_USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent)
      [[ $# -ge 2 ]] || { echo "Error: --agent requires a value" >&2; exit 1; }
      agent="$2"
      shift 2
      ;;
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

[[ -z "$agent" ]] && agent="global"

remove_native_agent() {
  local dest_base="$1"
  local label="$2"
  local skill

  for skill in "${skills[@]}"; do
    remove_managed_skill_directory "$dest_base/$skill" "$skill" "$label" "$dry_run"
  done
}

remove_cursor() {
  local rules_dir="$project_dir/.cursor/rules"
  local skill dest

  for skill in "${skills[@]}"; do
    dest="$rules_dir/$skill.mdc"
    remove_managed_file "$dest" "Cursor rule $skill" "$dry_run"
  done
}

remove_legacy_section() {
  local dest="$1"
  local label="$2"

  remove_managed_section \
    "$dest" \
    "$LEGACY_SECTION_START" \
    "$LEGACY_SECTION_END" \
    "$label" \
    "$dry_run"
}

remove_copilot() {
  remove_native_agent "$project_dir/.github/skills" "copilot"
  remove_legacy_section "$project_dir/.github/copilot-instructions.md" "legacy Copilot instructions"
}

remove_gemini() {
  remove_native_agent "$project_dir/.gemini/skills" "gemini"
  remove_legacy_section "$project_dir/GEMINI.md" "legacy Gemini context"
}

remove_opencode() {
  remove_native_agent "$project_dir/.opencode/skills" "opencode"
}

remove_aider() {
  remove_native_agent "$project_dir/.aicodereview/skills" "aider"
  remove_managed_file "$project_dir/AICODEREVIEW.md" "Aider workflow catalog" "$dry_run"
  remove_managed_section \
    "$project_dir/.aider.conf.yml" \
    "$AIDER_CONFIG_START" \
    "$AIDER_CONFIG_END" \
    "managed Aider read configuration" \
    "$dry_run"
  remove_legacy_section "$project_dir/CONVENTIONS.md" "legacy Aider conventions"

  if [[ "$dry_run" == false ]]; then
    rmdir "$project_dir/.aicodereview/skills" 2>/dev/null || true
    rmdir "$project_dir/.aicodereview" 2>/dev/null || true
  fi

  if [[ -f "$project_dir/.aider.conf.yml" ]] && grep -qF "AICODEREVIEW.md" "$project_dir/.aider.conf.yml"; then
    echo "Note: user-managed .aider.conf.yml content still references AICODEREVIEW.md and was left unchanged."
  fi
}

project_agents=("cursor" "copilot" "gemini" "opencode" "aider")
requires_project=false
for project_agent in "${project_agents[@]}"; do
  if [[ "$agent" == "$project_agent" || "$agent" == "all" ]]; then
    requires_project=true
    break
  fi
done

if [[ "$requires_project" == true && -z "$project_dir" ]]; then
  echo "Error: --project <path> is required for agent '$agent'" >&2
  exit 1
fi

if [[ -n "$project_dir" && ! -d "$project_dir" ]]; then
  echo "Error: project directory does not exist: $project_dir" >&2
  exit 1
fi

run_project_agents() {
  remove_cursor
  remove_copilot
  remove_gemini
  remove_opencode
  remove_aider
}

case "$agent" in
  global)
    remove_native_agent "${CODEX_HOME:-$HOME/.codex}/skills" "codex"
    remove_native_agent "${CLAUDE_HOME:-$HOME/.claude}/skills" "claude"
    ;;
  codex)
    remove_native_agent "${CODEX_HOME:-$HOME/.codex}/skills" "codex"
    ;;
  claude)
    remove_native_agent "${CLAUDE_HOME:-$HOME/.claude}/skills" "claude"
    ;;
  cursor)
    remove_cursor
    ;;
  copilot)
    remove_copilot
    ;;
  gemini)
    remove_gemini
    ;;
  opencode)
    remove_opencode
    ;;
  aider)
    remove_aider
    ;;
  all)
    remove_native_agent "${CODEX_HOME:-$HOME/.codex}/skills" "codex"
    remove_native_agent "${CLAUDE_HOME:-$HOME/.claude}/skills" "claude"
    run_project_agents
    ;;
  *)
    echo "Unknown agent: $agent" >&2
    usage >&2
    exit 1
    ;;
esac

if [[ "$dry_run" == true ]]; then
  echo "Dry run complete. No files were changed."
fi
