## Summary

<!-- Describe what changed and why. -->

## Checklist

### Skill files

- [ ] `skills/<skill-name>/SKILL.md` is the canonical workflow
- [ ] `SKILL.md` frontmatter has a matching `name` and specific `description`
- [ ] Required files under `skills/<skill-name>/agents/` are present
- [ ] The workflow reports evidence-based findings rather than style preferences
- [ ] Review or audit behavior remains read-only unless explicitly requested

### Integration safety

- [ ] No hard-coded skill inventory was added
- [ ] User-owned files and configuration are preserved
- [ ] New generated paths have ownership markers
- [ ] `--force` backs up unmanaged conflicts
- [ ] Migration validates markers before changing native paths
- [ ] Aider changes do not create a duplicate `read` key

### Validation and tests

- [ ] `./scripts/validate.sh` passes with no failures
- [ ] `./tests/run-all.sh` passes with no failures
- [ ] Installer changes include behavioral install and uninstall coverage
- [ ] Migration changes include user-content preservation and corrupt-marker tests

### Documentation

- [ ] `README.md` reflects any public behavior or support change
- [ ] `AGENTS.md` reflects any architecture change
- [ ] `SKILL_GUIDE.md` reflects any contributor workflow change
- [ ] `CHANGELOG.md` has an entry under `Unreleased`

### General

- [ ] No secrets, tokens, API keys, signing files, or private customer data are committed
- [ ] No unrelated planning or generated scratch files are committed
