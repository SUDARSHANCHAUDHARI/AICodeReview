## Changelog Writer Convention

When asked to generate CHANGELOG entries:

1. Inspect git log for the specified range (default: last tag to HEAD).
2. Read `CHANGELOG.md` to match the existing format.
3. Group by: Added, Changed, Fixed, Security, Deprecated, Removed.
4. Write in plain language — user impact, not file names.
5. Exclude pure chore/internal commits.
6. Mark breaking changes prominently.
7. Do not fabricate version numbers — ask if needed.
8. Present the section for confirmation before writing.
