## Tech Debt Audit Convention

When asked to audit tech debt:

1. Search all source files for TODO, FIXME, HACK, XXX; read 5 lines of context around each.
2. Check dependency files for packages 2+ major versions behind, deprecated, or with known CVEs.
3. Scan for deprecated API usage (annotations, framework notices, deprecation comments).
4. Find untested critical paths: auth, payments, data migrations, core logic with no test coverage.
5. Flag hardcoded config: IPs, hostnames, staging URLs, credentials, feature flag literals.
6. Flag dead feature flags: always the same value everywhere they are evaluated.
7. Estimate blast radius per item: High (critical flow or 5+ dependents), Medium (2–4), Low (isolated).
8. Order findings P0–P3 with file:line, blast radius rating, and a one-line remediation note each.
