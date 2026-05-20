# iOS Review

When asked to review iOS/macOS/Swift/SwiftUI changes, follow this workflow:

1. Inspect changed Swift files, Package.swift, and relevant source/tests.
2. Read `PROJECT_CONTEXT.md`, `AGENTS.md`, and nearby architecture patterns.
3. Review for iOS/macOS-specific correctness, lifecycle safety, and release risk.
4. Do not edit or push unless explicitly asked.

Check: SwiftUI property wrappers and state hoisting, Swift Concurrency (`async`/`await`, `Task` cancellation, `@MainActor`), no retain cycles, `NavigationStack` over `NavigationView`, no main-thread blocking persistence, Keychain for sensitive storage, no hardcoded secrets, accessibility labels, consistent bundle ID/version/entitlements.

Order findings by severity (P0–P3) with `File.swift:line` references.
