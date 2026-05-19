#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
SKILLS_DIR="$CODEX_HOME/skills"

skills=(
  "codex-code-review"
  "codex-security-audit"
  "codex-codebase-explainer"
  "codex-review-fixer"
)

mkdir -p "$SKILLS_DIR"

for skill in "${skills[@]}"; do
  src="$ROOT_DIR/skills/$skill"
  dest="$SKILLS_DIR/$skill"

  if [[ ! -d "$src" ]]; then
    echo "Missing skill directory: $src" >&2
    exit 1
  fi

  rm -rf "$dest"
  cp -R "$src" "$dest"
  echo "Installed $skill -> $dest"
done

echo
echo "Done. Restart Codex if the new skills do not appear immediately."
