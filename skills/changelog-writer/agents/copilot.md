## Changelog Writer

When asked to generate CHANGELOG entries: inspect git log for the specified range (last tag to HEAD by default). Read `CHANGELOG.md` to match the existing format. Group commits into: Added, Changed, Fixed, Security, Deprecated, Removed. Write in plain language describing user impact, not which files changed. Exclude pure internal/chore commits. Mark breaking changes prominently. Do not fabricate version numbers — ask if a version is needed. Present the new section for confirmation before writing the file.
