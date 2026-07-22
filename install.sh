#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=aicodereview-lib.sh
source "$ROOT_DIR/aicodereview-lib.sh"
load_skills "$ROOT_DIR"

ARTIFACT_SCRIPT="$ROOT_DIR/scripts/skill_artifacts.py"
LEGACY_SECTION_START="# >>> AICodeReview START <<<"
LEGACY_SECTION_END="# >>> AICodeReview END <<<"
AIDER_CONFIG_START="# >>> AICodeReview Aider read START <<<"
AIDER_CONFIG_END="# <<< AICodeReview Aider read END <<<"

agent=""
project_dir=""
dry_run=false
force=false

usage() {
  cat <<'EOF_USAGE'
Usage: ./install.sh [--agent <agent>] [--project <path>] [--dry-run] [--force]

Agents:
  claude    Install native skills to ~/.claude/skills/
  codex     Install native skills to ~/.codex/skills/
  global    Install claude + codex (default)
  cursor    Generate project rules in <project>/.cursor/rules/
  copilot   Install native project skills to <project>/.github/skills/
  gemini    Install native project skills to <project>/.gemini/skills/
  opencode  Install native project skills to <project>/.opencode/skills/
  aider     Generate <project>/AICODEREVIEW.md and configure it when safe
  all       Install every current adapter (requires --project)

Options:
  --agent <agent>    Agent to install for
  --project <path>   Target project directory for project-scoped adapters
  --dry-run          Show changes without writing files
  --force            Update managed installs and back up unmanaged conflicts
  --help             Show this message

Canonical source:
  SKILL.md is the only workflow source. OpenAI metadata, Cursor rules, and
  Aider conventions are generated deterministically from it.

Migration:
  Managed legacy Copilot, Gemini, and Aider sections are removed only after
  their replacement is validated and installed. Corrupt markers stop before
  any target is modified. The all-agent path preflights every adapter first.
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

validate_artifact_source() {
  command -v python3 >/dev/null 2>&1 || {
    echo "Error: python3 is required to generate agent artifacts" >&2
    return 1
  }
  [[ -f "$ARTIFACT_SCRIPT" ]] || {
    echo "Error: missing artifact renderer: $ARTIFACT_SCRIPT" >&2
    return 1
  }
  python3 "$ARTIFACT_SCRIPT" validate >/dev/null
  python3 "$ARTIFACT_SCRIPT" sync-openai --check >/dev/null
}

preflight_native_agent() {
  local dest_base="$1"
  local label="$2"
  validate_artifact_source
  preflight_skill_directory_install "$dest_base" "$label" "$force"
}

install_native_agent() {
  local dest_base="$1"
  local label="$2"
  local skill

  preflight_native_agent "$dest_base" "$label"
  [[ "$dry_run" == true ]] || mkdir -p "$dest_base"

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

preflight_project_native_agent() {
  local dest_base="$1"
  local label="$2"
  local legacy_file="${3:-}"
  local state

  if [[ -n "$legacy_file" ]]; then
    state="$(managed_section_state "$legacy_file" "$LEGACY_SECTION_START" "$LEGACY_SECTION_END")"
    if [[ "$state" == "corrupt" ]]; then
      echo "Error: invalid AICodeReview markers in $legacy_file; refusing migration" >&2
      return 1
    fi
  fi

  preflight_native_agent "$dest_base" "$label"
}

install_project_native_agent() {
  local dest_base="$1"
  local label="$2"
  local legacy_file="${3:-}"

  preflight_project_native_agent "$dest_base" "$label" "$legacy_file"
  install_native_agent "$dest_base" "$label"

  if [[ -n "$legacy_file" ]]; then
    remove_managed_section \
      "$legacy_file" \
      "$LEGACY_SECTION_START" \
      "$LEGACY_SECTION_END" \
      "legacy $label instructions" \
      "$dry_run"
  fi
}

preflight_cursor() {
  local rules_dir="$project_dir/.cursor/rules"
  local skill dest

  validate_artifact_source
  for skill in "${skills[@]}"; do
    dest="$rules_dir/$skill.mdc"
    preflight_managed_file_install "$dest" "Cursor rule $skill" "$force"
  done
}

install_cursor() {
  local rules_dir="$project_dir/.cursor/rules"
  local generated_dir skill generated dest

  preflight_cursor
  generated_dir="$(mktemp -d "${TMPDIR:-/tmp}/aicodereview-cursor.XXXXXX")"

  (
    trap 'rm -rf "$generated_dir"' EXIT

    for skill in "${skills[@]}"; do
      generated="$generated_dir/$skill.mdc"
      python3 "$ARTIFACT_SCRIPT" render-cursor --skill "$skill" --output "$generated"
    done

    for skill in "${skills[@]}"; do
      generated="$generated_dir/$skill.mdc"
      dest="$rules_dir/$skill.mdc"
      install_managed_file \
        "$generated" \
        "$dest" \
        "cursor-rule:$skill" \
        "Cursor rule $skill" \
        "$force" \
        "$dry_run"
    done
  )
}

aider_config_clean_content() {
  local config_file="$1"
  python3 - "$config_file" "$AIDER_CONFIG_START" "$AIDER_CONFIG_END" <<'PYEOF'
import re
import sys

path, start_marker, end_marker = sys.argv[1:]
try:
    content = open(path, encoding="utf-8").read()
except FileNotFoundError:
    content = ""
pattern = r"\n?" + re.escape(start_marker) + r".*?" + re.escape(end_marker) + r"\n?"
print(re.sub(pattern, "\n", content, flags=re.DOTALL))
PYEOF
}

configure_aider_read() {
  local config_file="$project_dir/.aider.conf.yml"
  local state clean_content section_file

  state="$(managed_section_state "$config_file" "$AIDER_CONFIG_START" "$AIDER_CONFIG_END")"
  if [[ "$state" == "corrupt" ]]; then
    echo "Error: invalid AICodeReview Aider markers in $config_file" >&2
    return 1
  fi

  clean_content="$(aider_config_clean_content "$config_file")"
  if printf '%s\n' "$clean_content" | grep -Eq '^[[:space:]]*read[[:space:]]*:'; then
    if [[ "$state" == "managed" ]]; then
      remove_managed_section \
        "$config_file" \
        "$AIDER_CONFIG_START" \
        "$AIDER_CONFIG_END" \
        "managed Aider read block" \
        "$dry_run"
    fi

    if printf '%s\n' "$clean_content" | grep -qF "AICODEREVIEW.md"; then
      echo "Aider config already references AICODEREVIEW.md."
    else
      echo "Aider config has an existing read setting; it was left unchanged."
      echo "Add AICODEREVIEW.md to that read list to load the generated conventions."
    fi
    return 0
  fi

  section_file="$(mktemp "${TMPDIR:-/tmp}/aicodereview-aider-config.XXXXXX")"
  cat > "$section_file" <<EOF_SECTION
$AIDER_CONFIG_START
read:
  - AICODEREVIEW.md
$AIDER_CONFIG_END
EOF_SECTION

  upsert_managed_section \
    "$config_file" \
    "$AIDER_CONFIG_START" \
    "$AIDER_CONFIG_END" \
    "$section_file" \
    "Aider read configuration" \
    "$dry_run"
  rm -f "$section_file"
}

preflight_aider() {
  local legacy_file="$project_dir/CONVENTIONS.md"
  local dest="$project_dir/AICODEREVIEW.md"
  local legacy_state config_state

  validate_artifact_source

  legacy_state="$(managed_section_state "$legacy_file" "$LEGACY_SECTION_START" "$LEGACY_SECTION_END")"
  [[ "$legacy_state" != "corrupt" ]] || {
    echo "Error: invalid AICodeReview markers in $legacy_file" >&2
    return 1
  }

  config_state="$(managed_section_state "$project_dir/.aider.conf.yml" "$AIDER_CONFIG_START" "$AIDER_CONFIG_END")"
  [[ "$config_state" != "corrupt" ]] || {
    echo "Error: invalid AICodeReview Aider markers in $project_dir/.aider.conf.yml" >&2
    return 1
  }

  preflight_managed_file_install "$dest" "Aider conventions" "$force"
}

install_aider() {
  local legacy_file="$project_dir/CONVENTIONS.md"
  local dest="$project_dir/AICODEREVIEW.md"
  local generated

  preflight_aider
  generated="$(mktemp "${TMPDIR:-/tmp}/aicodereview-aider.XXXXXX")"
  python3 "$ARTIFACT_SCRIPT" render-aider --output "$generated"

  install_managed_file \
    "$generated" \
    "$dest" \
    "aider-conventions" \
    "Aider conventions" \
    "$force" \
    "$dry_run"
  rm -f "$generated"

  remove_managed_section \
    "$legacy_file" \
    "$LEGACY_SECTION_START" \
    "$LEGACY_SECTION_END" \
    "legacy Aider conventions" \
    "$dry_run"

  configure_aider_read
}

preflight_all_agents() {
  preflight_native_agent "${CODEX_HOME:-$HOME/.codex}/skills" "codex"
  preflight_native_agent "${CLAUDE_HOME:-$HOME/.claude}/skills" "claude"
  preflight_cursor
  preflight_project_native_agent "$project_dir/.github/skills" "copilot" "$project_dir/.github/copilot-instructions.md"
  preflight_project_native_agent "$project_dir/.gemini/skills" "gemini" "$project_dir/GEMINI.md"
  preflight_project_native_agent "$project_dir/.opencode/skills" "opencode"
  preflight_aider
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
  install_cursor
  install_project_native_agent "$project_dir/.github/skills" "copilot" "$project_dir/.github/copilot-instructions.md"
  install_project_native_agent "$project_dir/.gemini/skills" "gemini" "$project_dir/GEMINI.md"
  install_project_native_agent "$project_dir/.opencode/skills" "opencode"
  install_aider
}

case "$agent" in
  global)
    preflight_native_agent "${CODEX_HOME:-$HOME/.codex}/skills" "codex"
    preflight_native_agent "${CLAUDE_HOME:-$HOME/.claude}/skills" "claude"
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
    install_project_native_agent "$project_dir/.github/skills" "copilot" "$project_dir/.github/copilot-instructions.md"
    ;;
  gemini)
    install_project_native_agent "$project_dir/.gemini/skills" "gemini" "$project_dir/GEMINI.md"
    ;;
  opencode)
    install_project_native_agent "$project_dir/.opencode/skills" "opencode"
    ;;
  aider)
    install_aider
    ;;
  all)
    preflight_all_agents
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

echo
if [[ "$dry_run" == true ]]; then
  echo "Dry run complete. No files were changed."
else
  echo "Done."
  if [[ "$agent" == "gemini" || "$agent" == "all" ]]; then
    echo "Gemini CLI: run /skills reload to refresh workspace skills."
  fi
fi
