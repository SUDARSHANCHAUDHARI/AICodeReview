#!/usr/bin/env bash

# Shared helpers for AICodeReview maintenance scripts.
# This file is sourced by the root-level install, uninstall, list, health, and update commands.

AICODEREVIEW_SOURCE="SUDARSHANCHAUDHARI/AICodeReview"
AICODEREVIEW_MANAGED_FILE=".aicodereview-managed"
AICODEREVIEW_FILE_MARKER_SUFFIX=".aicodereview-managed"

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

managed_file_marker() {
  printf '%s%s' "$1" "$AICODEREVIEW_FILE_MARKER_SUFFIX"
}

is_managed_file() {
  local path="$1"
  local marker
  marker="$(managed_file_marker "$path")"
  [[ -f "$marker" ]] && grep -qF "source=$AICODEREVIEW_SOURCE" "$marker"
}

write_managed_file_marker() {
  local path="$1"
  local item="$2"
  local marker
  marker="$(managed_file_marker "$path")"

  cat > "$marker" <<EOF_MARKER
source=$AICODEREVIEW_SOURCE
item=$item
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

preflight_skill_directory_install() {
  local dest_base="$1"
  local label="$2"
  local force="$3"
  local skill dest
  local conflicts=0

  for skill in "${skills[@]}"; do
    dest="$dest_base/$skill"
    if [[ -e "$dest" ]] && ! is_managed_skill_dir "$dest" && [[ "$force" == false ]]; then
      echo "Error: $dest exists and is not managed by AICodeReview." >&2
      echo "Use --force to back it up before installing the $label adapter." >&2
      conflicts=$((conflicts + 1))
    fi
  done

  [[ "$conflicts" -eq 0 ]]
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

preflight_managed_file_install() {
  local dest="$1"
  local label="$2"
  local force="$3"

  if [[ -e "$dest" ]] && ! is_managed_file "$dest" && [[ "$force" == false ]]; then
    echo "Error: $dest exists and is not managed by AICodeReview." >&2
    echo "Use --force to back it up before installing $label." >&2
    return 1
  fi
}

install_managed_file() {
  local src="$1"
  local dest="$2"
  local item="$3"
  local label="$4"
  local force="$5"
  local dry_run="$6"
  local marker
  marker="$(managed_file_marker "$dest")"

  if [[ ! -f "$src" ]]; then
    echo "Missing source file: $src" >&2
    return 1
  fi

  if [[ -e "$dest" && "$force" == false ]]; then
    if is_managed_file "$dest"; then
      echo "Skipping $label; already installed (use --force to update)"
    else
      echo "Skipping $label; destination exists and is not managed by AICodeReview"
    fi
    return 0
  fi

  if [[ "$dry_run" == true ]]; then
    if [[ -e "$dest" ]] && ! is_managed_file "$dest"; then
      echo "Would back up unmanaged $dest and install $label"
    elif [[ -e "$dest" ]]; then
      echo "Would update $label -> $dest"
    else
      echo "Would install $label -> $dest"
    fi
    return 0
  fi

  local parent tmp tmp_marker old_path old_marker keep_old=false
  parent="$(dirname "$dest")"
  mkdir -p "$parent"
  tmp="${dest}.aicodereview-tmp-$$"
  tmp_marker="${tmp}${AICODEREVIEW_FILE_MARKER_SUFFIX}"
  rm -f "$tmp" "$tmp_marker"
  cp "$src" "$tmp"
  write_managed_file_marker "$tmp" "$item"

  old_path=""
  old_marker=""
  if [[ -e "$dest" ]]; then
    if is_managed_file "$dest"; then
      old_path="${dest}.aicodereview-old-$$"
      old_marker="${marker}.old-$$"
      rm -f "$old_path" "$old_marker"
      mv "$dest" "$old_path"
      mv "$marker" "$old_marker"
    else
      old_path="$(next_backup_path "$dest")"
      keep_old=true
      mv "$dest" "$old_path"
    fi
  fi

  if ! mv "$tmp" "$dest"; then
    rm -f "$tmp" "$tmp_marker"
    [[ -n "$old_path" && -e "$old_path" ]] && mv "$old_path" "$dest"
    [[ -n "$old_marker" && -e "$old_marker" ]] && mv "$old_marker" "$marker"
    echo "Failed to install $label -> $dest; previous content restored" >&2
    return 1
  fi

  mv "$tmp_marker" "$marker"

  if [[ -n "$old_path" ]]; then
    if [[ "$keep_old" == true ]]; then
      echo "Backed up unmanaged destination -> $old_path"
    else
      rm -f "$old_path" "$old_marker"
    fi
  fi

  echo "Installed $label -> $dest"
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

remove_managed_file() {
  local dest="$1"
  local label="$2"
  local dry_run="$3"
  local marker
  marker="$(managed_file_marker "$dest")"

  if [[ ! -e "$dest" ]]; then
    echo "Not installed: $label ($dest)"
    return 0
  fi

  if ! is_managed_file "$dest"; then
    echo "Skipping $dest; it is not marked as an AICodeReview install" >&2
    return 0
  fi

  if [[ "$dry_run" == true ]]; then
    echo "Would remove $dest and $marker"
  else
    rm -f "$dest" "$marker"
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

upsert_managed_section() {
  local dest="$1"
  local start_marker="$2"
  local end_marker="$3"
  local section_file="$4"
  local label="$5"
  local dry_run="$6"
  local state

  state="$(managed_section_state "$dest" "$start_marker" "$end_marker")"
  if [[ "$state" == "corrupt" ]]; then
    echo "Error: invalid AICodeReview marker state in $dest; refusing to modify it" >&2
    return 1
  fi

  if [[ "$dry_run" == true ]]; then
    echo "Would write $label -> $dest ($state)"
    return 0
  fi

  mkdir -p "$(dirname "$dest")"

  if [[ "$state" == "absent" ]]; then
    cp "$section_file" "$dest"
    echo "Installed $label -> $dest"
  elif [[ "$state" == "unmanaged" ]]; then
    printf '\n' >> "$dest"
    cat "$section_file" >> "$dest"
    echo "Appended $label -> $dest"
  else
    python3 - "$dest" "$start_marker" "$end_marker" "$section_file" <<'PYEOF'
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
    echo "Updated $label -> $dest"
  fi
}

remove_managed_section() {
  local dest="$1"
  local start_marker="$2"
  local end_marker="$3"
  local label="$4"
  local dry_run="$5"
  local state

  state="$(managed_section_state "$dest" "$start_marker" "$end_marker")"
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
    echo "Would remove $label from $dest"
    return 0
  fi

  python3 - "$dest" "$start_marker" "$end_marker" <<'PYEOF'
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
  echo "Removed $label from $dest"
}
