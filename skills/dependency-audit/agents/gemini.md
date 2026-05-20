# Dependency Audit

When asked to audit dependencies, follow this workflow:

1. Identify the package manager and manifest files (package.json, build.gradle.kts, Podfile, Package.swift, requirements.txt, Cargo.toml, go.mod).
2. Read `PROJECT_CONTEXT.md` for known risk areas or active migrations.
3. Check for:
   - Outdated direct dependencies — security-sensitive libs first, flag major version gaps separately.
   - Known CVEs via npm audit, Gradle dependency check, pip-audit, cargo audit.
   - Abandoned packages: no commits in 2+ years, many open issues, single maintainer.
   - Licence incompatibilities: GPL/AGPL/SSPL in proprietary apps, no-licence packages.
   - Dev dependencies accidentally in the production bundle.
4. Do not upgrade or edit files unless explicitly asked.

Rate findings CRITICAL / HIGH / MEDIUM / LOW with package name and version.
