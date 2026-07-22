# AICodeReview

Portable code-review workflows for multiple AI coding agents.

AICodeReview provides a canonical `SKILL.md` for each workflow and adapter files for agents that do not yet consume the same native format. The capability is not identical on every agent, so the support matrix below distinguishes native skills, project rules, and persistent instruction files.

## Skills

| Skill | What it does |
|---|---|
| `code-review` | Review changes for bugs, regressions, security, performance, and missing tests |
| `security-audit` | Threat-model-driven audit for injection, auth, secrets, data exposure, config, and dependencies |
| `codebase-explainer` | Explain architecture and data flow for onboarding or returning to a repository |
| `review-fixer` | Apply concrete, low-risk fixes from review findings |
| `android-review` | Android, Kotlin, KMP, and Compose-focused review |
| `ios-review` | iOS, macOS, Swift, SwiftUI, and Xcode-focused review |
| `web-review` | React, Next.js, TypeScript, and Node-focused review |
| `release-review` | Check release blockers, privacy, build configuration, and rollout risk |
| `pr-summary` | Write concise pull request descriptions from local changes |
| `context-writer` | Create or refresh `PROJECT_CONTEXT.md` from repository inspection |
| `changelog-writer` | Generate changelog entries from Git commits |
| `dependency-audit` | Check for outdated, vulnerable, or risky dependencies |
| `agent-config-review` | Review AI-agent configuration files for secrets, placeholders, and inconsistencies |
| `backend-review` | Review REST or GraphQL APIs, database access, auth, errors, and service layers |
| `performance-review` | Review latency, memory, N+1 queries, caching, and rendering bottlenecks |
| `accessibility-audit` | Audit semantics, keyboard navigation, ARIA, contrast, and mobile accessibility |
| `database-review` | Review schema design, indexes, migrations, query efficiency, and data integrity |
| `test-writer` | Write unit, integration, and snapshot tests matching the existing test style |
| `kmp-review` | Review Kotlin Multiplatform expect/actual use and shared/platform boundaries |
| `docker-review` | Review Dockerfiles and Compose configuration for layers, secrets, images, and health checks |
| `ci-review` | Review CI/CD pipelines, secrets, caching, test gates, and failure modes |
| `api-design-review` | Review API naming, versioning, auth, errors, idempotency, and pagination |
| `flutter-review` | Review Flutter and Dart lifecycle, rendering, state, platform channels, and release setup |
| `refactor-planner` | Plan safe incremental refactors with blast radius, rollback, and feature flags |
| `architecture-review` | Review dependency direction, circular dependencies, coupling, cohesion, and layer violations |
| `code-smell-detector` | Find god classes, long methods, feature envy, dead code, duplication, and magic values |
| `error-handling-review` | Find silent catches, missing UI error states, unsafe retries, and untyped errors |
| `graphql-review` | Review schemas, resolver N+1 problems, field-level auth, limits, and breaking changes |
| `react-native-review` | Review JS thread use, bridge calls, lists, leaks, updates, and deep-link security |
| `tech-debt-audit` | Find and prioritize TODOs, deprecated APIs, untested critical paths, and dead flags |
| `onboarding-writer` | Generate `ONBOARDING.md` from actual repository inspection |

The installer discovers skill directories dynamically. Adding a skill no longer requires updating separate hard-coded arrays in the maintenance scripts.

## Agent support

| Agent | Current adapter | Install target | Behavior |
|---|---|---|---|
| Claude Code | Native Agent Skill | `~/.claude/skills/` | Loaded on demand from `SKILL.md` |
| OpenAI Codex | Native Agent Skill | `~/.codex/skills/` | Loaded on demand from `SKILL.md` |
| Cursor | Agent-requested project rule | `<project>/.cursor/rules/` | Cursor decides when the `.mdc` rule is relevant, or the user invokes it |
| GitHub Copilot | Legacy combined instructions | `<project>/.github/copilot-instructions.md` | Persistent repository instructions; native Copilot skills are planned for Phase 0B |
| Gemini CLI | Legacy combined context | `<project>/GEMINI.md` | Loaded as persistent context; native Gemini skills are planned for Phase 0B |
| Aider | Conventions file | `<project>/CONVENTIONS.md` | Must be loaded with `/read` or configured in `.aider.conf.yml` |

The current adapters provide the same review intent, but they are not technically equivalent. Native skills use on-demand discovery. Rules and persistent context files follow the behavior of their host agent.

## Install

Clone the repository:

```bash
git clone https://github.com/SUDARSHANCHAUDHARI/AICodeReview.git
cd AICodeReview
```

Install Claude Code and Codex native skills:

```bash
./install.sh
```

Install one global agent:

```bash
./install.sh --agent claude
./install.sh --agent codex
```

Install a project-scoped adapter:

```bash
./install.sh --agent cursor  --project /path/to/project
./install.sh --agent copilot --project /path/to/project
./install.sh --agent gemini  --project /path/to/project
./install.sh --agent aider   --project /path/to/project
```

Install all current adapters:

```bash
./install.sh --agent all --project /path/to/project
```

Preview changes:

```bash
./install.sh --agent all --project /path/to/project --dry-run
```

Update an existing managed installation:

```bash
./install.sh --agent claude --force
```

### Installation safety

AICodeReview writes ownership markers beside native skills and Cursor rules.

When `--force` encounters a conflicting path that is not marked as AICodeReview-managed, it moves the existing content to a timestamped backup before installing. It does not silently delete the existing path.

Combined Copilot, Gemini, and Aider files are modified only when their AICodeReview start and end markers are absent or form exactly one valid pair. Corrupt or duplicate markers cause the operation to stop without changing the file.

## Aider activation

Creating `CONVENTIONS.md` does not automatically guarantee that Aider reads it. Load it in the session:

```text
/read CONVENTIONS.md
```

Or add it to the project’s `.aider.conf.yml`:

```yaml
read:
  - CONVENTIONS.md
```

## Use

Ask the agent to apply a workflow by name:

```text
Use code-review to review my current changes.
Use security-audit on this pull request.
Use review-fixer to fix only safe and concrete findings.
Use release-review to check whether this build is ready to ship.
Use architecture-review to inspect dependency direction and layer violations.
Use test-writer to add tests grounded in the repository's current test style.
```

Cursor rules are also available through Cursor’s rule picker. Copilot, Gemini, and Aider use their generated project instruction files.

## Per-project context

Copy the context template into the repository being reviewed:

```bash
cp templates/PROJECT_CONTEXT.md /path/to/project/PROJECT_CONTEXT.md
```

Document the project stack, architecture, conventions, verification commands, and known migration constraints. Skills read this file when present so findings remain grounded in the real repository.

Examples are available under `examples/`.

## Maintenance

```bash
./update.sh
./list-installed.sh
./list-installed.sh --project /path/to/project
./check-health.sh
./check-health.sh --project /path/to/project
```

`list-installed.sh` reports `installed`, `unmanaged`, or `missing` for every discovered skill.

`check-health.sh` verifies ownership markers, compares installed native skill files and Cursor rules with the source, and detects stale or corrupt combined sections.

## Uninstall

```bash
./uninstall.sh --agent claude
./uninstall.sh --agent all --project /path/to/project
```

Native skill directories and Cursor rules are removed only when an AICodeReview ownership marker is present. Unmanaged paths are left untouched.

## Validate and test

```bash
./scripts/validate.sh
./tests/run-all.sh
```

Validation checks skill naming and frontmatter, required adapter files, shell syntax, and use of the shared dynamic inventory. GitHub Actions runs validation and tests on Ubuntu and macOS.

## Design principles

- Inspect real files before making claims.
- Report production risks rather than personal style preferences.
- Rank findings by severity and include file and line references.
- Keep review workflows read-only unless the user explicitly requests changes.
- Prefer small, verifiable fixes over broad rewrites.
- Keep secrets, keys, signing files, private data, and `.env` values out of context files.
- Describe agent capability accurately instead of treating skills, rules, instructions, and hooks as interchangeable.

## Roadmap

Phase 0A strengthens inventory, installation ownership, uninstall safety, marker validation, documentation, and CI.

Phase 0B will replace the legacy Copilot and Gemini combined-context adapters with their native Agent Skills formats while preserving a migration path for existing installations.

Phase 1 will standardize skill metadata and generate non-native adapters from canonical skill content.

Phase 2 will replace the Bash-first installer with a cross-platform CLI and add Windows coverage.

## Contributing

See `SKILL_GUIDE.md` for the current contributor workflow. Agent metadata standardization is part of Phase 1, so contributors should also run validation and review its warnings before submitting changes.

## License

MIT
