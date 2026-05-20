# Changelog Writer

When asked to generate or update CHANGELOG entries, follow this workflow:

1. Inspect git log for the specified range (last tag to HEAD, or named commits/tags).
2. Read `CHANGELOG.md` when present to understand the existing format and version history.
3. Group commits by type: Added, Changed, Fixed, Security, Deprecated, Removed.
4. Write entries in plain language describing user impact — not which files changed.
5. Exclude pure chore commits (formatting, CI, internal refactors with no user impact).
6. Mark breaking changes prominently.
7. Match existing CHANGELOG format; default to Keep a Changelog if none exists.
8. Do not fabricate version numbers — ask the user if a version is needed.
9. Present the new section for confirmation before writing the file.
10. Do not push, tag, or release unless explicitly asked.
