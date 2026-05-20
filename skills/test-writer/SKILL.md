---
name: test-writer
description: Use when generating missing tests for existing code: unit tests, integration tests, or snapshot tests. Writes real, runnable tests matched to the project's existing test patterns.
---

# Test Writer

## Workflow

1. Inspect the target code to understand its behaviour, inputs, outputs, and failure modes.
2. Read existing tests in the repo to understand the test framework, patterns, naming conventions, and assertion style used.
3. Read `PROJECT_CONTEXT.md` for test commands and known coverage gaps.
4. Write tests that cover: happy path, edge cases, error/failure cases, and boundary conditions.
5. Match existing test style exactly — do not introduce new frameworks or patterns unless asked.
6. Run the test suite after writing if a command is available. Report pass/fail.

## What To Cover

For each piece of code being tested:

- **Happy path**: expected inputs produce expected outputs.
- **Edge cases**: empty collections, zero values, max values, single items, duplicates.
- **Error cases**: invalid inputs, null/nil, network failure, DB error, permission denied.
- **Boundary conditions**: off-by-one, overflow, empty string vs null, timezone edge cases.
- **State**: verify state changes, not just return values, where relevant.
- **Side effects**: verify calls to collaborators (mocks/fakes) were made with correct arguments.

## Rules

- Do not test implementation details — test observable behaviour.
- Do not write tests that only pass because they mirror the implementation's bugs.
- Prefer real objects over mocks where setup cost is low.
- One assertion concept per test where the framework allows it.
- Test names describe the scenario: `given_X_when_Y_then_Z` or `test_methodName_condition_expectedResult`.
- Never write tests that always pass regardless of the code under test.

## Stack Defaults

- **Android/Kotlin**: JUnit 4/5 + MockK + Turbine for Flow testing. ViewModel tests use `TestCoroutineDispatcher` or `UnconfinedTestDispatcher`.
- **iOS/Swift**: XCTest. Async code tested with `async`/`await` or `XCTestExpectation`.
- **Web/TypeScript**: Vitest or Jest. React components with React Testing Library.
- **Backend**: framework-native testing. Integration tests against real or in-memory DB where practical.

## Output

Write the test file(s) directly. Then report:

```markdown
## Tests Written

- `path/to/TestFile.kt` — X tests covering Y, Z, W.

## Not Covered

- Scenario: reason it was skipped (e.g. requires real network, needs test infra not present).

## Verification

- Command run: `./gradlew test`
- Result: X passed, 0 failed.
```
