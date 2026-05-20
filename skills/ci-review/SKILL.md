---
name: ci-review
description: Use when reviewing CI/CD pipeline configuration: GitHub Actions workflows, permissions, secret handling, action pinning, build matrices, or deployment safety.
---

# CI Review

## Workflow

1. Inspect `.github/workflows/`, `Makefile`, CI config files (`Jenkinsfile`, `.gitlab-ci.yml`, `bitrise.yml`, etc.).
2. Read `PROJECT_CONTEXT.md` and `AGENTS.md` for deployment context and branch strategy.
3. Review for secret safety, permission hygiene, supply chain risk, and pipeline correctness.
4. Do not edit files unless explicitly asked.

## Checklist

### Secret Safety
- Secrets accessed via `${{ secrets.NAME }}` — never hardcoded or echoed in logs.
- No `run: echo $SECRET` or similar commands that print secrets to stdout.
- Secrets not passed as environment variables to steps that don't need them.
- Pull request workflows do not have access to repository secrets by default (correct — verify this is not broken by `pull_request_target`).
- `pull_request_target` used carefully — it runs in the context of the base branch and has secret access even from forks. Avoid checking out and running untrusted code in this context.

### Permission Hygiene
- Top-level `permissions` set to `contents: read` or more restrictive as a default.
- Individual jobs override permissions only for what they actually need (`id-token: write` for OIDC, `pull-requests: write` for PR comments).
- `GITHUB_TOKEN` minimum permissions used — no `write-all` unless genuinely required.

### Action Pinning (Supply Chain)
- Third-party actions pinned to a full commit SHA, not a mutable tag (`uses: actions/checkout@v4` is a mutable tag; pin to SHA for security-critical workflows).
- First-party GitHub actions (`actions/*`) can use version tags.
- Unpinned actions from unknown publishers flagged as high risk.

### Trigger Safety
- Workflow triggers (`on:`) are appropriate — no `on: push` to main without a reason.
- `workflow_dispatch` available for manual runs on critical workflows.
- `schedule` triggers use UTC and have appropriate cadence.
- `concurrency` set to cancel in-progress runs for PR workflows to avoid queue buildup.

### Build Correctness
- Build matrix covers all supported versions/platforms without redundancy.
- Cache keys are correct and include lockfile hash (not just branch name).
- Failing fast (`fail-fast: true`) is appropriate for the matrix — set to `false` when all matrix results are needed.
- Artefacts uploaded with retention policies.
- Deploy steps only run on the correct branch (main/production), not on every PR.

### Deployment Safety
- Deploy steps have an approval gate for production environments.
- Rollback procedure exists or is documented.
- Environment variables and secrets for production are distinct from staging.

## Output

```markdown
## CI Review Findings

**[P0]** `.github/workflows/deploy.yml:34` - pull_request_target with checkout of untrusted code
Forks can run arbitrary code with access to repository secrets.

**[P1]** `.github/workflows/ci.yml:12` - Third-party action not pinned to SHA
`uses: some-org/some-action@v2` can be changed silently. Pin to commit SHA.

## Summary

Security verdict and pipeline correctness summary.
```
