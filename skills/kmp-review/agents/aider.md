## KMP Review Convention

When asked to review Kotlin Multiplatform code:

1. Check no Android/iOS SDK imports in `commonMain`.
2. Check `expect`/`actual` used correctly; all targets have matching `actual`.
3. Check source set dependencies correct.
4. Check Ktor: platform engine, timeout/retry, serialization, no hardcoded URLs.
5. Check `Dispatchers.Main` handled per-platform; no `runBlocking` on iOS main thread.
6. Check `StateFlow`/`SharedFlow` used for iOS consumption.
7. Check public API Objective-C compatible; `suspend` exported correctly.
8. Verify all targets build cleanly.
9. Order findings P0–P3 with file.kt:line references.
