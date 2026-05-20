## CI Review Convention

When asked to review CI/CD configuration:

1. Check secrets via `${{ secrets.NAME }}` — never hardcoded or echoed to logs.
2. Check `pull_request_target` not used with checkout+run of untrusted fork code.
3. Check top-level `permissions: contents: read` or more restrictive.
4. Check jobs override permissions only for what they need.
5. Check third-party actions pinned to full commit SHA.
6. Check `concurrency` set for PR workflows.
7. Check cache keys include lockfile hash.
8. Check deploy steps only on correct branch with production approval gate.
9. Check production secrets distinct from staging.
10. Rate findings P0–P3 with file:line references.
