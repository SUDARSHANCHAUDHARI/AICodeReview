# Release Review Prompt

Check release readiness before publishing, tagging, merging a release branch, or preparing a store build.

## Instructions

1. Inspect repo status, branch, recent commits, changed files, version files, release notes, build config, and CI config.
2. Read `PROJECT_CONTEXT.md`, `AGENTS.md`, release docs, and store docs when present.
3. Identify release blockers first. Do not make changes unless asked.

## Checklist

- Version code/name, changelog, tags, and release notes.
- Release build avoids debug config.
- No secrets, signing files, `.env` values, private keys, or tokens.
- Android releases produce AAB unless intentionally testing APKs.
- Privacy policy, permissions, analytics, and data collection are aligned.
- CI checks are passing or explicitly not run.
- Migrations are forward-safe.
- Rollback risk is understood.

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
