# GraphQL Review

When asked to review GraphQL code, follow this workflow:

1. Read all schema files and map types, fields, queries, mutations, and subscriptions.
2. Check naming conventions: types PascalCase, fields camelCase, enums SCREAMING_SNAKE_CASE.
3. Check nullability: non-null on stable required fields, nullable on legitimately absent data.
4. Read all resolver files; flag N+1 patterns where list resolvers issue a per-parent DB/service call without DataLoader or batching.
5. Flag auth gaps: sensitive fields with no field-level auth check in the resolver.
6. Flag missing input validation on mutation inputs (types, ranges, lengths, format).
7. Check server config for query depth and complexity limits; flag their absence.
8. Check subscription resolvers for pubsub cleanup on disconnect.
9. Identify breaking schema changes: removed fields, changed types, added required args, renamed types.
10. Check pagination consistency: flag mixed cursor and offset strategies without justification.

Check: naming, nullability, N+1, field-level auth, input validation, complexity limits, subscription cleanup, breaking changes, pagination consistency.

Order findings P0–P3 with file:line references.
