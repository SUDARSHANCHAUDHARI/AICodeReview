---
name: codex-security-audit
description: Use when performing a focused security and privacy audit of code changes, pull requests, release candidates, API endpoints, authentication flows, storage, configuration, or dependencies.
---

# Codex Security Audit

## Workflow

1. Inspect repo state, changed files, and security-sensitive configuration.
2. Read `PROJECT_CONTEXT.md`, `AGENTS.md`, README, and relevant auth/storage/networking code when present.
3. Trace data from entry points to sinks: UI input, API handlers, CLI args, files, database writes, network calls, logs, and responses.
4. Report exploitable or realistic risks first. Avoid speculative noise.
5. Do not edit files unless the user asks for fixes.

## Threat Model

Check for:

- Injection: SQL, command, template, path traversal, SSRF, unsafe deserialization.
- Auth/authz: missing authentication, missing ownership checks, IDOR, weak token/session validation.
- Secrets: hardcoded keys, tokens, passwords, private signing files, unsafe `.env` handling.
- Sensitive data: logs, analytics, crash reports, responses, backups, local storage.
- Crypto: weak algorithms, predictable randomness, insecure token generation.
- Input validation: missing length/type checks, unsafe file uploads, ReDoS, missing rate limits.
- Config: debug mode, permissive CORS, missing security headers, unsafe network security config.
- Dependencies: known risky libraries or obviously outdated security-sensitive dependencies.

## Android/Kotlin Checks

- No secrets in resources, BuildConfig, manifests, Gradle files, or committed properties.
- No signing config or keystore material committed.
- Exported components have clear intent filters and permission expectations.
- WebView settings do not enable unnecessary JavaScript/file access.
- Network security config does not allow cleartext traffic accidentally.
- Local storage does not keep sensitive data unencrypted when encryption is expected.
- Logs do not expose tokens, emails, private repository paths, or PII.

## Output

```markdown
## Security Findings

**[CRITICAL]** `path/to/file.ext:123` - Vulnerability type: short title
Attack scenario, impact, and concrete fix.

**[HIGH]** `path/to/file.ext:45` - Short title
...

**[MEDIUM]** `path/to/file.ext:67` - Short title
...

## Positive Notes

- ...

## Verdict

SECURE / REVIEW NEEDED / DO NOT MERGE
```

If no vulnerabilities are found, state that clearly and mention what was not verified.
