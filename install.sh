#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SECTION_START="# >>> AICodeReview START <<<"
SECTION_END="# >>> AICodeReview END <<<"

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
  "architecture-review"
  "code-smell-detector"
  "error-handling-review"
  "graphql-review"
  "react-native-review"
  "tech-debt-audit"
  "onboarding-writer"
)

agent=""
project_dir=""
dry_run=false
force=false

usage() {
  cat <<'EOF'
Usage: ./install.sh [--agent <agent>] [--project <path>] [--dry-run] [--force]

Agents:
  claude   Install skills to ~/.claude/skills/ (Claude Code)
  codex    Install skills to ~/.codex/skills/ (OpenAI Codex)
  global   Install claude + codex (default when no --agent given)
  cursor   Install rules to <project>/.cursor/rules/ (requires --project)
  copilot  Append instructions to <project>/.github/copilot-instructions.md (requires --project)
  gemini   Append instructions to <project>/GEMINI.md (requires --project)
  aider    Append conventions to <project>/CONVENTIONS.md (requires --project)
  all      Install all agents: global + cursor + copilot + gemini + aider (requires --project)

Options:
  --agent <agent>    Agent to install for (default: global)
  --project <path>   Target project directory (required for cursor, copilot, gemini, aider, all)
  --dry-run          Show what would happen without writing files
  --force            Overwrite or update existing installed skills
  --help             Show this help message

Notes:
  - copilot, gemini, and aider append into a marked section in the target file.
    Existing content outside the section is preserved.
  - Re-running updates the section in place. Use --force to update global skills.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent)
      agent="${2:-}"
      shift 2
      ;;
    --project)
      project_dir="${2:-}"
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

install_global() {
  local dest_base="$1"
  local label="$2"

  if [[ "$dry_run" == false ]]; then
    mkdir -p "$dest_base"
  fi

  for skill in "${skills[@]}"; do
    local src="$ROOT_DIR/skills/$skill"
    local dest="$dest_base/$skill"

    if [[ ! -d "$src" ]]; then
      echo "Missing skill directory: $src" >&2
      exit 1
    fi

    if [[ -e "$dest" && "$force" == false ]]; then
      echo "Skipping $skill ($label); already exists (use --force to overwrite)"
      continue
    fi

    if [[ "$dry_run" == true ]]; then
      echo "Would install $skill -> $dest"
      continue
    fi

    [[ -e "$dest" ]] && rm -rf "$dest"
    cp -R "$src" "$dest"
    echo "Installed $skill -> $dest"
  done
}

install_cursor() {
  local rules_dir="$project_dir/.cursor/rules"

  if [[ "$dry_run" == false ]]; then
    mkdir -p "$rules_dir"
  fi

  for skill in "${skills[@]}"; do
    local src="$ROOT_DIR/skills/$skill/agents/cursor.mdc"
    local dest="$rules_dir/$skill.mdc"

    if [[ ! -f "$src" ]]; then
      echo "Missing cursor config: $src" >&2
      exit 1
    fi

    if [[ -e "$dest" && "$force" == false ]]; then
      echo "Skipping $skill (cursor); already exists (use --force to overwrite)"
      continue
    fi

    if [[ "$dry_run" == true ]]; then
      echo "Would install $skill -> $dest"
      continue
    fi

    cp "$src" "$dest"
    echo "Installed $skill -> $dest"
  done
}

# Writes our content into a marked section in the target file.
# Existing content outside the section is preserved.
# On re-run, the section is replaced in place.
install_combined() {
  local agent_file="$1"
  local dest="$2"

  if [[ "$dry_run" == true ]]; then
    echo "Would write $agent_file section -> $dest"
    return
  fi

  local dest_dir
  dest_dir="$(dirname "$dest")"
  mkdir -p "$dest_dir"

  # Build the new section content
  local section
  section="$(printf '%s\n\n' "$SECTION_START")"
  for skill in "${skills[@]}"; do
    local src="$ROOT_DIR/skills/$skill/agents/$agent_file"
    if [[ ! -f "$src" ]]; then
      echo "Missing $agent_file for $skill" >&2
      exit 1
    fi
    section+="$(cat "$src")"$'\n\n'
  done
  section+="$SECTION_END"

  if [[ ! -e "$dest" ]]; then
    # New file — write section only
    printf '%s\n' "$section" > "$dest"
    echo "Installed $agent_file section -> $dest"
    return
  fi

  # File exists — check for our section
  if grep -qF "$SECTION_START" "$dest"; then
    # Replace the section in place using Python (safe for multiline, no sed issues)
    python3 - "$dest" "$SECTION_START" "$SECTION_END" "$section" <<'PYEOF'
import sys, re
path, start_marker, end_marker, new_section = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
content = open(path).read()
pattern = re.escape(start_marker) + r'.*?' + re.escape(end_marker)
# Use a function as the replacement so backslashes / group references
# (\1, \g<...>) inside the section content are treated literally, not as
# regex replacement escapes — otherwise skill content could corrupt the file.
updated = re.sub(pattern, lambda _m: new_section, content, flags=re.DOTALL)
open(path, 'w').write(updated)
PYEOF
    echo "Updated $agent_file section -> $dest"
  else
    # Append our section to existing file
    printf '\n%s\n' "$section" >> "$dest"
    echo "Appended $agent_file section -> $dest"
  fi
}

project_agents=("cursor" "copilot" "gemini" "aider")

requires_project=false
for pa in "${project_agents[@]}"; do
  [[ "$agent" == "$pa" || "$agent" == "all" ]] && requires_project=true && break
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
  install_combined "gemini.md"  "$project_dir/GEMINI.md"
  install_combined "aider.md"   "$project_dir/CONVENTIONS.md"
}

case "$agent" in
  global)
    install_global "${CODEX_HOME:-$HOME/.codex}/skills" "codex"
    install_global "${CLAUDE_HOME:-$HOME/.claude}/skills" "claude"
    ;;
  codex)
    install_global "${CODEX_HOME:-$HOME/.codex}/skills" "codex"
    ;;
  claude)
    install_global "${CLAUDE_HOME:-$HOME/.claude}/skills" "claude"
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
    install_global "${CODEX_HOME:-$HOME/.codex}/skills" "codex"
    install_global "${CLAUDE_HOME:-$HOME/.claude}/skills" "claude"
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
    echo "Restart your AI assistant if the new skills do not appear immediately."
  fi
fi
