# KMP Review

When asked to review Kotlin Multiplatform (KMP) or Compose Multiplatform code, follow this workflow:

1. Inspect files in `commonMain`, `androidMain`, `iosMain`, and other source sets.
2. Read `PROJECT_CONTEXT.md`, `AGENTS.md`, and `settings.gradle.kts` for platform targets.
3. Review for KMP-specific correctness, platform boundary correctness, and build safety.
4. Do not edit unless explicitly asked.

Check: no Android/iOS SDK imports in `commonMain`, `expect`/`actual` used correctly with all targets covered, source set dependencies correct, Ktor engine/timeout/serialization configured, no hardcoded URLs, `Dispatchers.Main` handled per-platform, no `runBlocking` on iOS main thread, `StateFlow`/`SharedFlow` for iOS, public API Objective-C compatible, `suspend` exported correctly, all targets build.

Order findings P0–P3 with file.kt:line references.
