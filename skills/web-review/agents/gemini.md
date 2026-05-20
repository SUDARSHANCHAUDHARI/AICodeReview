# Web Review

When asked to review React/Next.js/TypeScript/Node changes, follow this workflow:

1. Inspect changed files, package.json, framework config, and relevant source/tests.
2. Read `PROJECT_CONTEXT.md`, `AGENTS.md`, and nearby architecture patterns.
3. Review for web-specific correctness, security, performance, and release risk.
4. Do not edit or push unless explicitly asked.

Check: no `any` in TypeScript, correct Server vs Client component split, loading/empty/error states, no request waterfalls, auth enforced server-side, no secrets in `NEXT_PUBLIC_*`, user input sanitized, images optimised, no whole-library imports, keyboard navigation and ARIA labels, API routes validate input, no debug endpoints in production.

Order findings by severity (P0–P3) with `file.tsx:line` references.
