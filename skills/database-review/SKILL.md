---
name: database-review
description: Use when reviewing database schema design, migrations, queries, indexing strategy, transactions, or ORM usage across any stack.
---

# Database Review

## Workflow

1. Inspect schema files, migration files, query code, ORM models, and relevant tests.
2. Read `PROJECT_CONTEXT.md` and `AGENTS.md` for known risk areas or active migrations.
3. Review for schema correctness, query efficiency, migration safety, and data integrity.
4. Do not edit files unless explicitly asked.

## Checklist

### Schema Design
- Tables have a clear primary key; composite keys used intentionally, not by accident.
- Column types match the data: no storing numbers as strings, no oversized `VARCHAR(MAX)` where a specific length works.
- Nullable columns are nullable for a real reason — avoid nullability as a lazy default.
- Foreign key constraints defined where referential integrity is expected.
- Soft-delete columns (`deleted_at`, `is_deleted`) are indexed and queries filter them correctly.

### Indexing
- Columns used in `WHERE`, `ORDER BY`, `JOIN ON`, and `GROUP BY` clauses have appropriate indexes.
- Composite index column order matches query patterns (leading column first).
- No missing indexes on foreign key columns.
- No redundant indexes that duplicate existing ones.
- High-write tables are not over-indexed (each index slows writes).

### Migrations
- Migrations are reversible where possible (have a `down` path).
- Adding a `NOT NULL` column to a large existing table includes a default or a multi-step approach to avoid table lock.
- Renaming or dropping columns done in phases to avoid breaking running instances during deploy.
- Index creation uses `CREATE INDEX CONCURRENTLY` (Postgres) or equivalent to avoid table lock.
- Migration does not depend on application code that may not yet be deployed.

### Queries
- No N+1 patterns — batch or join where loading related data.
- No `SELECT *` in production code — project only needed columns.
- Queries on large tables use indexed columns in `WHERE` clauses.
- `LIKE '%value%'` searches understood to be full-table scans.
- Aggregations (`COUNT`, `SUM`, `GROUP BY`) on large tables are bounded or cached.

### Transactions
- Multi-step writes that must succeed or fail together are wrapped in a transaction.
- Transactions are short — no long-running work (API calls, heavy computation) inside a transaction.
- Deadlock risk considered when multiple tables are updated in a transaction.

### ORM Usage (Room, Prisma, ActiveRecord, etc.)
- Eager loading used where N+1 is possible; lazy loading understood and intentional.
- Raw queries used only when ORM cannot express the query; parameterised correctly.
- Room: `@Transaction` used for multi-table operations; queries run on background thread.

## Output

```markdown
## Database Review Findings

**[P0]** `db/migrations/0042_add_column.sql` - NOT NULL column added without default on large table
This will lock the table during migration. Use a multi-step approach.

**[P1]** `src/repo/UserRepository.kt:88` - N+1 in user list query
...

## Summary

Migration safety verdict and highest-risk findings.
```
