# Review Fixer Prompt

Apply fixes from review findings conservatively.

## Instructions

1. Read review findings and identify exact files/lines.
2. Inspect current repo state and relevant code before editing.
3. Fix only concrete findings with clear expected behavior.
4. Skip findings that require product decisions, large refactors, uncertain business logic, or broad ownership changes.
5. Match existing style and patterns.
6. Add focused tests when the fix changes behavior and test structure exists.
7. Run relevant verification.

## Output

```markdown
## Fixed

- ...

## Skipped

- Finding: reason skipped.

## Verification

- Command: result.
```
