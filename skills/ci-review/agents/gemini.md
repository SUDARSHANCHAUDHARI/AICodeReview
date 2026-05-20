# CI Review

When asked to review CI/CD pipeline configuration, follow this workflow:

1. Inspect .github/workflows/, Jenkinsfile, .gitlab-ci.yml, bitrise.yml, or equivalent.
2. Read `PROJECT_CONTEXT.md` for deployment context and branch strategy.
3. Review for secret safety, permission hygiene, supply chain risk, and pipeline correctness.
4. Do not edit unless explicitly asked.

Check: secrets via ${{ secrets.NAME }} never echoed, `pull_request_target` not used dangerously, top-level permissions restrictive, jobs override only what they need, third-party actions pinned to SHA, `concurrency` set for PR workflows, cache keys include lockfile hash, deploy steps on correct branch with approval gate, production secrets distinct from staging, artefacts have retention policies.

Rate findings P0–P3 with file:line references.
