## Test Writer Convention

When asked to generate tests:

1. Read the target code fully before writing any tests.
2. Read existing tests to match framework, naming conventions, and assertion style exactly.
3. Cover: happy path, edge cases (empty/zero/max/single/duplicates), error cases (invalid/null/network fail/DB error), state changes, side effects via mocks.
4. Test observable behaviour — not implementation details.
5. One assertion concept per test. Never write tests that always pass.
6. Prefer real objects over mocks where setup cost is low.
7. Run the test suite after writing. Report pass/fail.
