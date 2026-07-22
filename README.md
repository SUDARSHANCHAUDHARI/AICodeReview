# AICodeReview

Portable code-review workflows for multiple AI coding agents.

Every workflow has one canonical `SKILL.md`. Native agents receive that directory directly. Cursor rules, a compact Aider catalog, and OpenAI metadata are generated from the same source.

## Included

AICodeReview contains 31 workflows covering general review, security, architecture, APIs, databases, CI, Docker, Android, iOS, web, Flutter, React Native, testing, performance, accessibility, release readiness, refactoring, technical debt, documentation, and onboarding.

The CLI discovers skill directories dynamically. Adding a skill does not require editing a hard-coded inventory.

## Agent support

| Agent | Adapter | Install target |
|---|---|---|
| Claude Code | Native Agent Skill | `~/.claude/skills/` |
| OpenAI Codex | Native Agent Skill | `~/.codex/skills/` |
| GitHub Copilot | Native Agent Skill | `<project>/.github/skills/` |
| Gemini CLI | Native Agent Skill | `<project>/.gemini/skills/` |
| OpenCode | Native Agent Skill | `<project>/.opencode/skills/` |
| Cursor | Generated rule | `<project>/.cursor/rules/` |
| Aider | Catalog plus selective skills | `<project>/AICODEREVIEW.md` and `.aicodereview/skills/` |

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

## Workflow installation

```bash
aicodereview install
aicodereview install --agent cursor   --project /path/to/project
aicodereview install --agent copilot  --project /path/to/project
aicodereview install --agent gemini   --project /path/to/project
aicodereview install --agent opencode --project /path/to/project
aicodereview install --agent aider    --project /path/to/project
aicodereview install --agent all      --project /path/to/project
```

Preview or safely replace managed paths:

```bash
aicodereview install --agent all --project /path/to/project --dry-run
aicodereview install --agent all --project /path/to/project --force
```

The old flag-only form remains supported:

```bash
aicodereview --agent claude
```

## Maintenance

```bash
aicodereview list   --project /path/to/project
aicodereview health --project /path/to/project
aicodereview update --project /path/to/project
```

`list` reports every discovered skill and installation state. `health` detects drift, unmanaged paths, incomplete migrations, and corrupt markers. `update` refreshes detected managed integrations from the installed package.

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

Hooks are optional deterministic automation. They do not call an AI provider, block the agent, or claim to perform a code review.

```bash
aicodereview hooks install   --agent copilot --project /path/to/project
aicodereview hooks install   --agent gemini  --project /path/to/project
aicodereview hooks install   --agent all     --project /path/to/project
aicodereview hooks status    --agent all     --project /path/to/project
aicodereview hooks uninstall --agent all     --project /path/to/project
```

Copilot receives `.github/hooks/aicodereview.json` and a Node runner. Gemini receives a local extension under `.aicodereview/gemini-extension/`; link it with the command printed by the installer.

The hooks record branch, Git status, and `git diff --check` at session start and after the main agent turn. In a Git repository, reports are stored under the repository's Git metadata directory so they cannot be committed accidentally. A non-Git fallback uses the ignored `.aicodereview/reports/` path.

Hooks are provided only for Copilot and Gemini because those integrations have documented compatible lifecycle-hook formats.

## Behavioral evaluations

Installation success does not prove review quality. The `evals/` directory contains two seeded defects and one false-positive control.

```bash
aicodereview eval --list
aicodereview eval --validate
aicodereview eval --results results.json
```

The scorer reports true positives, false positives, false negatives, precision, recall, and severity accuracy. See `evals/README.md` for the result format and fair-comparison rules.

Publish behavioral support claims only when reproducible results support them.

## Safety guarantees

- Managed directories and generated files receive ownership markers.
- Unmanaged conflicts stop installation unless `--force` is supplied.
- Forced replacement moves unmanaged content to timestamped backups.
- Directory, file, and marker replacement is transactional and rolls back after failure.
- Corrupt migration markers stop before replacement paths are written.
- `--agent all` preflights every destination before the first write.
- Uninstall removes only ownership-marked content.

## Aider activation

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

GitHub Actions is configured for Ubuntu, macOS, and Windows. Repository-only shell compatibility remains checked on Ubuntu and macOS.

## Contributing

See `SKILL_GUIDE.md`, `CONTRIBUTING.md`, and `evals/README.md`.

## License

MIT
