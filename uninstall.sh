#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=aicodereview-lib.sh
source "$ROOT_DIR/aicodereview-lib.sh"
load_skills "$ROOT_DIR"

SECTION_START="# >>> AICodeReview START <<<"
SECTION_END="# >>> AICodeReview END <<<"

agent=""
project_dir=""
dry_run=false

usage() {
  cat <<'EOF_USAGE'
Usage: ./uninstall.sh [--agent <agent>] [--project <path>] [--dry-run]

Agents:
  claude   Remove managed skills from ~/.claude/skills/
  codex    Remove managed skills from ~/.codex/skills/
  global   Remove managed claude + codex skills (default)
  cursor   Remove managed rules from <project>/.cursor/rules/
  copilot  Remove the AICodeReview section from copilot-instructions.md
  gemini   Remove the AICodeReview section from GEMINI.md
  aider    Remove the AICodeReview section from CONVENTIONS.md
  all      Remove all current adapters (requires --project)

Safety:
  Native skill directories and Cursor rules are deleted only when an
  AICodeReview ownership marker is present. Unmanaged paths are left untouched.
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
  local skill dest marker

  for skill in "${skills[@]}"; do
    dest="$rules_dir/$skill.mdc"
    marker="${dest}${AICODEREVIEW_CURSOR_MARKER_SUFFIX}"

    if [[ ! -e "$dest" ]]; then
      echo "Not installed: $skill (cursor)"
      continue
    fi

    if ! is_managed_cursor_rule "$dest"; then
      echo "Skipping $dest; it is not marked as an AICodeReview install" >&2
      continue
    fi

    if [[ "$dry_run" == true ]]; then
      echo "Would remove $dest and $marker"
    else
      rm -f "$dest" "$marker"
      echo "Removed $dest"
    fi
  done
}

remove_section() {
  local dest="$1"
  local label="$2"
  local state

  state="$(managed_section_state "$dest" "$SECTION_START" "$SECTION_END")"

  case "$state" in
    absent|unmanaged)
      echo "Not installed: $label ($dest)"
      return 0
      ;;
    corrupt)
      echo "Error: invalid AICodeReview marker state in $dest; refusing to modify it" >&2
      return 1
      ;;
  esac

  if [[ "$dry_run" == true ]]; then
    echo "Would remove AICodeReview section from $dest"
    return 0
  fi

  python3 - "$dest" "$SECTION_START" "$SECTION_END" <<'PYEOF'
import os
import re
import sys
import tempfile

path, start_marker, end_marker = sys.argv[1:]
with open(path, encoding="utf-8") as handle:
    content = handle.read()
pattern = r"\n?" + re.escape(start_marker) + r".*?" + re.escape(end_marker) + r"\n?"
updated, count = re.subn(pattern, "", content, flags=re.DOTALL)
if count != 1:
    raise SystemExit(f"expected one managed section, removed {count}")
updated = updated.strip()
if not updated:
    os.remove(path)
else:
    folder = os.path.dirname(path) or "."
    fd, tmp = tempfile.mkstemp(prefix=".aicodereview-", dir=folder, text=True)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as handle:
            handle.write(updated + "\n")
        os.replace(tmp, path)
    except Exception:
        try:
            os.unlink(tmp)
        except FileNotFoundError:
            pass
        raise
PYEOF
  echo "Removed AICodeReview section from $dest"
}

project_agents=("cursor" "copilot" "gemini" "aider")
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
  remove_section "$project_dir/.github/copilot-instructions.md" "copilot"
  remove_section "$project_dir/GEMINI.md" "gemini"
  remove_section "$project_dir/CONVENTIONS.md" "aider"
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
    remove_section "$project_dir/.github/copilot-instructions.md" "copilot"
    ;;
  gemini)
    remove_section "$project_dir/GEMINI.md" "gemini"
    ;;
  aider)
    remove_section "$project_dir/CONVENTIONS.md" "aider"
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
