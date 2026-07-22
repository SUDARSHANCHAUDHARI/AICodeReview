#!/usr/bin/env bash

# Shared helpers for AICodeReview maintenance scripts.
# This file is sourced by the root-level install, uninstall, list, and health commands.

AICODEREVIEW_SOURCE="SUDARSHANCHAUDHARI/AICodeReview"
AICODEREVIEW_MANAGED_FILE=".aicodereview-managed"
AICODEREVIEW_CURSOR_MARKER_SUFFIX=".aicodereview-managed"

load_skills() {
  local root_dir="$1"
  skills=()

  while IFS= read -r skill_dir; do
    skills+=("$(basename "$skill_dir")")
  done < <(find "$root_dir/skills" -mindepth 1 -maxdepth 1 -type d | sort)

  if [[ "${#skills[@]}" -eq 0 ]]; then
    echo "Error: no skills found under $root_dir/skills" >&2
    return 1
  fi
}

is_managed_skill_dir() {
  local path="$1"
  local marker="$path/$AICODEREVIEW_MANAGED_FILE"
  [[ -f "$marker" ]] && grep -qF "source=$AICODEREVIEW_SOURCE" "$marker"
}

write_managed_skill_marker() {
  local path="$1"
  local skill="$2"

  cat > "$path/$AICODEREVIEW_MANAGED_FILE" <<EOF_MARKER
source=$AICODEREVIEW_SOURCE
skill=$skill
EOF_MARKER
}

is_managed_cursor_rule() {
  local path="$1"
  local marker="${path}${AICODEREVIEW_CURSOR_MARKER_SUFFIX}"
  [[ -f "$marker" ]] && grep -qF "source=$AICODEREVIEW_SOURCE" "$marker"
}

write_managed_cursor_marker() {
  local path="$1"
  local skill="$2"

  cat > "${path}${AICODEREVIEW_CURSOR_MARKER_SUFFIX}" <<EOF_MARKER
source=$AICODEREVIEW_SOURCE
skill=$skill
EOF_MARKER
}

next_backup_path() {
  local path="$1"
  local timestamp candidate counter
  timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
  candidate="${path}.aicodereview-backup-${timestamp}"
  counter=1

  while [[ -e "$candidate" ]]; do
    candidate="${path}.aicodereview-backup-${timestamp}-${counter}"
    counter=$((counter + 1))
  done

  printf '%s' "$candidate"
}

install_skill_directory() {
  local src="$1"
  local dest="$2"
  local skill="$3"
  local label="$4"
  local force="$5"
  local dry_run="$6"

  if [[ ! -d "$src" ]]; then
    echo "Missing skill directory: $src" >&2
    return 1
  fi

  if [[ -e "$dest" && "$force" == false ]]; then
    if is_managed_skill_dir "$dest"; then
      echo "Skipping $skill ($label); already installed (use --force to update)"
    else
      echo "Skipping $skill ($label); destination exists and is not managed by AICodeReview"
    fi
    return 0
  fi

  if [[ "$dry_run" == true ]]; then
    if [[ -e "$dest" ]] && ! is_managed_skill_dir "$dest"; then
      echo "Would back up unmanaged $dest and install $skill -> $dest"
    elif [[ -e "$dest" ]]; then
      echo "Would update $skill -> $dest"
    else
      echo "Would install $skill -> $dest"
    fi
    return 0
  fi

  local parent tmp old_path keep_old=false
  parent="$(dirname "$dest")"
  mkdir -p "$parent"
  tmp="${dest}.aicodereview-tmp-$$"
  rm -rf "$tmp"
  cp -R "$src" "$tmp"
  write_managed_skill_marker "$tmp" "$skill"

  old_path=""
  if [[ -e "$dest" ]]; then
    if is_managed_skill_dir "$dest"; then
      old_path="${dest}.aicodereview-old-$$"
      rm -rf "$old_path"
    else
      old_path="$(next_backup_path "$dest")"
      keep_old=true
    fi
    mv "$dest" "$old_path"
  fi

  if ! mv "$tmp" "$dest"; then
    rm -rf "$tmp"
    if [[ -n "$old_path" && -e "$old_path" ]]; then
      mv "$old_path" "$dest"
    fi
    echo "Failed to install $skill -> $dest; previous content restored" >&2
    return 1
  fi

  if [[ -n "$old_path" ]]; then
    if [[ "$keep_old" == true ]]; then
      echo "Backed up unmanaged destination -> $old_path"
    else
      rm -rf "$old_path"
    fi
  fi

  echo "Installed $skill -> $dest"
}

remove_managed_skill_directory() {
  local dest="$1"
  local skill="$2"
  local label="$3"
  local dry_run="$4"

  if [[ ! -e "$dest" ]]; then
    echo "Not installed: $skill ($label)"
    return 0
  fi

  if ! is_managed_skill_dir "$dest"; then
    echo "Skipping $dest; it is not marked as an AICodeReview install" >&2
    return 0
  fi

  if [[ "$dry_run" == true ]]; then
    echo "Would remove $dest"
  else
    rm -rf "$dest"
    echo "Removed $dest"
  fi
}

managed_section_state() {
  local file="$1"
  local start_marker="$2"
  local end_marker="$3"
  local start_count=0 end_count=0 start_line=0 end_line=0

  if [[ ! -e "$file" ]]; then
    printf 'absent'
    return 0
  fi

  start_count="$(grep -cF "$start_marker" "$file" || true)"
  end_count="$(grep -cF "$end_marker" "$file" || true)"

  if [[ "$start_count" -eq 0 && "$end_count" -eq 0 ]]; then
    printf 'unmanaged'
    return 0
  fi

  if [[ "$start_count" -ne 1 || "$end_count" -ne 1 ]]; then
    printf 'corrupt'
    return 0
  fi

  start_line="$(grep -nF "$start_marker" "$file" | cut -d: -f1)"
  end_line="$(grep -nF "$end_marker" "$file" | cut -d: -f1)"

  if [[ "$end_line" -le "$start_line" ]]; then
    printf 'corrupt'
  else
    printf 'managed'
  fi
}
