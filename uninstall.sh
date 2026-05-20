#!/usr/bin/env bash

set -euo pipefail

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

usage() {
  cat <<'EOF'
Usage: ./uninstall.sh [--agent <agent>] [--project <path>] [--dry-run]

Agents:
  claude   Remove skills from ~/.claude/skills/
  codex    Remove skills from ~/.codex/skills/
  global   Remove claude + codex (default)
  cursor   Remove rules from <project>/.cursor/rules/ (requires --project)
  copilot  Remove AICodeReview section from <project>/.github/copilot-instructions.md (requires --project)
  gemini   Remove AICodeReview section from <project>/GEMINI.md (requires --project)
  aider    Remove AICodeReview section from <project>/CONVENTIONS.md (requires --project)
  all      Remove all agents: global + cursor + copilot + gemini + aider (requires --project)

Options:
  --agent <agent>    Agent to uninstall from (default: global)
  --project <path>   Target project directory (required for cursor, copilot, gemini, aider, all)
  --dry-run          Show what would be removed without deleting files
  --help             Show this help message

Notes:
  - copilot, gemini, and aider only remove the AICodeReview section.
    Existing content outside that section is preserved.
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

remove_global() {
  local dest_base="$1"
  local label="$2"

  for skill in "${skills[@]}"; do
    local dest="$dest_base/$skill"

    if [[ ! -e "$dest" ]]; then
      echo "Not installed: $skill ($label)"
      continue
    fi

    if [[ "$dry_run" == true ]]; then
      echo "Would remove $dest"
    else
      rm -rf "$dest"
      echo "Removed $dest"
    fi
  done
}

remove_cursor() {
  local rules_dir="$project_dir/.cursor/rules"

  for skill in "${skills[@]}"; do
    local dest="$rules_dir/$skill.mdc"

    if [[ ! -e "$dest" ]]; then
      echo "Not installed: $skill (cursor)"
      continue
    fi

    if [[ "$dry_run" == true ]]; then
      echo "Would remove $dest"
    else
      rm -f "$dest"
      echo "Removed $dest"
    fi
  done
}

# Removes only the AICodeReview section from a combined file.
# Existing content outside the section is preserved.
remove_section() {
  local dest="$1"
  local label="$2"

  if [[ ! -e "$dest" ]]; then
    echo "Not installed: $label ($dest)"
    return
  fi

  if ! grep -qF "$SECTION_START" "$dest"; then
    echo "No AICodeReview section found in $dest — skipping"
    return
  fi

  if [[ "$dry_run" == true ]]; then
    echo "Would remove AICodeReview section from $dest"
    return
  fi

  python3 - "$dest" "$SECTION_START" "$SECTION_END" <<'PYEOF'
import sys, re
path, start_marker, end_marker = sys.argv[1], sys.argv[2], sys.argv[3]
content = open(path).read()
pattern = r'\n?' + re.escape(start_marker) + r'.*?' + re.escape(end_marker) + r'\n?'
updated = re.sub(pattern, '', content, flags=re.DOTALL).strip()
if updated:
    open(path, 'w').write(updated + '\n')
else:
    import os; os.remove(path)
PYEOF
  echo "Removed AICodeReview section from $dest"
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

run_project_agents() {
  remove_cursor
  remove_section "$project_dir/.github/copilot-instructions.md" "copilot"
  remove_section "$project_dir/GEMINI.md" "gemini"
  remove_section "$project_dir/CONVENTIONS.md" "aider"
}

case "$agent" in
  global)
    remove_global "${CODEX_HOME:-$HOME/.codex}/skills" "codex"
    remove_global "${CLAUDE_HOME:-$HOME/.claude}/skills" "claude"
    ;;
  codex)
    remove_global "${CODEX_HOME:-$HOME/.codex}/skills" "codex"
    ;;
  claude)
    remove_global "${CLAUDE_HOME:-$HOME/.claude}/skills" "claude"
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
    remove_global "${CODEX_HOME:-$HOME/.codex}/skills" "codex"
    remove_global "${CLAUDE_HOME:-$HOME/.claude}/skills" "claude"
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
