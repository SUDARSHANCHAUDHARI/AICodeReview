---
name: react-native-review
description: Review React Native code for JS thread blocking, bridge inefficiency, memory leaks, FlatList misuse, platform isolation, and deep link security.
---

# React Native Review

When asked to review React Native code, follow this workflow:

1. Read all source files in scope (JS/TS, native modules if present).
2. Check for JS thread blocking: synchronous heavy computation (crypto, parsing, sorting large arrays) running on the JS thread without being moved to a worker or native module. Flag each occurrence.
3. Check bridge call patterns: native module calls made inside tight loops or rapid event handlers without batching. Flag where calls could be collapsed.
4. Check list rendering: any list with more than 20 items rendered via ScrollView instead of FlatList or SectionList. Flag it — ScrollView renders all items at once.
5. Check useCallback and useMemo usage for callbacks passed to native components: missing memoization on event handlers causes unnecessary bridge traffic and rerenders.
6. Check for memory leaks:
   - Event listener or DeviceEventEmitter subscriptions not removed in useEffect cleanup or componentWillUnmount.
   - setInterval/setTimeout not cleared.
   - Subscriptions (store, push notification listeners) not cancelled on unmount.
7. Check OTA update safety (CodePush or similar): verify updates are staged, rollback is configured, and mandatory update flags are not used on every release.
8. Check platform-specific code isolation: Platform.OS checks or platform-specific file suffixes (.ios.ts, .android.ts) should contain all platform branching — flag business logic tangled with platform checks inline.
9. Check deep link handling: incoming URLs must be validated and sanitised before use. Flag direct use of URL params in navigation or API calls without sanitisation.
10. Check navigation patterns: verify back stack is predictable, and that navigation state is not mutated directly.
11. Order all findings P0–P3:
    - P0: JS thread blocking on main interaction path, deep link param used without sanitisation, memory leak in critical screen
    - P1: ScrollView for long list, missing cleanup for event listeners, bridge calls in tight loop
    - P2: missing useCallback for native callbacks, platform logic tangled with business logic
    - P3: minor memoization opportunity, CodePush staged rollout not configured
12. Output each finding with: severity, file:line, description, and one-sentence fix.

Output: Findings list P0–P3 with file references and fix suggestions.

Rules:
- Read actual component and hook code before flagging — do not guess from import names.
- useCallback without a dependency array is not a fix — flag incorrect dependency arrays too.
- Do not flag useMemo as missing on every value — only where it demonstrably prevents bridge traffic or expensive recompute.
