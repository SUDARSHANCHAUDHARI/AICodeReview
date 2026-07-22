# AICodeReview

Portable code-review workflows for multiple AI coding agents.

AICodeReview keeps every workflow in one canonical `SKILL.md`. Native agents receive that directory directly. Cursor rules, a compact Aider catalog, and OpenAI metadata are generated from the same source.

## What is included

The repository contains 31 workflows covering general review, security, architecture, APIs, databases, CI, Docker, Android, iOS, web, Flutter, React Native, testing, performance, accessibility, release readiness, refactoring, technical debt, documentation, and onboarding.

The CLI discovers skill directories dynamically. Adding a skill does not require editing a hard-coded inventory.

## Agent support

| Agent | Adapter | Install target | Behavior |
|---|---|---|---|
| Claude Code | Native Agent Skill | `~/.claude/skills/` | Loaded on demand from `SKILL.md` |
| OpenAI Codex | Native Agent Skill | `~/.codex/skills/` | Loaded on demand from `SKILL.md` |
| GitHub Copilot | Native Agent Skill | `<project>/.github/skills/` | Discovered when relevant |
| Gemini CLI | Native Agent Skill | `<project>/.gemini/skills/` | Activated through the native skill system |
| OpenCode | Native Agent Skill | `<project>/.opencode/skills/` | Loaded through the native skill tool |
| Cursor | Generated rule | `<project>/.cursor/rules/` | Generated from `SKILL.md` |
| Aider | Catalog plus selective skills | `<project>/AICODEREVIEW.md` and `.aicodereview/skills/` | Workflows are loaded individually with `/read` |

Skills, rules, conventions, extensions, and hooks are different capabilities. The repository does not describe them as equivalent.

## Requirements

The published CLI requires Node.js 18 or later. Bash and Python are not runtime requirements.

## Install

```bash
npm install -g aicodereview
```

From the repository:

```bash
git clone https://github.com/SUDARSHANCHAUDHARI/AICodeReview.git
cd AICodeReview
npm install
npm run build
```

## Install workflows

Install Claude Code and Codex:

```bash
aicodereview install
```

Install project integrations:

```bash
aicodereview install --agent cursor   --project /path/to/project
aicodereview install --agent copilot  --project /path/to/project
aicodereview install --agent gemini   --project /path/to/project
aicodereview install --agent opencode --project /path/to/project
aicodereview install --agent aider    --project /path/to/project
```

Install everything:

```bash
aicodereview install --agent all --project /path/to/project
```

Preview or update safely:

```bash
aicodereview install --agent all --project /path/to/project --dry-run
aicodereview install --agent all --project /path/to/project --force
```

The flag-only form remains supported:

```bash
aicodereview --agent claude
```

## Maintenance

```bash
aicodereview list --project /path/to/project
aicodereview health --project /path/to/project
aicodereview update --project /path/to/project
```

`list` reports every discovered skill and installation state. `health` detects drift, unmanaged paths, incomplete migration, and corrupt markers. `update` refreshes detected managed integrations from the currently installed package.

Update the CLI itself through npm:

```bash
npm install -g aicodereview@latest
```

## Generate and validate

```bash
aicodereview validate
aicodereview generate --check
aicodereview generate --write
```

`SKILL.md` is the only workflow source. Validation rejects obsolete per-agent prompt copies.

## Optional lifecycle hooks

Hooks are optional. They record deterministic repository state; they do not run an AI review or block the agent.

Install repository hooks for supported hook systems:

```bash
aicodereview hooks install --agent copilot --project /path/to/project
aicodereview hooks install --agent gemini  --project /path/to/project
aicodereview hooks install --agent all     --project /path/to/project
```

Check or remove them:

```bash
aicodereview hooks status    --agent all --project /path/to/project
aicodereview hooks uninstall --agent all --project /path/to/project
```

Copilot receives `.github/hooks/aicodereview.json` and a cross-platform Node runner. Gemini receives a local extension under `.aicodereview/gemini-extension/`; link it with the command printed by the installer.

The hooks run at session start and after the main agent turn. They write local reports under `.aicodereview/reports/`, including Git status and `git diff --check`. Reports are ignored by Git.

Hooks are currently provided only for Copilot and Gemini because these integrations have documented lifecycle-hook formats. Other agents still receive their supported skill or rule format without invented hook compatibility.

## Behavioral evaluations

Installation success does not prove review quality. The `evals/` directory provides seeded defects and a false-positive control.

```bash
aicodereview eval --list
aicodereview eval --validate
aicodereview eval --results results.json
```

The scorer reports true positives, false positives, false negatives, precision, recall, and severity accuracy. See `evals/README.md` for the result format and fair-comparison rules.

The initial suite covers:

- hardcoded production-shaped secret detection
- missing object-level authorization
- a safe authorization implementation that should not produce either finding

Publish behavioral support claims only when reproducible results support them.

## Installation safety

- Managed directories and generated files receive ownership markers.
- Unmanaged conflicts stop installation unless `--force` is supplied.
- Forced replacement moves unmanaged content to timestamped backups.
- Directory, file, and marker replacement is transactional and rolls back after failure.
- Corrupt migration markers stop before replacement paths are written.
- `--agent all` preflights every global and project destination before the first write.
- Uninstall removes only ownership-marked content.

## Aider activation

The installer writes a compact catalog and managed skill directories under `.aicodereview/skills/`.

```text
/read .aicodereview/skills/code-review/SKILL.md
```

Then ask Aider to use `code-review`.

## Example use

```text
Use code-review to review my current changes.
Use security-audit on this pull request.
Use release-review to check whether this build is ready to ship.
Use architecture-review to inspect dependency direction and layer violations.
Use test-writer to add tests grounded in the repository's current style.
```

For Gemini CLI, run `/skills reload` after adding or updating workspace skills.

## Project context

```bash
cp templates/PROJECT_CONTEXT.md /path/to/project/PROJECT_CONTEXT.md
```

Document the actual stack, architecture, verification commands, conventions, and migration constraints.

## Uninstall workflows

```bash
aicodereview uninstall --agent claude
aicodereview uninstall --agent aider --project /path/to/project
aicodereview uninstall --agent all --project /path/to/project
```

User-owned paths and configuration remain untouched.

## Test and package

```bash
npm test
npm run validate
npm run pack:check
```

GitHub Actions is configured to run the Node suite and package inspection on Ubuntu, macOS, and Windows. Repository-only shell compatibility remains checked on Ubuntu and macOS.

## Design principles

- Inspect real files before making claims.
- Report correctness, security, performance, testing, and operational risk rather than taste.
- Include severity, evidence, file and line references, impact, and a concrete fix direction.
- Keep review workflows read-only unless the user explicitly requests changes.
- Preserve secrets, private data, and user-owned configuration.
- Measure review behavior instead of treating assertion counts as quality evidence.

## Contributing

See `SKILL_GUIDE.md`, `CONTRIBUTING.md`, and `evals/README.md`.

## License

MIT
