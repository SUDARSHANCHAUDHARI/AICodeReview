---
name: graphql-review
description: Review GraphQL schema, resolvers, and client queries for N+1 problems, auth gaps, missing validation, complexity limits, and breaking changes.
---

# GraphQL Review

When asked to review GraphQL code, follow this workflow:

1. Read the schema file(s) — .graphql, .gql, or schema definitions in code. Map all types, fields, queries, mutations, and subscriptions.
2. Check schema naming conventions: types PascalCase, fields camelCase, enum values SCREAMING_SNAKE_CASE. Flag deviations.
3. Check nullability design: fields that should never be null must be marked non-null (`!`). Fields that can legitimately be absent should be nullable. Flag fields that appear backwards (non-null on volatile data, nullable on required IDs).
4. Read all resolver files. For each list/connection resolver that returns a collection, check whether it calls a separate loader per parent (N+1). Flag resolvers that issue individual DB/service queries inside a loop without a DataLoader or batch function.
5. Check authentication and authorisation at field and type level: verify that sensitive fields (PII, admin data, private resources) have auth checks in the resolver, not just at the route/middleware level.
6. Check input validation on all mutation inputs: types, ranges, length limits, format constraints. Flag missing validation.
7. Check for query depth and complexity limits in server config (max depth, max complexity, query cost). Flag their absence.
8. Check subscription resolvers: verify pubsub channels are cleaned up on disconnect and that subscriptions are not created without a corresponding unsubscribe path.
9. Identify breaking schema changes compared to the base branch or previous schema snapshot: removed fields, changed field types, added required arguments, renamed types. Flag each as breaking.
10. Check pagination conventions: are list fields using cursor-based pagination (Relay-style) or offset pagination consistently? Flag mixing of both without documented reason.
11. Order all findings P0–P3:
    - P0: auth missing on sensitive field, N+1 on high-traffic resolver, breaking schema change without deprecation
    - P1: no query depth/complexity limit, subscription without cleanup, missing input validation on mutation
    - P2: nullability mismatch, inconsistent pagination convention, naming convention deviation
    - P3: minor documentation gap, enum naming style
12. Output each finding with: severity, file:line, description, and one-sentence fix.

Output: Findings list P0–P3 with file references and fix suggestions.

Rules:
- Read actual resolver code before flagging N+1 — a DataLoader call inside the resolver resolves the issue.
- Do not flag nullable fields as a problem if the schema intent is clearly documented.
- Breaking change detection requires access to the previous schema; if unavailable, note that the check was skipped.
