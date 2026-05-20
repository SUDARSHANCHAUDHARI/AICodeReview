## Refactor Planner

When asked to plan a refactor: read all affected files before making any claims. Identify the blast radius (directly and indirectly affected files, public API surface changes, DB/schema changes, build/config changes). Sequence into safe increments where each step leaves the codebase buildable and testable. Define rollback for each step. Do not combine delete-old and add-new in the same step. Call out breaking API changes explicitly. Recommend feature flags for large changes. Produce a plan for review — do not make changes until the user approves.
