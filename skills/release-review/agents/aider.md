## Release Review Convention

Before any release:

1. Verify version code/name and changelog are consistent.
2. Confirm release build avoids debug config.
3. Check no secrets, signing files, or tokens are committed.
4. Android: build AAB not APK.
5. Confirm CI checks pass and DB migrations are forward-safe.
6. Output: blockers, should-fix, nice-to-have. Conclude READY / NOT READY / BLOCKED.
