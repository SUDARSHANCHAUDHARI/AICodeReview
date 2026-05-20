---
name: tech-debt-audit
description: Audit codebase for TODO/FIXME/HACK markers, deprecated APIs, untested critical paths, hardcoded config, stale dependencies, dead feature flags, and estimate blast radius per item.
---

# Tech Debt Audit

When asked to audit tech debt, follow this workflow:

1. Search all source files for TODO, FIXME, HACK, XXX, and NOSONAR markers. For each, read the surrounding context (at minimum 5 lines before and after) to assess severity and intent.
2. Check all dependency files (package.json, build.gradle, requirements.txt, Cargo.toml, go.mod, pubspec.yaml) for:
   - Dependencies pinned to versions that are more than 2 major versions behind the current stable release.
   - Dependencies marked as deprecated or with published end-of-life dates.
   - Dependencies with known security advisories (note the advisory if visible in lockfile or comments).
3. Scan all source files for deprecated API usage: language-level deprecations (@Deprecated, deprecated(), DeprecationWarning), framework deprecations mentioned in comments or docs references.
4. Identify untested critical paths: find functions or modules that handle payments, authentication, data migrations, or core business logic, then check whether corresponding test files exist and cover the primary flow.
5. Find hardcoded configuration: IP addresses, hostnames, port numbers, environment-specific values (staging URLs, API endpoints), credentials, or feature flags hard-coded in source rather than read from config or environment.
6. Find dead feature flags: boolean flags or config values that are always the same value everywhere they are evaluated (always true or always false) with no active mechanism to change them.
7. For each debt item, estimate blast radius:
   - High: affects a critical user flow (auth, payment, data integrity), depended on by 5+ modules, or would require migration across the entire codebase to fix.
   - Medium: affects a secondary flow or 2–4 modules.
   - Low: isolated to one file or a non-critical path.
8. Order all findings P0–P3:
   - P0: hardcoded credential, deprecated security API in use, untested auth or payment flow, FIXME on live data migration path
   - P1: TODO in critical business logic, stale dependency with known CVE, dead feature flag controlling a visible feature
   - P2: HACK comment on shared utility, deprecated API with available replacement, hardcoded staging URL in production code
   - P3: low-impact TODO, outdated but functioning dependency, cosmetic FIXME
9. Output each finding with: severity, debt type, file:line, blast radius (High/Medium/Low), and one-sentence remediation note.

Output: Prioritized debt list P0–P3 with file:line references, blast radius, and remediation notes.

Rules:
- Read surrounding context for every TODO/FIXME before assigning severity.
- Do not flag commented-out TODO items that are clearly resolved (marked "done", "fixed", or dated in the past with no open issue).
- Dependency staleness check requires reading the actual dependency file — do not guess version numbers.
- Dead feature flags must be confirmed always-same-value by reading all evaluation sites — do not flag active flags.
