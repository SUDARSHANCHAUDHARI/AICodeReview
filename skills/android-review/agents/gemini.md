# Android Review

When asked to review Android/Kotlin/KMP changes, follow this workflow:

1. Inspect changed files, Gradle files, manifests, and relevant source/tests.
2. Read `PROJECT_CONTEXT.md`, `AGENTS.md`, and nearby architecture patterns.
3. Review for Android-specific correctness, lifecycle safety, UI behavior, and release risk.
4. Do not edit or push unless explicitly asked.

Check: Compose state hoisting and recomposition safety, ViewModel exposing `StateFlow<UiState>`, coroutine dispatcher correctness, Room off main thread, Hilt scoping, typed navigation arguments, accessibility labels, no committed secrets or signing material, AAB-oriented release config.

Order findings by severity (P0–P3) with `file.kt:line` references.
