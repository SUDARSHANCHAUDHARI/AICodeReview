#!/usr/bin/env bash

set -euo pipefail

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
SKILLS_DIR="$CODEX_HOME/skills"
dry_run=false

skills=(
  "codex-code-review"
  "codex-security-audit"
  "codex-codebase-explainer"
  "codex-review-fixer"
  "codex-android-review"
  "codex-release-review"
  "codex-pr-summary"
  "codex-context-writer"
)

usage() {
  cat <<'EOF'
Usage: ./uninstall.sh [--dry-run]

Options:
  --dry-run  Show what would be removed without deleting files.
  --help     Show this help message.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      dry_run=true
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
  shift
done

for skill in "${skills[@]}"; do
  dest="$SKILLS_DIR/$skill"

  if [[ ! -e "$dest" ]]; then
    echo "Not installed: $skill"
    continue
  fi

  if [[ "$dry_run" == true ]]; then
    echo "Would remove $dest"
  else
    rm -rf "$dest"
    echo "Removed $dest"
  fi
done

if [[ "$dry_run" == true ]]; then
  echo "Dry run complete. No files were changed."
fi
