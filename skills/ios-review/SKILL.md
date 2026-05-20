---
name: ios-review
description: Use when reviewing iOS, macOS, Swift, SwiftUI, Combine, Swift Concurrency, Xcode, or App Store release changes.
---

# iOS Review

## Workflow

1. Inspect repo state, changed files, `Package.swift` or `.xcodeproj`, and relevant source/tests.
2. Read `PROJECT_CONTEXT.md`, `AGENTS.md`, README, and nearby architecture patterns when present.
3. Review changed code for iOS/macOS-specific correctness, lifecycle safety, UI behavior, and release risk.
4. Do not edit, push, publish, or change repo settings unless explicitly asked.

## Checklist

- SwiftUI: view body complexity, state hoisting, correct property wrappers (`@State`, `@Binding`, `@StateObject`, `@ObservedObject`, `@EnvironmentObject`, `@Observable`).
- State management: single source of truth, no redundant state, updates on `@MainActor` where required.
- Swift Concurrency: `async`/`await` used over callbacks, `Task` cancellation handled, no actor isolation violations.
- Combine: subscription lifetimes managed (stored in `cancellables`), no retain cycles.
- Memory: no retain cycles in closures (`[weak self]` where needed), no large objects captured unnecessarily.
- Navigation: `NavigationStack` used over deprecated `NavigationView`, deep link handling correct.
- Persistence: CoreData/SwiftData on correct context, no main-thread blocking fetches.
- Networking: `URLSession` used with async/await, errors handled, no sensitive data logged.
- Accessibility: `accessibilityLabel`, `accessibilityHint`, dynamic type support, VoiceOver compatible.
- Security: no hardcoded secrets or API keys, Keychain used for sensitive storage, no cleartext data in logs.
- Release: bundle ID, version, build number consistent; entitlements match capabilities; no debug-only code in release path.
- Tests: changed ViewModels/use cases have unit tests, UI tests cover critical flows where patterns exist.

## Output

```markdown
## iOS Review Findings

**[P1]** `path/to/File.swift:42` - Short title
Why this matters and how to fix it.

## Verification

- Commands run or not run.

## Summary

Verdict and remaining risk.
```
