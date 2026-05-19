---
name: codex-code-review
description: Use when reviewing code changes for production bugs, regressions, security issues, performance risks, missing tests, and maintainability concerns. Especially useful before commits, pull requests, or releases.
---

# Codex Code Review

## Workflow

1. Inspect repo state first: current path, git status, branch, changed files, and relevant diffs.
2. Read `PROJECT_CONTEXT.md`, `AGENTS.md`, README, and nearby implementation/tests when present.
3. Review changed code in context. Focus on real defects, not taste.
4. Prioritize findings by severity and include file/line references.
5. Do not edit files unless the user explicitly asks for fixes.

## What To Check

- Correctness: edge cases, nullability, error handling, async/concurrency, lifecycle, data loss.
- Security/privacy: auth, authorization, injection, path traversal, secrets, sensitive logging, unsafe config.
- Performance: repeated expensive work, unbounded loops, N+1 queries, main-thread blocking, memory churn.
- Tests: missing coverage for changed behavior, weak happy-path-only tests, tests that mask real behavior.
- Maintainability: inconsistent patterns, confusing ownership, avoidable duplication, risky abstraction.

## Android/Kotlin Defaults

When reviewing Android or KMP repos, also check:

- Compose state stability, recomposition safety, and UI state ownership.
- ViewModels expose observable UI state and avoid direct UI concerns.
- Coroutines use structured concurrency and appropriate dispatchers.
- Room/database access is not performed on the main thread.
- Repositories sit behind interfaces where the repo already follows Clean Architecture.
- DataStore is preferred over new SharedPreferences usage.
- Kotlinx Serialization is preferred over new Gson usage.
- Release code does not expose signing material, secrets, or store-only metadata.

## Output

Start with findings, ordered by severity.

Use this format:

```markdown
## Findings

**[P0]** `path/to/file.ext:123` - Short title
Explanation of the bug/risk, why it matters, and a concrete fix direction.

**[P1]** `path/to/file.ext:45` - Short title
...

## Open Questions

- ...

## Summary

Brief overall judgment and test gaps.
```

Severity guide:

- `P0`: must fix before merge/release; data loss, security breach, crash, or broken core workflow.
- `P1`: should fix; likely production bug, significant regression, missing critical test.
- `P2`: useful fix; maintainability, edge case, minor performance risk.
- `P3`: optional polish; mention sparingly.

If no issues are found, say so clearly and mention any residual test/build risk.
