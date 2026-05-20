---
name: performance-review
description: Use when reviewing code specifically for performance: CPU, memory, rendering, database query cost, network efficiency, startup time, or bundle size.
---

# Performance Review

## Workflow

1. Inspect changed files, profiling data, benchmarks, or performance-related config when present.
2. Read `PROJECT_CONTEXT.md`, `AGENTS.md`, and README to understand performance expectations.
3. Review for concrete, measurable performance risks — not speculative micro-optimisations.
4. Do not edit files unless explicitly asked.

## What To Check

### CPU / Compute
- Expensive work (sorting, filtering, crypto, serialization) done inside tight loops or hot paths.
- Unnecessary re-computation where results could be memoised or cached.
- Blocking I/O or synchronous work on threads/queues that should stay responsive.
- Recursive algorithms without depth limits or memoisation on large inputs.

### Memory
- Large collections built in memory that could be streamed or paginated.
- Object retention: references kept alive longer than needed, preventing GC.
- Android: Bitmap allocations not recycled, Drawable references held in static context.
- iOS: retain cycles, large images held in memory without downscaling.
- Web: event listeners not removed on component unmount.

### Rendering / UI
- Android: unnecessary recompositions from unstable Compose state, overdraw in custom drawing.
- iOS: view body complexity causing slow diffs, main-thread work during scroll.
- Web: render-blocking scripts, layout thrashing (read then write DOM repeatedly), missing `key` props causing full list re-renders.

### Database / Storage
- Queries missing indexes on filter/sort columns.
- N+1 query patterns — one query per item in a loop.
- Loading entire table when a `LIMIT` or projection would suffice.
- Large transactions holding locks longer than needed.

### Network
- Chatty APIs making many small requests where batching is possible.
- Large payloads without compression or pagination.
- Missing HTTP caching headers on cacheable responses.
- Polling where WebSocket or SSE would be more efficient.

### Bundle / Startup
- Web: large whole-library imports (`import _ from 'lodash'`), missing code splitting.
- Android: R8/ProGuard not stripping unused code, large assets in APK/AAB.
- iOS: slow `+load` or static initializers blocking app launch.

## Output

```markdown
## Performance Findings

**[P1]** `path/to/file.ext:42` - N+1 query: one DB call per item in loop
At 1000 items this makes 1001 queries. Fix: use a single query with IN clause or join.

**[P2]** `path/to/file.ext:88` - Unstable lambda in Compose
New lambda instance created on every recomposition, breaking `LazyColumn` stability.

## Summary

Highest-impact findings and estimated severity.
```
