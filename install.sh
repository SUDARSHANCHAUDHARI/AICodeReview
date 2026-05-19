#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
SKILLS_DIR="$CODEX_HOME/skills"
dry_run=false
force=false

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
Usage: ./install.sh [--dry-run] [--force]

Options:
  --dry-run  Show what would be installed without writing files.
  --force    Overwrite existing installed skills.
  --help     Show this help message.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      dry_run=true
      ;;
    --force)
      force=true
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

if [[ "$dry_run" == false ]]; then
  mkdir -p "$SKILLS_DIR"
fi

for skill in "${skills[@]}"; do
  src="$ROOT_DIR/skills/$skill"
  dest="$SKILLS_DIR/$skill"

  if [[ ! -d "$src" ]]; then
    echo "Missing skill directory: $src" >&2
    exit 1
  fi

  if [[ -e "$dest" && "$force" == false ]]; then
    echo "Skipping $skill; already exists at $dest (use --force to overwrite)"
    continue
  fi

  if [[ "$dry_run" == true ]]; then
    if [[ -e "$dest" && "$force" == true ]]; then
      echo "Would overwrite $skill -> $dest"
    else
      echo "Would install $skill -> $dest"
    fi
    continue
  fi

  if [[ -e "$dest" ]]; then
    rm -rf "$dest"
  fi

  cp -R "$src" "$dest"
  echo "Installed $skill -> $dest"
done

echo
if [[ "$dry_run" == true ]]; then
  echo "Dry run complete. No files were changed."
else
  echo "Done. Restart Codex if the new skills do not appear immediately."
fi
