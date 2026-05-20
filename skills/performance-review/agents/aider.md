## Performance Review Convention

When asked to review for performance:

1. Check expensive work in hot paths and tight loops.
2. Check for unnecessary recomputation — memoize/cache where applicable.
3. Check blocking I/O on responsive threads/queues.
4. Android: unstable Compose state, Bitmap lifecycle.
5. iOS: main-thread work during scroll, large images in memory.
6. Web: render-blocking scripts, layout thrashing, missing stable list keys.
7. DB: N+1, missing indexes, unbounded SELECT.
8. Network: chatty APIs, missing caching, large uncompressed payloads.
9. Bundle: whole-library imports, missing code splitting.
10. Focus on concrete measurable risks. Order findings P1–P3 with file:line references.
