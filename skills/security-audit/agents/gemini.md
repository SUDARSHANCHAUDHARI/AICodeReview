# Security Audit

When asked to audit security, follow this workflow:

1. Inspect changed files and security-sensitive configuration.
2. Read `PROJECT_CONTEXT.md`, `AGENTS.md`, and relevant auth/storage/networking code.
3. Trace data from entry points to sinks.
4. Report exploitable or realistic risks first. No speculative noise.
5. Do not edit files or push unless explicitly asked.

Check for: injection (SQL, command, path traversal), auth/authz gaps (IDOR, missing checks), hardcoded secrets, sensitive data in logs or storage, weak crypto, missing input validation, unsafe config, and risky dependencies.

Rate findings CRITICAL / HIGH / MEDIUM / LOW. Conclude with SECURE / REVIEW NEEDED / DO NOT MERGE.
