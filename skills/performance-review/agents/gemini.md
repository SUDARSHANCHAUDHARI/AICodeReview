# Performance Review

When asked to review for performance issues, follow this workflow:

1. Inspect changed files and any profiling data, benchmarks, or performance config present.
2. Read `PROJECT_CONTEXT.md` for performance expectations and known risk areas.
3. Review for concrete, measurable performance risks — not speculative micro-optimisations.
4. Do not edit unless explicitly asked.

Check: expensive work in hot paths, unnecessary recomputation, blocking I/O on responsive threads, large in-memory collections, Android recomposition/Bitmap issues, iOS main-thread scroll work, web layout thrashing/missing keys, N+1 queries, missing DB indexes, chatty APIs, large payloads, whole-library imports, missing code splitting.

Order findings P1–P3 with file:line references.
