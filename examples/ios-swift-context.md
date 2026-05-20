# Project Context

## What This Project Is

- Product: Native iOS application distributed via the Apple App Store.
- Users: Consumer-facing; targeting iOS 17+.
- Main platform: Swift 5.10, SwiftUI, Xcode 16.

## Tech Stack

- Language: Swift 5.10.
- UI framework: SwiftUI (100%; no UIKit unless bridging unavoidable).
- State management: `@Observable` macro (Swift 5.9+) for view models and shared state.
- Concurrency: Swift Concurrency (`async`/`await`, `Task`, `TaskGroup`, `AsyncStream`).
- Persistence: SwiftData (primary); CoreData for legacy data if upgrading from an older version.
- Networking: `URLSession` with async/await; Codable for JSON decoding.
- Testing: XCTest (unit and integration), Swift Testing framework for new tests.
- Linting: SwiftLint (rules in `.swiftlint.yml`).
- Dependency manager: Swift Package Manager (SPM); no CocoaPods.

## Architecture

```
App/
  AppEntry.swift       # @main, WindowGroup, environment injection
  AppModel.swift       # root @Observable app model (auth state, deep link routing)
Features/
  <FeatureName>/
    <FeatureName>View.swift       # SwiftUI view; reads from ViewModel
    <FeatureName>ViewModel.swift  # @Observable class; owns async Tasks
    <FeatureName>Model.swift      # domain value types (struct)
Shared/
  Services/            # URLSession wrappers, push notification service, etc.
  Persistence/         # SwiftData container setup, migration plans
  Components/          # reusable SwiftUI views
  Extensions/          # Swift standard library and Foundation extensions
Tests/
  Unit/                # XCTest; mock services via protocols
  Integration/         # SwiftData in-memory store tests
```

- Navigation: `NavigationStack` + `navigationDestination(for:)` with a typed
  `Hashable` route enum per feature.
- Dependency injection: environment values (`@Environment`) for app-wide singletons;
  direct init injection for feature view models.
- Error handling: `do { try await ... } catch { }` with typed errors; never `try!`.
- `@MainActor`: all ViewModels and UI-bound async methods marked `@MainActor`.

## Review Priorities

- `@MainActor` boundaries: background tasks must not touch UI state off the main actor.
- Task lifetime: `Task {}` spawned in a view or view model must be cancelled in
  `onDisappear` or `deinit` to prevent leaks.
- SwiftData thread safety: `ModelContext` is not `Sendable`; do not pass across
  actor boundaries.
- Force unwraps: `!` and `try!` are banned in production code; use `guard let` or
  `if let`.
- Codable: new fields added to an API response type must have a default value
  (`= nil` or a literal) to maintain backward compatibility with cached responses.
- Accessibility: `accessibilityLabel`, `accessibilityHint`, and `.accessibilityElement`
  on all interactive controls.
- Privacy: no PII written to `UserDefaults` without encryption; no logging of tokens.

## Commands

- Build: `xcodebuild -scheme AppName -destination 'platform=iOS Simulator,name=iPhone 16' build`
- Run tests: `xcodebuild test -scheme AppName -destination 'platform=iOS Simulator,name=iPhone 16'`
- Lint: `swiftlint lint`
- Lint with autocorrect: `swiftlint --fix`
- Resolve SPM packages: `xcodebuild -resolvePackageDependencies`
- Archive for TestFlight: `xcodebuild archive -scheme AppName -archivePath build/AppName.xcarchive`

## Known Risk Areas

- SwiftData `@Query` results are updated on the main actor; avoid triggering
  expensive re-renders in list views by scoping `@Query` predicates tightly.
- Async image loading without caching will hammer the network on scroll; use
  `AsyncImage` with a custom URLCache configuration or a caching library.
- `NavigationStack` path binding can de-sync if route objects are not properly
  `Equatable` and `Hashable`.

## Active Migrations

- Add entries here when a data model migration or SDK upgrade is in progress
  (e.g., migrating CoreData schema to SwiftData, adopting Swift Testing).
