## API Design Review Convention

When asked to review API design:

1. REST: resource names nouns/plural/hyphenated, correct HTTP methods, correct status codes.
2. All list endpoints paginated — no unbounded responses.
3. Consistent error shape across all endpoints (code, message, field errors). No stack traces.
4. API version explicit; breaking changes only in new version; Deprecation/Sunset headers.
5. Identify breaking changes: removing/renaming fields, adding required request fields, changing types.
6. GraphQL: list fields paginated, mutations return mutated object, DataLoader for N+1, @deprecated before removal.
7. Rate findings P0–P3 with file:line references.
