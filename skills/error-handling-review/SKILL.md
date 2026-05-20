---
name: error-handling-review
description: Review error handling for silent catches, inconsistent propagation, missing UI error states, untyped errors, and missing boundary handling.
---

# Error Handling Review

When asked to review error handling, follow this workflow:

1. List all source files in scope and read them.
2. Find silent catch blocks: catch/except/rescue clauses that contain no log statement, no rethrow, no meaningful action. Flag each one.
3. Check error propagation consistency: if some call sites use exceptions and others use result types or error codes for the same error category, flag the inconsistency.
4. Check UI layers for missing error states: screens or components that make network/DB calls but have no error branch shown to the user (no error message, no retry button, no fallback UI).
5. Check for missing user-friendly error messages: errors that expose raw exception text, stack traces, or internal codes to the user.
6. Check retry logic: any retry loop or mechanism that has no backoff (exponential or fixed delay), no maximum retry cap, or retries on non-retryable errors (e.g., 400 Bad Request, auth failures).
7. Check boundary error handling for network calls, DB operations, and filesystem access — each boundary must have an explicit error handler.
8. Check error type definition: errors should be typed (custom exception classes, error enums, result types) not passed as raw strings or untyped objects.
9. Check error documentation: public APIs that can fail must declare what errors they can produce (docstring, annotation, throws clause, or equivalent).
10. Order all findings P0–P3:
    - P0: silent catch swallowing a security or data-integrity error, missing error handler on a DB write or financial transaction
    - P1: silent catch in business logic, missing UI error state on critical user flow, retry without backoff
    - P2: inconsistent propagation style, missing user-friendly message, missing error type definition
    - P3: missing error documentation on internal API, minor inconsistency in error naming
11. Output each finding with: severity, file:line, description, and one-sentence fix.

Output: Findings list P0–P3 with file references and fix suggestions.

Rules:
- Read actual catch/except/rescue blocks before flagging — do not guess from method signatures.
- Logging the error then rethrowing is acceptable — do not flag it as silent.
- Do not flag intentional "swallow and continue" patterns if they are clearly documented in a comment explaining the rationale.
