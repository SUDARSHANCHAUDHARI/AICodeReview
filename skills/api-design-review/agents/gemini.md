# API Design Review

When asked to review REST or GraphQL API design, follow this workflow:

1. Inspect route definitions, OpenAPI/Swagger specs, GraphQL schemas, and handler code.
2. Read `PROJECT_CONTEXT.md` and API docs when present.
3. Review for naming consistency, HTTP correctness, error contracts, versioning, and breaking changes.
4. Do not edit unless explicitly asked.

REST: nouns/plural/hyphenated paths, correct HTTP methods and status codes (201+Location, 204, 400/401/403/404/409/422/429/500), all lists paginated, consistent error shape, no stack traces in responses, explicit versioning, breaking changes only in new version, Deprecation/Sunset headers. GraphQL: list fields paginated, mutations return mutated object, DataLoader for N+1, @deprecated before removal.

Identify breaking vs non-breaking changes explicitly. Rate P0–P3 with file:line references.
