---
name: changelog-writer
description: Use when generating or updating CHANGELOG entries from git commits, summarising what changed in a release, or writing human-readable release notes.
---

# Changelog Writer

## Workflow

1. Inspect git log between the specified range (e.g. last tag to HEAD, or two named commits/tags).
2. Read `CHANGELOG.md` when present to understand the existing format and version history.
3. Read `PROJECT_CONTEXT.md` when present to understand the project's versioning conventions.
4. Group commits by type: features, fixes, performance, security, breaking changes, deprecations, internal/chore.
5. Write entries in plain language — what changed from the user's perspective, not what files were touched.
6. Do not push, tag, or release unless explicitly asked.

## Rules

- Exclude pure chore/internal commits (dependency bumps without user impact, formatting, CI changes) unless they affect the release process.
- Mark breaking changes prominently.
- Use the project's existing CHANGELOG format if one exists (e.g. Keep a Changelog, conventional commits). Default to Keep a Changelog if no format is established.
- Do not fabricate version numbers — ask the user if a version is needed and not obvious.
- Keep entries concise: one line per change where possible.

## Default Format (Keep a Changelog)

```markdown
## [Unreleased]

### Added
- ...

### Changed
- ...

### Fixed
- ...

### Security
- ...

### Deprecated
- ...

### Removed
- ...
```

## Output

Provide the new CHANGELOG section ready to paste, then ask the user to verify before writing the file.
