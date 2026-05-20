# Refactor Planner

When asked to plan a refactor, follow this workflow:

1. Understand the refactor goal — ask if unclear.
2. Read all files involved before making claims about structure or dependencies.
3. Identify blast radius: directly/indirectly affected files, API surface changes, DB/schema changes, build/config changes.
4. Sequence into safe increments — each must leave the codebase buildable and testable.
5. Define rollback for each step.
6. Do not make changes — produce a plan for the user to review first.

Output: Current State, Blast Radius, Incremental Plan (step/what/verify/rollback), Risks & Unknowns, Recommendation.

Rules: never combine delete-old and add-new in the same step. Call out breaking API changes explicitly. Recommend feature flags for large changes.
