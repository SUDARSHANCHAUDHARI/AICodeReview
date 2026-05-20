## Backend Review

When asked to review backend code: check routes use nouns/plural/correct HTTP methods/correct status codes, all authenticated endpoints actually check auth (IDOR risk), input validated at boundary, no PII in responses or logs, rate limiting on auth/high-cost endpoints, parameterised SQL only, no N+1 queries, paginated list endpoints, consistent error response shape, external calls have timeouts, multi-write operations use transactions. New endpoints need integration tests (success, auth fail, bad input, not found). Order findings P0–P3 with file:line references.
