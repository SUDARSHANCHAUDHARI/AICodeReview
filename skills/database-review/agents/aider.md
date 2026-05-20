## Database Review Convention

When asked to review database changes:

1. Check PKs defined, column types correct, FK constraints present.
2. Check indexes on WHERE/ORDER BY/JOIN columns; composite order correct; no redundant indexes.
3. Migrations: reversible, NOT NULL on large table uses multi-step, CONCURRENTLY for index creation.
4. Queries: no N+1, no SELECT *, indexed WHERE clauses, bounded aggregations.
5. Transactions: multi-writes atomic, transactions short, deadlock risk considered.
6. ORM: Room uses @Transaction and background threads.
7. Rate findings P0–P3 with file:line references.
