## Summary

<!-- One or two sentences describing what this PR does and why. -->

## Checklist

### Skill files (if adding or modifying a skill)

- [ ] Skill folder created under `skills/<skill-name>/`
- [ ] `skills/<skill-name>/SKILL.md` exists with valid frontmatter (`name`, `description`)
- [ ] `skills/<skill-name>/agents/openai.yaml` is present and non-empty
- [ ] `skills/<skill-name>/agents/cursor.mdc` is present with correct frontmatter
- [ ] `skills/<skill-name>/agents/copilot.md` is present and non-empty
- [ ] `skills/<skill-name>/agents/gemini.md` is present and non-empty
- [ ] `skills/<skill-name>/agents/aider.md` is present and non-empty

### Integration

- [ ] `install.sh` skills array includes the new skill name
- [ ] `uninstall.sh` skills array includes the new skill name

### Validation

- [ ] `./scripts/validate.sh` passes with no failures

### Tests

- [ ] `./tests/run-all.sh` passes with no failures

### Documentation

- [ ] `README.md` updated if the skill list or usage instructions changed
- [ ] `AGENTS.md` updated if agent support matrix changed
- [ ] `CHANGELOG.md` entry added under `## Unreleased`

### General

- [ ] No secrets, tokens, API keys, or personal credentials in any committed file
- [ ] No planning docs or spec files committed (e.g. SPEC_*.md, PLAN_*.md)
