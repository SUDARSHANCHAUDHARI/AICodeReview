---
name: accessibility-audit
description: Use when auditing UI code for accessibility: WCAG 2.2 compliance, keyboard navigation, screen reader support, focus management, colour contrast, and ARIA usage.
---

# Accessibility Audit

## Workflow

1. Inspect changed UI files: components, screens, routes, forms, and modals.
2. Read `PROJECT_CONTEXT.md` and `AGENTS.md` when present for accessibility targets (WCAG level, assistive tech expectations).
3. Audit for the issues below. Focus on real barriers that prevent users from completing tasks.
4. Do not edit files unless explicitly asked.

## Checklist

### Perceivable
- All non-text content (images, icons, charts) has an equivalent text alternative (`alt`, `accessibilityLabel`, `contentDescription`).
- Decorative images are hidden from assistive tech (`alt=""`, `importantForAccessibility="no"`).
- Colour is not the only means of conveying information (e.g. error state shown with text + colour, not colour alone).
- Colour contrast ratio meets WCAG AA (4.5:1 for normal text, 3:1 for large text and UI components).
- Text can be resized to 200% without loss of content or functionality.
- Captions or transcripts provided for audio/video content.

### Operable
- All interactive elements are reachable and operable via keyboard alone.
- Focus order is logical — follows visual reading order.
- No keyboard traps: user can navigate into and out of all components.
- Focus is visible: not hidden or overridden with `outline: none` without a replacement.
- Touch targets meet minimum size: 44×44pt (iOS), 48×48dp (Android), 44×44px (Web).
- No interaction requires a precise gesture, path, or multi-finger input without an alternative.
- Sufficient time provided for timed interactions; user can pause, stop, or extend.

### Understandable
- Form inputs have visible, programmatically associated labels (not just placeholder text).
- Error messages identify the field in error and describe how to fix it.
- Consistent navigation and labelling across pages/screens.
- Language of page and language changes in content are marked up.

### Robust
- Semantic HTML used where possible (`<button>` not `<div onClick>`, `<nav>`, `<main>`, `<h1>`–`<h6>` hierarchy).
- ARIA used only when native semantics are insufficient; no redundant or conflicting ARIA.
- `role`, `aria-label`, `aria-describedby`, `aria-expanded`, `aria-live` are used correctly.
- Android: `TalkBack` order and grouping correct, `traversalBefore`/`After` used where needed.
- iOS: VoiceOver rotor and custom actions considered for complex interactions.

### Focus Management
- Modal/dialog: focus moves into modal on open, returns to trigger on close.
- Route changes: focus moves to page heading or top of new content.
- Dynamic content: newly injected content announced to screen readers (`aria-live`, `announceForAccessibility`).

## Output

```markdown
## Accessibility Findings

**[P0]** `path/to/Component.tsx:34` - Icon button has no accessible label
Screen reader announces "button" with no context. Add `aria-label` or `accessibilityLabel`.

**[P1]** `path/to/Form.tsx:88` - Error message not associated with input
`aria-describedby` is missing. Screen reader users cannot hear the error for the field.

**[P2]** `path/to/Card.tsx:12` - Colour contrast 3.1:1 (fails AA)
Text on this background needs 4.5:1. Darken foreground or lighten background.

## Summary

WCAG level assessed, barriers found, and recommended priority order.
```
