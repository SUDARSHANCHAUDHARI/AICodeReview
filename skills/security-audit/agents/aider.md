## Security Audit Convention

When asked to audit security:

1. Trace data from entry points to sinks.
2. Check for injection, auth/authz gaps, hardcoded secrets, sensitive data exposure, weak crypto, missing validation, unsafe config, risky dependencies.
3. Rate findings CRITICAL / HIGH / MEDIUM / LOW.
4. Do not edit files unless explicitly asked to fix findings.
5. Never commit secrets, signing files, or tokens.
