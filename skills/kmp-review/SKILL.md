---
name: kmp-review
description: Use when reviewing Kotlin Multiplatform (KMP) or Compose Multiplatform code: shared module, expect/actual declarations, platform-specific implementations, Ktor, or multiplatform builds.
---

# KMP Review

## Workflow

1. Inspect changed files in `commonMain`, `androidMain`, `iosMain`, and other source sets.
2. Read `PROJECT_CONTEXT.md`, `AGENTS.md`, and `settings.gradle.kts` to understand the target platforms and module structure.
3. Review for KMP-specific correctness, platform boundary correctness, and build safety.
4. Do not edit, push, or change settings unless explicitly asked.

## Checklist

### Module Structure
- Business logic lives in `commonMain` — no Android or iOS SDK imports leaking into shared code.
- `expect`/`actual` declarations used for genuinely platform-specific behaviour; not overused for things that could be common.
- Source set dependencies are correct: `commonMain` does not depend on `androidMain` or `iosMain`.
- Gradle source set hierarchy matches the Kotlin Multiplatform plugin conventions.

### expect/actual
- Every `expect` declaration has a matching `actual` in every declared target.
- `actual` implementations behave consistently across platforms — no silent divergence in error handling or edge cases.
- `actual typealias` used where a platform type satisfies the contract rather than duplicating code.

### Networking (Ktor)
- Ktor client engine configured per platform (`OkHttp` for Android, `Darwin` for iOS).
- Request timeout and retry logic defined at the client level, not per-call.
- Serialization plugin configured correctly for `kotlinx.serialization`.
- No hardcoded base URLs — inject from config or `BuildConfig`.

### Coroutines / Concurrency
- `Dispatchers.Main` used correctly on each platform; not assumed to be the same.
- `kotlinx-coroutines-core` used for shared async — no platform threading APIs in `commonMain`.
- iOS: `runBlocking` not used on the main thread; Swift async interop considered.
- Flows exposed from shared code use `StateFlow` or `SharedFlow` where iOS consumption is expected.

### iOS Interop
- Public API from shared module is Objective-C compatible where needed (`@ObjCName`, no generics on `actual` interfaces).
- `suspend` functions exported to Swift correctly (consider KMP-NativeCoroutines or SKIE if used).
- Memory management: no circular references between Kotlin and Swift objects.

### Build
- All targets build cleanly: `./gradlew build` or per-target tasks.
- `cocoapods` or SPM integration configured correctly if used for iOS framework distribution.
- Version catalogs used consistently across modules.

## Output

```markdown
## KMP Review Findings

**[P1]** `shared/src/commonMain/kotlin/repo/UserRepo.kt:34` - Android SDK import in commonMain
`android.util.Log` imported directly. Use `expect`/`actual` or a multiplatform logging lib.

## Summary

Platform boundary health and build safety verdict.
```
