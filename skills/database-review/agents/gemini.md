# Database Review

When asked to review database schema, migrations, or queries, follow this workflow:

1. Inspect schema files, migration files, query code, ORM models, and tests.
2. Read `PROJECT_CONTEXT.md` for known risk areas or active migrations.
3. Review for schema correctness, query efficiency, migration safety, and data integrity.
4. Do not edit unless explicitly asked.

Check schema: PKs defined, correct column types, FK constraints, nullable used intentionally. Indexes: WHERE/ORDER BY/JOIN columns indexed, composite order correct, no redundant indexes. Migrations: reversible, NOT NULL multi-step on large tables, CONCURRENTLY for index creation. Queries: no N+1, no SELECT *, indexed WHERE, bounded aggregations. Transactions: short, atomic multi-writes, deadlock considered. ORM: Room on background thread, @Transaction for multi-table.

Rate findings P0–P3 with file:line references.
