# Contributing

Thanks for improving AICodeReview.

## Local Safety

- Do not commit secrets, `.env` values, signing keys, keystores, API tokens, or private customer data.
- Keep project-specific private context in your own repos, not in reusable skills.
- Test installer changes locally with `./install.sh --dry-run`.
- Do not publish, push, rename, or change repo visibility unless that is the explicit task.

## Editing Skills

Skills live in `skills/<skill-name>/SKILL.md`. Each skill also has agent-specific configs in `skills/<skill-name>/agents/`.

Each `SKILL.md` needs YAML frontmatter:

```markdown
---
name: skill-name
description: Use when ...
---
```

Keep descriptions clear — AI agents use them to decide when a skill applies.

## Adding A Skill

1. Create `skills/<skill-name>/SKILL.md`.
2. Add all five agent configs:
   - `skills/<skill-name>/agents/openai.yaml`
   - `skills/<skill-name>/agents/cursor.mdc`
   - `skills/<skill-name>/agents/copilot.md`
   - `skills/<skill-name>/agents/gemini.md`
   - `skills/<skill-name>/agents/aider.md`
3. Add the skill name to the `skills` array in `install.sh` and `uninstall.sh`.
4. Run `./scripts/validate.sh`.

## Adding An Agent

1. Add the agent config file to every skill under `skills/*/agents/<agent-name>.<ext>`.
2. Update `install.sh` to handle the new `--agent` value.
3. Update `uninstall.sh` to handle removal.
4. Update `validate.sh` to check the new file exists in every skill.
5. Update README, USAGE.md, and CUSTOMISING.md.

## Prompt Quality

- Prefer concrete workflows over vague advice.
- Tell the AI what to inspect before acting.
- Include output format expectations.
- Keep reusable skills free of personal or private repo details.
- Put repo-specific conventions in `PROJECT_CONTEXT.md`.

## Before Sharing

```bash
./install.sh --dry-run
./scripts/validate.sh
```
