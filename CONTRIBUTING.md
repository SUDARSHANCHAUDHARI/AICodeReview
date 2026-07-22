# Contributing

Thanks for improving AICodeReview.

## Safety

- Never commit secrets, signing material, API tokens, private customer data, or `.env` values.
- Preserve user-owned files and configuration.
- Back up unmanaged conflicts before replacement.
- Preflight every destination before a multi-agent operation writes.
- Do not publish, rename the repository, or change visibility without explicit approval.

## Development setup

```bash
npm install
npm test
npm run validate
npm run pack:check
```

## Skills

`skills/<skill-name>/SKILL.md` is the only workflow source.

Every skill needs YAML frontmatter:

```markdown
---
name: skill-name
description: Use when this specific workflow is required.
---
```

Add a skill by creating `SKILL.md`, running `aicodereview generate --write`, and updating public documentation when the inventory changes. Skills are discovered dynamically. Do not add installer arrays.

Do not create per-skill `cursor.mdc`, `copilot.md`, `gemini.md`, or `aider.md` copies. Cursor rules and the Aider catalog are generated from canonical skills.

## CLI changes

- Implement published behavior in TypeScript.
- Keep the npm entrypoint free of Bash or Python delegation.
- Keep replacements transactional and rollback-safe.
- Add Node tests with temporary projects and isolated global agent homes.
- Cover Windows paths, unmanaged backups, corrupt markers, all-agent preflight, update detection, and ownership-aware uninstall.
- Do not edit `dist/` manually.

## Hooks

- Add hooks only for agents with documented hook formats.
- Hooks must be optional and non-destructive by default.
- Hook stdout must contain only valid protocol JSON. Write diagnostics to stderr.
- Never call an external AI provider from a lifecycle hook without explicit user configuration.
- Never describe deterministic Git checks as an AI code review.
- Add install, status, uninstall, conflict-backup, and cross-platform tests.
- Keep generated local reports out of Git.

## Evaluations

- Use fake or synthetic data only.
- Add expected finding IDs and severities to `evals/manifest.json`.
- Add a false-positive control for each new evaluation category.
- Keep fixtures small enough for agents to inspect completely.
- Use the same prompt and fixture state when comparing agents.
- Do not publish behavioral claims without reproducible result files.
- Update `evals/README.md` when the result schema or scoring changes.

## Integration claims

Confirm whether an agent supports native skills, rules, conventions, extensions, persistent instructions, or hooks. Implement only the supported capability and describe it accurately.

## Review quality

- Inspect relevant files before making claims.
- Focus on correctness, security, performance, testing, and operational risk.
- Include evidence, file and line references, impact, and a concrete fix direction.
- Avoid style-only findings.
- Keep review and audit workflows read-only unless the user explicitly requests changes.

## Before sharing

```bash
npm test
npm run validate
npm run pack:check
```

Also test unmanaged conflicts, corrupt legacy markers, selective Aider paths, hook install and removal, evaluation validation, and existing user configuration.
