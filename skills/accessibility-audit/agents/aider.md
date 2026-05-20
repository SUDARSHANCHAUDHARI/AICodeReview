## Accessibility Audit Convention

When asked to audit accessibility:

1. Check text alternatives for all non-text content.
2. Check colour is not the sole means of conveying information.
3. Check contrast ≥4.5:1 normal text, ≥3:1 large text and UI components.
4. Check all interactive elements keyboard-reachable with visible focus indicator.
5. Check no keyboard traps; focus order is logical.
6. Check touch target sizes: ≥44×44pt (iOS), ≥48×48dp (Android), ≥44×44px (web).
7. Check form inputs have programmatically associated labels.
8. Check error messages identify the field and describe the fix.
9. Check semantic HTML and correct ARIA usage.
10. Check focus managed on modal/route change; dynamic content announced via aria-live.
11. Rate P0 (task blocker) → P3 (polish) with file:line references.
