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
force=false

usage() {
  cat <<'EOF_USAGE'
Usage: ./install.sh [--agent <agent>] [--project <path>] [--dry-run] [--force]

Agents:
  claude   Install native skills to ~/.claude/skills/
  codex    Install native skills to ~/.codex/skills/
  global   Install claude + codex (default when no --agent is given)
  cursor   Install project rules to <project>/.cursor/rules/ (requires --project)
  copilot  Install legacy combined instructions to <project>/.github/copilot-instructions.md
  gemini   Install legacy combined context to <project>/GEMINI.md
  aider    Install conventions to <project>/CONVENTIONS.md
  all      Install all current adapters (requires --project)

Options:
  --agent <agent>    Agent to install for (default: global)
  --project <path>   Target project directory for project-scoped adapters
  --dry-run          Show what would happen without writing files
  --force            Update managed installs; back up unmanaged conflicts before replacement
  --help             Show this help message

Safety:
  - Native skill directories and Cursor rules are marked as AICodeReview-managed.
  - --force never silently deletes an unmanaged conflicting path; it creates a timestamped backup.
  - Combined files are changed only when their managed marker pair is valid.
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
    --force)
      force=true
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

install_native_agent() {
  local dest_base="$1"
  local label="$2"

  if [[ "$dry_run" == false ]]; then
    mkdir -p "$dest_base"
  fi

  local skill
  for skill in "${skills[@]}"; do
    install_skill_directory \
      "$ROOT_DIR/skills/$skill" \
      "$dest_base/$skill" \
      "$skill" \
      "$label" \
      "$force" \
      "$dry_run"
  done
}

install_cursor() {
  local rules_dir="$project_dir/.cursor/rules"

  if [[ "$dry_run" == false ]]; then
    mkdir -p "$rules_dir"
  fi

  local skill src dest marker tmp old_path old_marker keep_old
  for skill in "${skills[@]}"; do
    src="$ROOT_DIR/skills/$skill/agents/cursor.mdc"
    dest="$rules_dir/$skill.mdc"
    marker="${dest}${AICODEREVIEW_CURSOR_MARKER_SUFFIX}"

    if [[ ! -f "$src" ]]; then
      echo "Missing cursor config: $src" >&2
      exit 1
    fi

    if [[ -e "$dest" && "$force" == false ]]; then
      if is_managed_cursor_rule "$dest"; then
        echo "Skipping $skill (cursor); already installed (use --force to update)"
      else
        echo "Skipping $skill (cursor); destination exists and is not managed by AICodeReview"
      fi
      continue
    fi

    if [[ "$dry_run" == true ]]; then
      if [[ -e "$dest" ]] && ! is_managed_cursor_rule "$dest"; then
        echo "Would back up unmanaged $dest and install $skill -> $dest"
      elif [[ -e "$dest" ]]; then
        echo "Would update $skill -> $dest"
      else
        echo "Would install $skill -> $dest"
      fi
      continue
    fi

    tmp="${dest}.aicodereview-tmp-$$"
    cp "$src" "$tmp"
    old_path=""
    old_marker=""
    keep_old=false

    if [[ -e "$dest" ]]; then
      if is_managed_cursor_rule "$dest"; then
        old_path="${dest}.aicodereview-old-$$"
        old_marker="${marker}.old-$$"
        mv "$dest" "$old_path"
        mv "$marker" "$old_marker"
      else
        old_path="$(next_backup_path "$dest")"
        keep_old=true
        mv "$dest" "$old_path"
      fi
    fi

    if ! mv "$tmp" "$dest"; then
      rm -f "$tmp"
      [[ -n "$old_path" && -e "$old_path" ]] && mv "$old_path" "$dest"
      [[ -n "$old_marker" && -e "$old_marker" ]] && mv "$old_marker" "$marker"
      echo "Failed to install $skill -> $dest; previous content restored" >&2
      exit 1
    fi

    write_managed_cursor_marker "$dest" "$skill"

    if [[ -n "$old_path" ]]; then
      if [[ "$keep_old" == true ]]; then
        echo "Backed up unmanaged destination -> $old_path"
      else
        rm -f "$old_path" "$old_marker"
      fi
    fi

    echo "Installed $skill -> $dest"
  done
}

build_combined_section() {
  local agent_file="$1"
  local output_file="$2"
  local skill src

  : > "$output_file"
  printf '%s\n\n' "$SECTION_START" >> "$output_file"

  for skill in "${skills[@]}"; do
    src="$ROOT_DIR/skills/$skill/agents/$agent_file"
    if [[ ! -f "$src" ]]; then
      echo "Missing $agent_file for $skill" >&2
      return 1
    fi
    cat "$src" >> "$output_file"
    printf '\n\n' >> "$output_file"
  done

  printf '%s\n' "$SECTION_END" >> "$output_file"
}

install_combined() {
  local agent_file="$1"
  local dest="$2"
  local state section_file

  state="$(managed_section_state "$dest" "$SECTION_START" "$SECTION_END")"
  if [[ "$state" == "corrupt" ]]; then
    echo "Error: invalid AICodeReview marker state in $dest; refusing to modify it" >&2
    return 1
  fi

  section_file="$(mktemp "${TMPDIR:-/tmp}/aicodereview-section.XXXXXX")"
  build_combined_section "$agent_file" "$section_file"

  if [[ "$dry_run" == true ]]; then
    echo "Would write $agent_file section -> $dest ($state)"
    rm -f "$section_file"
    return 0
  fi

  mkdir -p "$(dirname "$dest")"

  if [[ "$state" == "absent" ]]; then
    cp "$section_file" "$dest"
    echo "Installed $agent_file section -> $dest"
  elif [[ "$state" == "unmanaged" ]]; then
    printf '\n' >> "$dest"
    cat "$section_file" >> "$dest"
    echo "Appended $agent_file section -> $dest"
  else
    python3 - "$dest" "$SECTION_START" "$SECTION_END" "$section_file" <<'PYEOF'
import os
import re
import sys
import tempfile

path, start_marker, end_marker, section_path = sys.argv[1:]
with open(path, encoding="utf-8") as handle:
    content = handle.read()
with open(section_path, encoding="utf-8") as handle:
    new_section = handle.read().rstrip("\n")
pattern = re.escape(start_marker) + r".*?" + re.escape(end_marker)
updated, count = re.subn(pattern, lambda _match: new_section, content, flags=re.DOTALL)
if count != 1:
    raise SystemExit(f"expected one managed section, replaced {count}")
folder = os.path.dirname(path) or "."
fd, tmp = tempfile.mkstemp(prefix=".aicodereview-", dir=folder, text=True)
try:
    with os.fdopen(fd, "w", encoding="utf-8") as handle:
        handle.write(updated)
    os.replace(tmp, path)
except Exception:
    try:
        os.unlink(tmp)
    except FileNotFoundError:
        pass
    raise
PYEOF
    echo "Updated $agent_file section -> $dest"
  fi

  rm -f "$section_file"
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
  install_cursor
  install_combined "copilot.md" "$project_dir/.github/copilot-instructions.md"
  install_combined "gemini.md" "$project_dir/GEMINI.md"
  install_combined "aider.md" "$project_dir/CONVENTIONS.md"
}

case "$agent" in
  global)
    install_native_agent "${CODEX_HOME:-$HOME/.codex}/skills" "codex"
    install_native_agent "${CLAUDE_HOME:-$HOME/.claude}/skills" "claude"
    ;;
  codex)
    install_native_agent "${CODEX_HOME:-$HOME/.codex}/skills" "codex"
    ;;
  claude)
    install_native_agent "${CLAUDE_HOME:-$HOME/.claude}/skills" "claude"
    ;;
  cursor)
    install_cursor
    ;;
  copilot)
    install_combined "copilot.md" "$project_dir/.github/copilot-instructions.md"
    ;;
  gemini)
    install_combined "gemini.md" "$project_dir/GEMINI.md"
    ;;
  aider)
    install_combined "aider.md" "$project_dir/CONVENTIONS.md"
    ;;
  all)
    install_native_agent "${CODEX_HOME:-$HOME/.codex}/skills" "codex"
    install_native_agent "${CLAUDE_HOME:-$HOME/.claude}/skills" "claude"
    run_project_agents
    ;;
  *)
    echo "Unknown agent: $agent" >&2
    usage >&2
    exit 1
    ;;
esac

echo ""
if [[ "$dry_run" == true ]]; then
  echo "Dry run complete. No files were changed."
else
  echo "Done."
  if [[ "$agent" == "global" || "$agent" == "all" || "$agent" == "codex" || "$agent" == "claude" ]]; then
    echo "Restart your AI assistant if newly installed skills do not appear immediately."
  fi
  if [[ "$agent" == "aider" || "$agent" == "all" ]]; then
    echo "Aider note: load CONVENTIONS.md with /read or add it to the read list in .aider.conf.yml."
  fi
fi
