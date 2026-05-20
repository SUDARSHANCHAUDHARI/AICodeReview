## Refactor Planner Convention

When asked to plan a refactor:

1. Read all affected files before making claims — do not guess at structure.
2. Identify blast radius: directly/indirectly affected files, API changes, DB/schema changes.
3. Sequence into safe increments — each step leaves the codebase buildable and testable.
4. Define rollback for each step.
5. Never combine delete-old and add-new in the same step.
6. Call out breaking API changes explicitly.
7. Recommend feature flags for large changes.
8. Produce a plan for review — do not make changes until approved.
