## Error Handling Review Convention

When asked to review error handling:

1. Read all source files in scope.
2. Flag silent catch blocks: catch/except/rescue with no log, rethrow, or action.
3. Flag inconsistent propagation: same error category uses different styles (exceptions vs result types) across call sites.
4. Flag missing UI error states: network/DB callers with no error branch for the user.
5. Flag raw error exposure: exception text, stack traces, or internal codes shown to users.
6. Flag retry without backoff: loops with no delay, no cap, or retrying non-retryable codes.
7. Flag unhandled boundaries: network, DB, or filesystem calls with no error handler.
8. Flag untyped errors: errors as raw strings or untyped objects.
9. Flag undocumented error contracts on public APIs.
10. Output P0–P3 findings with file:line and a one-line fix per finding.
