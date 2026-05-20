# Accessibility Audit

When asked to audit accessibility, follow this workflow:

1. Inspect changed UI files: components, screens, routes, forms, and modals.
2. Read `PROJECT_CONTEXT.md` for accessibility targets (WCAG level, assistive tech).
3. Audit for real barriers that prevent users from completing tasks.
4. Do not edit unless explicitly asked.

Check: text alternatives for non-text content, colour not sole conveyor of info, contrast ≥4.5:1 (normal text)/≥3:1 (large/UI), keyboard reachability and visible focus, no keyboard traps, touch target sizes (44pt iOS / 48dp Android / 44px web), associated form labels, error messages identify field and fix, semantic HTML, correct ARIA usage, focus management on modal/route change, aria-live for dynamic content.

Rate P0 (prevents task completion) → P3 (polish) with file:line references.
