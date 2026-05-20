## GraphQL Review Convention

When asked to review GraphQL code:

1. Read all schema files; map types, fields, queries, mutations, subscriptions.
2. Check naming: types PascalCase, fields camelCase, enums SCREAMING_SNAKE_CASE.
3. Check nullability: non-null on stable required fields, nullable on optional data.
4. Read resolvers; flag N+1 where list resolvers query per parent without DataLoader or batch.
5. Flag sensitive fields with no field-level auth check in the resolver.
6. Flag missing input validation on mutation inputs.
7. Flag missing query depth and complexity limits in server config.
8. Flag subscription resolvers without pubsub cleanup on disconnect.
9. Flag breaking schema changes (removed fields, type changes, new required args, renames).
10. Flag mixed pagination conventions (cursor vs offset) without documented justification.
11. Output P0–P3 findings with file:line and a one-line fix per finding.
