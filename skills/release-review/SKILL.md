---
name: release-review
description: Use before publishing a release, merging a release branch, preparing a Play Store build, tagging a version, or checking release-blocking risk.
---

# Release Review

## Workflow

1. Inspect repo status, branch, recent commits, changed files, version files, release notes, and build config.
2. Read `PROJECT_CONTEXT.md`, `AGENTS.md`, release docs, store docs, and CI config when present.
3. Identify release blockers first. Do not make changes unless asked.
4. Separate must-fix issues from nice-to-have cleanup.

## Checklist

- Versioning: app/version code, changelog, tags, and release notes are consistent.
- Build: release command exists and avoids debug config.
- Secrets: no credentials, signing files, `.env` values, private keys, or tokens committed.
- Platform rules: Android releases build AAB, not APK, unless intentionally testing.
- Privacy: data collection, analytics, permissions, and policy text are aligned.
- CI: required checks are known and passing or explicitly not run.
- Migration: database/schema/config migrations are forward-safe.
- Rollback: risky changes have a fallback or are clearly understood.
- User impact: breaking changes, data loss, or compatibility issues are called out.

## Output

```markdown
## Release Blockers

- ...

## Should Fix

- ...

## Nice To Have

- ...

## Verification

- ...

## Verdict

READY / NOT READY / BLOCKED
```
