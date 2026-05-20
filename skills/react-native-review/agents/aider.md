## React Native Review Convention

When asked to review React Native code:

1. Read all source files (JS/TS, native modules).
2. Flag JS thread blocking: heavy synchronous computation not moved to a worker or native module.
3. Flag bridge calls in tight loops or rapid handlers not batched.
4. Flag lists of 20+ items using ScrollView instead of FlatList or SectionList.
5. Flag missing useCallback/useMemo on callbacks passed to native components.
6. Flag memory leaks: subscriptions, event listeners, or timers not cleaned up on unmount.
7. Flag OTA (CodePush) without staged rollout or rollback configuration.
8. Flag Platform.OS checks inline with business logic — should be in platform-specific files.
9. Flag deep link URL params used in navigation or API calls without sanitisation.
10. Flag unpredictable navigation back-stack patterns.
11. Output P0–P3 findings with file:line and a one-line fix per finding.
