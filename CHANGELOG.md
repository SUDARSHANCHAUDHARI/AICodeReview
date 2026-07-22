# Changelog

All notable changes to AICodeReview will be documented here.

## Unreleased

### Phase 0A foundation hardening

- Replaced duplicated hard-coded skill arrays with one dynamically discovered inventory.
- Added ownership markers for native skill directories and Cursor rules.
- Changed forced installation so unmanaged conflicts are backed up instead of silently deleted.
- Changed uninstall so unmanaged skill directories and Cursor rules are preserved.
- Added strict validation for combined-file marker count and order before update or removal.
- Added atomic combined-section replacement.
- Expanded health checks to cover every discovered skill and report unmanaged or stale installs.
- Corrected the README support matrix to distinguish native skills, Cursor rules, and persistent instruction adapters.
- Documented the Aider `/read` or `.aider.conf.yml` activation requirement.
- Added Ubuntu and macOS GitHub Actions validation.
- Added behavioral install and uninstall safety tests.

### Existing unreleased work

- Restructured to multi-agent: skills renamed from `codex-*` to agent-agnostic names.
- Added agent configs for Cursor (`.mdc`), GitHub Copilot, Gemini CLI, and Aider alongside existing Codex and Claude Code support.
- Rewrote `install.sh` with `--agent` and `--project` flags.
- Rewrote `uninstall.sh` to match.
- Added `ios-review`, `web-review`, `changelog-writer`, `dependency-audit`, `agent-config-review`, `backend-review`, `performance-review`, `accessibility-audit`, `database-review`, `test-writer`, `kmp-review`, `docker-review`, `ci-review`, `api-design-review`, `flutter-review`, `refactor-planner`, `architecture-review`, `code-smell-detector`, `error-handling-review`, `graphql-review`, `react-native-review`, `tech-debt-audit`, and `onboarding-writer`.
- Added maintenance scripts, test suites, project-context examples, issue templates, and contributor guidance.
- Total skill count: 31.

## v0.1.0

- Initial skill pack scaffold.
- Added review, security audit, explanation, fixer, Android, release, pull request summary, and context-writer skills.
- Added project context templates and examples.
- Added local validation script.
