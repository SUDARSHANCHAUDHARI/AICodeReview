---
name: web-review
description: Use when reviewing React, Next.js, TypeScript, Node.js, or general web frontend and backend changes.
---

# Web Review

## Workflow

1. Inspect repo state, changed files, `package.json`, framework config, and relevant source/tests.
2. Read `PROJECT_CONTEXT.md`, `AGENTS.md`, README, and nearby architecture patterns when present.
3. Review changed code for web-specific correctness, security, performance, and release risk.
4. Do not edit, push, publish, or change repo settings unless explicitly asked.

## Checklist

- TypeScript: no `any`, nullability handled, types exported from a shared location, strict mode respected.
- React/Next.js: correct use of Server vs Client components, no server-only imports in client code, loading/empty/error states present.
- State: no unnecessary re-renders, stable references for callbacks and objects passed as props, correct dependency arrays in hooks.
- Data fetching: no waterfalls where parallel fetches are possible, cache invalidation correct, stale-while-revalidate used appropriately.
- Forms: input validated both client and server side, errors surfaced to users, no silent failures.
- Auth/authz: protected routes actually protected, session checks on server actions and API routes, no client-side-only auth enforcement.
- Security: no secrets in `NEXT_PUBLIC_*` env vars, CSP headers present where applicable, user input sanitized before rendering.
- Performance: no blocking scripts, images optimised, large bundle imports checked (`import { x } from 'lib'` not `import lib from 'lib'`).
- Accessibility: interactive elements keyboard-navigable, ARIA labels on icon buttons, focus management correct after route changes.
- API routes/server actions: input validated at boundary, errors return correct HTTP status, no PII logged.
- Release: `NODE_ENV` not hardcoded, environment variables documented in `.env.example`, no debug endpoints exposed in production.
- Tests: changed utilities, hooks, and API routes have unit tests where patterns exist; critical user flows have E2E coverage.

## Output

```markdown
## Web Review Findings

**[P1]** `path/to/file.tsx:42` - Short title
Why this matters and how to fix it.

## Verification

- Commands run or not run.

## Summary

Verdict and remaining risk.
```
