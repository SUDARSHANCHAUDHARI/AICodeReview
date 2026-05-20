# Backend Review

When asked to review backend API code, follow this workflow:

1. Inspect route definitions, middleware, handler code, and relevant tests.
2. Read `PROJECT_CONTEXT.md` and `AGENTS.md` for architecture context.
3. Review for API design, security, performance, reliability, and test coverage.
4. Do not edit unless explicitly asked.

Check: correct HTTP methods and status codes, auth checks on all protected endpoints, ownership checks (IDOR), input validation at boundary, no PII in responses/logs, rate limiting, parameterised SQL, no N+1, paginated lists, consistent error shape, external call timeouts, transaction usage for multi-write ops. New endpoints need integration tests.

Order findings P0–P3 with file:line references.
