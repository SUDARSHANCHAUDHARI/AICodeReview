# Release Review

When asked to check release readiness, follow this workflow:

1. Inspect repo status, branch, recent commits, version files, release notes, and build config.
2. Read `PROJECT_CONTEXT.md`, `AGENTS.md`, release docs, and CI config when present.
3. Identify release blockers first. Do not make changes unless asked.

Check: version code/name and changelog consistency, release build avoids debug config, no secrets or signing files committed, Android builds AAB not APK, permissions and privacy policy aligned, CI checks passing, DB/schema migrations forward-safe, risky changes have fallbacks.

Output: blockers first, then should-fix, then nice-to-have. Conclude with READY / NOT READY / BLOCKED.
