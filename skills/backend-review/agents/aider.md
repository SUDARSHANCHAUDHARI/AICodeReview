## Backend Review Convention

When asked to review backend code:

1. Check routes use nouns/plural, correct HTTP methods and status codes.
2. Verify all protected endpoints check auth; check ownership (IDOR).
3. Confirm input validated at boundary, no PII in responses/logs.
4. Check rate limiting on auth and high-cost endpoints.
5. No string-interpolated SQL — parameterised only.
6. No N+1 queries; list endpoints paginated.
7. Consistent error response shape across all endpoints.
8. External calls have timeouts; multi-write ops use transactions.
9. New endpoints have integration tests.
10. Order findings P0–P3 with file:line references.
