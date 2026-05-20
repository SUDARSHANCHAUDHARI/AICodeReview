---
name: review-fixer
description: Use when applying fixes from review findings. Only applies concrete, low-risk, verifiable fixes and runs relevant checks afterward.
---

# Review Fixer

## Workflow

1. Read the review findings and identify the exact files/lines involved.
2. Inspect current repo state and relevant code before editing.
3. Fix only concrete findings with clear expected behavior.
4. Skip findings that require product decisions, large refactors, uncertain business logic, or broad ownership changes.
5. Match existing style and patterns.
6. Add or update focused tests when the fix changes behavior and test structure exists.
7. Run relevant verification: build, lint, typecheck, or targeted tests.
8. Summarize fixed, skipped, and verification results.

## Guardrails

- Do not perform unrelated refactors.
- Do not rewrite large files to fix small issues.
- Do not touch secrets, signing files, generated files, or local config unless explicitly requested.
- Do not run destructive git commands.
- Preserve user changes already in the worktree.

## Output

```markdown
## Fixed

- ...

## Skipped

- Finding: reason skipped.

## Verification

- Command: result.
```
