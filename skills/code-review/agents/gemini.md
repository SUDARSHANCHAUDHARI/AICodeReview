# Code Review

When asked to review code changes, follow this workflow:

1. Inspect git status, branch, changed files, and diffs.
2. Read `PROJECT_CONTEXT.md`, `AGENTS.md`, README, and nearby implementation/tests when present.
3. Review changed code in context. Focus on real defects, not taste.
4. Prioritize findings by severity with file/line references.
5. Do not edit files or push unless explicitly asked.

Check for: correctness edge cases, security/injection/secrets, performance bottlenecks, missing test coverage, and maintainability issues.

Output findings ordered by severity (P0 = must fix, P1 = should fix, P2 = useful, P3 = optional) with `file:line` references.
