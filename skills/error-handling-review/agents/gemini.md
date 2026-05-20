# Error Handling Review

When asked to review error handling, follow this workflow:

1. Read all source files in scope.
2. Find silent catch blocks: catch/except/rescue with no log, no rethrow, no meaningful action.
3. Check error propagation consistency across the codebase for the same error categories.
4. Check UI layers for missing error states on network/DB call sites.
5. Check for raw error or stack trace exposure in user-facing messages.
6. Check retry logic for missing backoff, missing cap, or retrying non-retryable errors.
7. Verify every network call, DB write, and filesystem operation has an explicit error handler.
8. Check that errors are typed (custom classes, enums, result types) not raw strings.
9. Check that public APIs document their error contracts.
10. Output findings ordered P0–P3 with file:line and a one-line fix suggestion.

Check: silent catches, inconsistent propagation, missing UI error state, raw error exposure, retry without backoff, unhandled boundaries, untyped errors, missing error contracts.

Order findings P0–P3 with file:line references.
