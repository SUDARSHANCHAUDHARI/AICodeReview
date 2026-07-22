# AICodeReview

Portable code-review workflows for multiple AI coding agents.

AICodeReview keeps every workflow in one canonical `SKILL.md`. Native agents receive that directory directly. Cursor rules, a compact Aider catalog, and OpenAI product metadata are generated from the same source.

## Skills

| Skill | What it does |
|---|---|
| `code-review` | Review changes for bugs, regressions, security, performance, and missing tests |
| `security-audit` | Audit injection, auth, secrets, data exposure, configuration, and dependencies |
| `codebase-explainer` | Explain architecture and data flow from repository evidence |
| `review-fixer` | Apply concrete, low-risk fixes from review findings |
| `android-review` | Review Android, Kotlin, KMP, and Compose code |
| `ios-review` | Review iOS, macOS, Swift, SwiftUI, and Xcode code |
| `web-review` | Review React, Next.js, TypeScript, and Node code |
| `release-review` | Check release blockers, privacy, build configuration, and rollout risk |
| `pr-summary` | Write pull request descriptions from local changes |
| `context-writer` | Create or refresh `PROJECT_CONTEXT.md` |
| `changelog-writer` | Generate changelog entries from Git history |
| `dependency-audit` | Check outdated, vulnerable, or risky dependencies |
| `agent-config-review` | Review AI-agent configuration for secrets and inconsistencies |
| `backend-review` | Review APIs, databases, auth, errors, and service layers |
| `performance-review` | Review latency, memory, N+1 queries, caching, and rendering |
| `accessibility-audit` | Audit semantics, keyboard navigation, ARIA, contrast, and mobile accessibility |
| `database-review` | Review schema design, indexes, migrations, and data integrity |
| `test-writer` | Write tests matching the existing repository style |
| `kmp-review` | Review Kotlin Multiplatform boundaries and expect/actual use |
| `docker-review` | Review Dockerfiles and Compose configuration |
| `ci-review` | Review CI/CD pipelines, secrets, caching, and test gates |
| `api-design-review` | Review API naming, versioning, auth, errors, idempotency, and pagination |
| `flutter-review` | Review Flutter and Dart lifecycle, rendering, and release setup |
| `refactor-planner` | Plan safe incremental refactors |
| `architecture-review` | Review dependency direction, coupling, cohesion, and layer violations |
| `code-smell-detector` | Find god classes, long methods, duplication, dead code, and magic values |
| `error-handling-review` | Find silent catches, missing error states, and unsafe retries |
| `graphql-review` | Review schemas, N+1 problems, field authorization, and limits |
| `react-native-review` | Review bridge calls, list performance, leaks, updates, and deep links |
| `tech-debt-audit` | Prioritize TODOs, deprecated APIs, untested paths, and dead flags |
| `onboarding-writer` | Generate `ONBOARDING.md` from repository inspection |

The CLI discovers skill directories dynamically. Adding a skill does not require editing a hard-coded list.

## Agent support

| Agent | Adapter | Install target | Behavior |
|---|---|---|---|
| Claude Code | Native Agent Skill | `~/.claude/skills/` | Loaded on demand from `SKILL.md` |
| OpenAI Codex | Native Agent Skill | `~/.codex/skills/` | Loaded on demand from `SKILL.md` |
| GitHub Copilot | Native Agent Skill | `<project>/.github/skills/` | Discovered and activated when relevant |
| Gemini CLI | Native Agent Skill | `<project>/.gemini/skills/` | Activated through the native skill system |
| OpenCode | Native Agent Skill | `<project>/.opencode/skills/` | Loaded on demand through the native skill tool |
| Cursor | Generated project rule | `<project>/.cursor/rules/` | Generated from `SKILL.md` during installation |
| Aider | Catalog plus selective skills | `<project>/AICODEREVIEW.md` and `<project>/.aicodereview/skills/` | Catalog is loaded normally; workflows are loaded individually with `/read` |

Native skills are not copied into persistent Copilot or Gemini instructions. Aider does not preload all 31 workflow bodies into every session.

## Requirements

The published CLI requires **Node.js 18 or later**.

Bash and Python are not runtime requirements. The repository keeps legacy shell utilities only for backward-compatibility testing.

## Install

From npm:

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

## CLI

Install Claude Code and Codex:

```bash
aicodereview install
```

Install a project integration:

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

Preview without writing:

```bash
aicodereview install --agent all --project /path/to/project --dry-run
```

Update managed paths while backing up unmanaged conflicts:

```bash
aicodereview install --agent all --project /path/to/project --force
```

The old flag-only form remains supported:

```bash
aicodereview --agent claude
```

## Maintenance

List every discovered skill and installation state:

```bash
aicodereview list --project /path/to/project
```

Check drift, ownership, incomplete migrations, and corrupt markers:

```bash
aicodereview health --project /path/to/project
```

Refresh all detected managed integrations from the currently installed package:

```bash
aicodereview update --project /path/to/project
```

Update the CLI package itself through the package manager:

```bash
npm install -g aicodereview@latest
```

## Generate and validate

```bash
aicodereview validate
aicodereview generate --check
aicodereview generate --write
```

`SKILL.md` is the only workflow source. Validation rejects obsolete `cursor.mdc`, `copilot.md`, `gemini.md`, and `aider.md` copies inside skill directories.

## Installation safety

- Managed directories and generated files receive ownership markers.
- Unmanaged conflicts stop installation unless `--force` is supplied.
- `--force` moves unmanaged content to timestamped backups.
- File and marker replacement is transactional and restores previous content after a failed operation.
- Corrupt migration markers stop before replacement paths are written.
- `--agent all` preflights every global and project destination before the first write.
- Uninstall removes only ownership-marked content.

## Aider activation

The installer writes a compact `AICODEREVIEW.md` catalog and managed skill directories under `.aicodereview/skills/`.

Load one workflow:

```text
/read .aicodereview/skills/code-review/SKILL.md
```

Then ask Aider to use `code-review`.

## Use

```text
Use code-review to review my current changes.
Use security-audit on this pull request.
Use review-fixer to fix only safe and concrete findings.
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

## Uninstall

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

GitHub Actions runs the Node suite and package inspection on Ubuntu, macOS, and Windows. Legacy shell compatibility remains checked on Ubuntu and macOS.

## Design principles

- Inspect real files before making claims.
- Report correctness, security, performance, testing, and operational risks rather than taste.
- Include severity, evidence, file and line references, impact, and a concrete fix direction.
- Keep review workflows read-only unless the user explicitly requests changes.
- Preserve secrets, private data, and user-owned configuration.
- Describe skills, rules, conventions, plugins, and hooks as different capabilities.

## Roadmap

- **Phase 0:** Safe ownership, migration, native multi-agent support, and CI.
- **Phase 1:** Canonical workflows, standardized metadata, generated Cursor rules, and selective Aider loading.
- **Phase 2:** Complete cross-platform Node CLI, Windows coverage, health, update, and package validation.
- **Phase 3:** Optional lifecycle hooks and behavioral evaluation fixtures.

## Contributing

See `SKILL_GUIDE.md` and `CONTRIBUTING.md`.

## License

MIT
