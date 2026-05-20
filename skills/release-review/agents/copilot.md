## Release Review

When asked to check release readiness: verify version code/name and changelog are consistent, release build avoids debug config, no secrets or signing files committed, Android builds AAB not APK, permissions and privacy policy are aligned, CI checks are passing, and DB/schema migrations are forward-safe. Output blockers first, then should-fix, then nice-to-have. Conclude with READY / NOT READY / BLOCKED.
