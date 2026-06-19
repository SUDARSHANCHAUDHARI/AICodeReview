# Contributing

Thanks for improving AICodeReview.

## Local Safety

- Do not commit secrets, `.env` values, signing keys, keystores, API tokens, or private customer data.
- Keep project-specific private context in your own repos, not in reusable skills.
- Test installer changes locally with `./install.sh --dry-run`.
- Do not publish, push, rename, or change repo visibility unless that is the explicit task.

## Editing Skills

Skills live in `skills/<skill-name>/SKILL.md`.

Each skill needs YAML frontmatter:

```markdown
---
name: skill-name
description: Use when ...
---
```

Keep descriptions clear because Codex uses them to decide when a skill applies.

## Adding A Skill

1. Create `skills/<skill-name>/SKILL.md`.
2. Add `skills/<skill-name>/agents/openai.yaml`.
3. Add the skill name to `install.sh`.
4. Add the skill name to `uninstall.sh`.
5. Run `./scripts/validate.sh`.

## Prompt Quality

- Prefer concrete workflows over vague advice.
- Tell Codex what to inspect before acting.
- Include output expectations.
- Keep reusable skills free of personal or private repo details.
- Put repo-specific conventions in `PROJECT_CONTEXT.md`.

## Before Sharing

Run:

```bash
./install.sh --dry-run
./scripts/validate.sh
```
