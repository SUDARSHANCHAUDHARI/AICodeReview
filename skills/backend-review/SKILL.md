---
name: backend-review
description: Use when reviewing backend API code, server-side logic, REST or GraphQL endpoints, middleware, authentication, rate limiting, or data processing pipelines.
---

# Backend Review

## Workflow

1. Inspect repo state, changed files, route definitions, middleware, and relevant tests.
2. Read `PROJECT_CONTEXT.md`, `AGENTS.md`, README, and API docs when present.
3. Review changed code for backend-specific correctness, security, performance, and API contract quality.
4. Do not edit, push, or change settings unless explicitly asked.

## Checklist

### API Design
- Routes follow consistent naming conventions (nouns not verbs, plural resources).
- HTTP methods used correctly: GET is idempotent and side-effect free, POST/PUT/PATCH/DELETE used appropriately.
- Status codes are correct: 200/201/204 for success, 400 for client errors, 401/403 for auth, 404 for not found, 409 for conflict, 422 for validation, 500 for server errors.
- Pagination implemented for list endpoints (cursor or offset), not returning unbounded results.
- Error responses have a consistent shape across all endpoints.

### Security
- All endpoints that require authentication actually check it — no missing auth middleware.
- Authorization checks ownership: user A cannot access user B's resources (IDOR risk).
- Input validated and sanitised at the boundary before use.
- No sensitive data (passwords, tokens, PII) returned in responses or logged.
- Rate limiting applied to auth, signup, and high-cost endpoints.
- SQL queries use parameterised statements — no string interpolation.

### Performance
- No N+1 queries — batch or join where needed.
- Expensive operations (external APIs, heavy DB queries) not blocking the request path unnecessarily.
- Database queries use appropriate indexes.
- No unbounded queries that could return millions of rows.
- Caching applied where appropriate; cache keys are correct and invalidation is considered.

### Reliability
- Errors are handled and return meaningful responses — no swallowed exceptions.
- External service calls have timeouts and failure handling.
- Database transactions used where multiple writes must be atomic.
- Idempotency considered for operations that can be retried (webhooks, payment callbacks).

### Tests
- New endpoints have integration tests covering success, auth failure, invalid input, and not-found cases.
- Business logic has unit tests independent of HTTP layer.

## Output

```markdown
## Backend Review Findings

**[P0]** `path/to/file.ext:123` - Missing auth check on DELETE /users/:id
Any authenticated user can delete any account. Add ownership check.

**[P1]** `path/to/file.ext:45` - N+1 query in GET /posts
...

## Summary

Verdict and remaining risk.
```
