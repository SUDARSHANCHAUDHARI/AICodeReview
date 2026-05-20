# React Native Review

When asked to review React Native code, follow this workflow:

1. Read all source files in scope (JS/TS, native modules).
2. Flag JS thread blocking: heavy synchronous work (crypto, parsing, large sorts) not offloaded to a worker or native module.
3. Flag bridge calls in tight loops or rapid event handlers without batching.
4. Flag lists of more than 20 items in ScrollView — must use FlatList or SectionList.
5. Flag missing useCallback/useMemo on callbacks passed to native components.
6. Flag memory leaks: event listeners, subscriptions, or timers not cleaned up on unmount.
7. Flag OTA update (CodePush) missing staged rollout or rollback config.
8. Flag Platform.OS checks mixed into business logic — isolate to platform-specific files.
9. Flag deep link URL params used in navigation or API calls without sanitisation.
10. Flag unpredictable navigation back-stack mutations.

Check: JS thread blocking, bridge batching, FlatList usage, memoization, memory leaks, OTA safety, platform isolation, deep link security, navigation back-stack.

Order findings P0–P3 with file:line references.
