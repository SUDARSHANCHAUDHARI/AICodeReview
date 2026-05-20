## iOS Review Convention

When asked to review iOS/macOS/Swift/SwiftUI changes:

1. Check SwiftUI property wrappers and state hoisting.
2. Check Swift Concurrency: `async`/`await` over callbacks, `Task` cancellation, `@MainActor` on UI.
3. Check for retain cycles (`[weak self]` in closures).
4. Check `NavigationStack` used over deprecated `NavigationView`.
5. Check no main-thread blocking persistence calls.
6. Check Keychain for sensitive storage, no hardcoded secrets, no PII in logs.
7. Check accessibility labels and dynamic type support.
8. Check bundle ID, version, entitlements are consistent for release.
9. Order findings P0–P3 with File.swift:line references.
