---
name: dependency-audit
description: Use when checking dependencies for outdated versions, known vulnerabilities, abandoned packages, licence risks, or bloated transitive deps.
---

# Dependency Audit

## Workflow

1. Identify the package manager and manifest files (`package.json`, `build.gradle.kts`, `Podfile`, `Package.swift`, `requirements.txt`, `Cargo.toml`, `go.mod`, etc.).
2. Read `PROJECT_CONTEXT.md` when present for known risk areas or active migrations.
3. Check for issues in the categories below.
4. Do not upgrade dependencies or edit files unless explicitly asked.

## What To Check

### Outdated
- Direct dependencies with newer stable versions available.
- Focus on security-sensitive libraries first: auth, crypto, networking, serialization, parsers.
- Flag major version gaps separately from minor/patch gaps.

### Vulnerabilities
- Known CVEs in direct or transitive dependencies.
- Check against advisories: npm audit, Gradle dependency check, `pip-audit`, `cargo audit`, GitHub Dependabot alerts if visible.
- Rate by severity: CRITICAL, HIGH, MEDIUM, LOW.

### Abandoned / Risky
- Packages with no commits in 2+ years and many open issues.
- Packages with a single maintainer and no recent activity.
- Packages that were recently transferred to an unknown owner.
- Packages with an unusual spike in download count (possible supply chain attack indicator).

### Licence
- Licences incompatible with the project's own licence or commercial use (GPL in a proprietary app, AGPL, SSPL).
- Packages with no clear licence.

### Bloat
- Transitive dependencies pulling in unexpectedly large or risky sub-trees.
- Dev dependencies accidentally bundled into production builds.

## Android/Kotlin Specifics

- Check for Gradle plugin and AGP version compatibility.
- Flag deprecated APIs that will break on the next major SDK/AGP version.
- Check that `implementation` vs `api` scoping is correct — leaking transitive deps via `api` unnecessarily.

## Output

```markdown
## Dependency Audit Findings

**[CRITICAL]** `package-name@version` - CVE-XXXX-YYYY
Impact and recommended upgrade.

**[HIGH]** `package-name@version` - Outdated: current 1.2.3, latest 3.0.0
Breaking changes to review before upgrading.

**[MEDIUM]** `package-name` - Abandoned
Last commit 3 years ago, 200+ open issues, no maintainer response.

**[LOW]** `package-name` - Licence risk
GPL-3.0 may conflict with commercial distribution.

## Summary

Total deps audited, highest severity, recommended next steps.
```
