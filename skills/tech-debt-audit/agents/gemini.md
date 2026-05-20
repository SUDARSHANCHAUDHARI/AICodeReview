# Tech Debt Audit

When asked to audit tech debt, follow this workflow:

1. Search all source files for TODO, FIXME, HACK, XXX markers; read 5 lines of context per marker.
2. Check all dependency files for stale packages (2+ major versions behind), deprecated packages, and known CVEs.
3. Scan for deprecated API usage: annotations, framework notices, or comments referencing deprecated replacements.
4. Identify untested critical paths: auth, payments, data migrations, core business logic with no test coverage.
5. Flag hardcoded config: IPs, hostnames, staging URLs, ports, credentials, environment-specific values in source.
6. Flag dead feature flags: always the same value everywhere evaluated with no toggle mechanism.
7. Estimate blast radius per item: High (critical flow or 5+ dependents), Medium (2–4), Low (isolated).
8. Output all findings ordered P0–P3 with file:line, blast radius, and a one-line remediation note.

Check: TODO/FIXME/HACK markers, stale dependencies, deprecated APIs, untested critical paths, hardcoded config, dead feature flags.

Order findings P0–P3 with file:line references.
