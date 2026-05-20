## Web Review Convention

When asked to review React/Next.js/TypeScript/Node changes:

1. Check no `any` in TypeScript, nullability handled, strict mode respected.
2. Check correct Server vs Client components, loading/empty/error states present.
3. Check no unnecessary re-renders, correct hook dependency arrays.
4. Check no request waterfalls, cache invalidation correct.
5. Check auth enforced server-side, not client-side only.
6. Check no secrets in `NEXT_PUBLIC_*`, user input sanitized.
7. Check images optimised, no whole-library imports.
8. Check keyboard navigation and ARIA labels.
9. Check API routes validate input and return correct HTTP status.
10. Order findings P0–P3 with file.tsx:line references.
