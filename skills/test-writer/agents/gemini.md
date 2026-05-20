# Test Writer

When asked to generate tests for existing code, follow this workflow:

1. Read the target code to understand its behaviour, inputs, outputs, and failure modes.
2. Read existing tests to understand the framework, patterns, naming, and assertion style.
3. Write tests covering: happy path, edge cases, error/failure cases, boundary conditions, state changes, side effects.
4. Match existing test style exactly — do not introduce new frameworks or patterns.
5. Run the test suite after writing. Report pass/fail.

Rules: test observable behaviour not implementation details. One assertion concept per test. Never write tests that always pass regardless of the code. Prefer real objects over mocks where setup cost is low.

Stack defaults: Android/Kotlin → JUnit4/5 + MockK + Turbine. iOS/Swift → XCTest. Web → Vitest/Jest + React Testing Library. Backend → framework-native + real or in-memory DB.
