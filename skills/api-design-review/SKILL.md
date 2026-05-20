---
name: api-design-review
description: Use when reviewing REST or GraphQL API design: naming conventions, versioning, error contracts, pagination, breaking changes, and developer experience.
---

# API Design Review

## Workflow

1. Inspect route definitions, OpenAPI/Swagger specs, GraphQL schemas, and relevant handler code.
2. Read `PROJECT_CONTEXT.md`, `AGENTS.md`, and API docs when present.
3. Review for design consistency, breaking change risk, and developer experience.
4. Do not edit files unless explicitly asked.

## REST Checklist

### Naming & Structure
- Resource names are nouns, plural: `/users`, `/orders`, not `/getUser`, `/createOrder`.
- Nested resources reflect real ownership: `/users/{id}/orders`, not flat `/userOrders?userId=`.
- Path segments are lowercase and hyphenated: `/shipping-addresses`, not `/shippingAddresses`.
- Query parameters used for filtering, sorting, pagination — not for actions.
- No verbs in paths except for non-resource actions where REST genuinely does not fit (e.g. `/payments/{id}/refund`).

### HTTP Methods & Status Codes
- GET is side-effect free and cacheable.
- POST creates or triggers; returns 201 with `Location` header for created resources.
- PUT replaces the full resource; PATCH applies partial updates.
- DELETE returns 204 (no body) on success.
- Status codes consistent and correct: 400 (bad request), 401 (unauthenticated), 403 (forbidden), 404 (not found), 409 (conflict), 422 (validation), 429 (rate limited), 500 (server error).

### Error Shape
- All error responses have a consistent structure across all endpoints.
- Error body includes: machine-readable code, human-readable message, and field-level errors for validation failures.
- No stack traces or internal paths in production error responses.

### Versioning
- API version is explicit: URI versioning (`/v1/`) or header versioning (`Accept: application/vnd.api+json;version=1`).
- Breaking changes are never made to existing versioned endpoints without a new version.
- Deprecation communicated via `Deprecation` and `Sunset` response headers.

### Pagination
- All list endpoints are paginated — no unbounded responses.
- Cursor-based pagination preferred over offset for large or frequently-updated datasets.
- Response includes pagination metadata: next cursor or total count, page size, links.

### Breaking Changes
- Adding required fields to request bodies is a breaking change.
- Removing or renaming fields in responses is a breaking change.
- Changing field types is a breaking change.
- New optional fields and new endpoints are non-breaking.

## GraphQL Checklist
- Queries are not unbounded — pagination or `first`/`last` args on list fields.
- Mutations return the mutated object, not just a success flag.
- Errors use the GraphQL error extension format, not HTTP error codes.
- N+1 risk on resolvers — DataLoader or batching applied.
- Breaking schema changes follow deprecation (`@deprecated`) before removal.

## Output

```markdown
## API Design Findings

**[P1]** `routes/users.js:12` - Verb in resource path
`POST /createUser` should be `POST /users`.

**[P2]** `routes/orders.js:45` - Unbounded list endpoint
GET /orders returns all records. Add pagination.

## Summary

Consistency verdict and most impactful design issues.
```
