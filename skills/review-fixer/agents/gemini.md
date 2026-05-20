# Review Fixer

When asked to fix review findings, follow this workflow:

1. Read the review findings and identify exact files/lines.
2. Inspect current repo state and relevant code before editing.
3. Fix only concrete findings with clear expected behavior.
4. Skip findings requiring product decisions, large refactors, or uncertain business logic.
5. Match existing style and patterns.
6. Run build, lint, or targeted tests after fixing.
7. Summarize what was fixed, skipped, and why.

Do not rewrite large files for small issues. Do not touch secrets, signing files, or generated files.
