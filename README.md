# AICodeReview

Portable code-review workflows for multiple AI coding agents.

AICodeReview keeps every workflow in one canonical `SKILL.md`. Native agents receive that directory directly. Cursor rules, Aider conventions, and OpenAI product metadata are generated deterministically from the same source.

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

The installer discovers skill directories dynamically. Adding a skill does not require editing a hard-coded list.

## Agent support

| Agent | Adapter | Install target | Behavior |
|---|---|---|---|
| Claude Code | Native Agent Skill | `~/.claude/skills/` | Loaded on demand from `SKILL.md` |
| OpenAI Codex | Native Agent Skill | `~/.codex/skills/` | Loaded on demand from `SKILL.md` |
| GitHub Copilot | Native Agent Skill | `<project>/.github/skills/` | Discovered and activated when relevant |
| Gemini CLI | Native Agent Skill | `<project>/.gemini/skills/` | Discovered and activated through `activate_skill` |
| OpenCode | Native Agent Skill | `<project>/.opencode/skills/` | Loaded on demand through the native skill tool |
| Cursor | Generated project rule | `<project>/.cursor/rules/` | Generated from `SKILL.md` during installation |
| Aider | Generated conventions file | `<project>/AICODEREVIEW.md` | Generated from all canonical skills and loaded through `.aider.conf.yml` |

Native skills are not copied into persistent Copilot or Gemini instruction files.

## Canonical structure

```text
skills/<skill-name>/
├── SKILL.md
└── agents/
    └── openai.yaml
```

`SKILL.md` is the only workflow source.

`agents/openai.yaml` contains generated product-facing metadata:

```yaml
interface:
  display_name: "Code Review"
  short_description: "Run the Code Review workflow"
  default_prompt: "Use $code-review to apply this workflow to the current repository."
```

All metadata strings are quoted. Short descriptions are 25–64 characters, and every default prompt explicitly invokes its skill.

## Install

Clone the repository:

```bash
git clone https://github.com/SUDARSHANCHAUDHARI/AICodeReview.git
cd AICodeReview
```

Install Claude Code and Codex:

```bash
./install.sh
```

Install a project-scoped integration:

```bash
./install.sh --agent cursor   --project /path/to/project
./install.sh --agent copilot  --project /path/to/project
./install.sh --agent gemini   --project /path/to/project
./install.sh --agent opencode --project /path/to/project
./install.sh --agent aider    --project /path/to/project
```

Install every current adapter:

```bash
./install.sh --agent all --project /path/to/project
```

The all-agent command preflights every destination, generated artifact, and migration marker before writing the first file.

Preview changes:

```bash
./install.sh --agent all --project /path/to/project --dry-run
```

Update managed installations:

```bash
./install.sh --agent all --project /path/to/project --force
```

## Generated artifacts

Verify committed OpenAI metadata:

```bash
python3 scripts/skill_artifacts.py sync-openai --check
```

Regenerate it after adding or renaming a skill:

```bash
python3 scripts/skill_artifacts.py sync-openai --write
```

Preview one generated Cursor rule:

```bash
python3 scripts/skill_artifacts.py render-cursor \
  --skill code-review \
  --output /tmp/code-review.mdc
```

Preview the generated Aider conventions:

```bash
python3 scripts/skill_artifacts.py render-aider \
  --output /tmp/AICODEREVIEW.md
```

Do not create or maintain `cursor.mdc`, `copilot.md`, `gemini.md`, or `aider.md` inside individual skill directories. Validation rejects those obsolete duplicate adapters.

## Legacy migration

Older releases appended AICodeReview content to `.github/copilot-instructions.md`, `GEMINI.md`, and `CONVENTIONS.md`.

The installer validates the managed marker pair, installs the replacement, then removes only the managed legacy section. User-owned content outside the markers is preserved. Corrupt markers stop migration before replacement files are written.

## Installation safety

AICodeReview writes ownership markers into native skill directories and beside generated files.

Without `--force`, unmanaged conflicts stop installation. With `--force`, existing content is moved to a timestamped backup before replacement. Uninstall removes only managed paths.

For Aider:

- If `.aider.conf.yml` has no `read` setting, the installer adds a managed block for `AICODEREVIEW.md`.
- If a user-managed `read` setting exists, it remains unchanged.
- The installer never creates a duplicate top-level `read` key.

## Use

```text
Use code-review to review my current changes.
Use security-audit on this pull request.
Use review-fixer to fix only safe and concrete findings.
Use release-review to check whether this build is ready to ship.
Use architecture-review to inspect dependency direction and layer violations.
Use test-writer to add tests grounded in the repository's current test style.
```

For Gemini CLI, run `/skills reload` after adding or updating workspace skills.

## Per-project context

```bash
cp templates/PROJECT_CONTEXT.md /path/to/project/PROJECT_CONTEXT.md
```

Document the actual stack, architecture, conventions, verification commands, and migration constraints. Skills read this file when present.

## Maintenance

```bash
./update.sh --project /path/to/project
./list-installed.sh --project /path/to/project
./check-health.sh --project /path/to/project
```

`check-health.sh` renders expected Cursor and Aider output from `SKILL.md` before comparing installed files. It also verifies OpenAI metadata, ownership markers, incomplete migrations, Aider activation, and corrupt marker states.

## Uninstall

```bash
./uninstall.sh --agent claude
./uninstall.sh --agent copilot --project /path/to/project
./uninstall.sh --agent all --project /path/to/project
```

User-owned paths and configuration remain untouched.

## Validate and test

```bash
./scripts/validate.sh
./tests/run-all.sh
```

Validation rejects metadata drift and obsolete duplicated adapters. Behavioral tests cover generation, installation, migration, backups, inventory, Aider configuration, all-agent preflight, and uninstall.

## Design principles

- Inspect real files before making claims.
- Report production risks rather than personal style preferences.
- Rank findings by severity and include file and line references.
- Keep review workflows read-only unless the user explicitly requests changes.
- Prefer small, verifiable fixes over broad rewrites.
- Keep secrets, keys, signing files, private data, and `.env` values out of context files.
- Describe skills, rules, conventions, and hooks accurately instead of treating them as interchangeable.

## Roadmap

- **Phase 0:** Installation ownership, migration safety, native Copilot and Gemini support, OpenCode support, Aider activation, and CI.
- **Phase 1:** Canonical workflow source, standardized OpenAI metadata, and generated Cursor/Aider adapters.
- **Phase 2:** Cross-platform TypeScript CLI and Windows coverage.
- **Phase 3:** Optional hooks and behavioral evaluation repositories.

## Contributing

See `SKILL_GUIDE.md`.

## License

MIT
