## Dependency Audit Convention

When asked to audit dependencies:

1. Identify package manager and manifests (package.json, build.gradle.kts, Podfile, etc.).
2. Check for outdated direct deps — security-sensitive libs first.
3. Check for known CVEs via the appropriate tool (npm audit, cargo audit, pip-audit, etc.).
4. Flag abandoned packages: no commits in 2+ years, many open issues.
5. Flag licence incompatibilities: GPL/AGPL in proprietary apps, no-licence packages.
6. Check dev deps not leaking into production bundles.
7. Rate findings CRITICAL/HIGH/MEDIUM/LOW. Do not upgrade or edit unless explicitly asked.
