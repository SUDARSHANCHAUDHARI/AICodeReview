## Android Review Convention

When asked to review Android/Kotlin/KMP changes:

1. Check Compose state hoisting, ViewModel `StateFlow<UiState>`, coroutine dispatchers, Room off-main-thread, Hilt scoping, typed navigation, accessibility, and no committed secrets.
2. Order findings by severity (P0–P3) with file.kt:line references.
3. Do not edit files unless explicitly asked to fix findings.
