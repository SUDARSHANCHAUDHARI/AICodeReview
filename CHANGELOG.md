# Changelog

All notable changes to AICodeReview will be documented here.

## Unreleased

### Phase 0B native agent integrations

- Replaced the combined GitHub Copilot instruction section with native project skills under `.github/skills/`.
- Replaced persistent Gemini `GEMINI.md` review context with native workspace skills under `.gemini/skills/`.
- Added native OpenCode support under `.opencode/skills/`.
- Added a managed `AICODEREVIEW.md` conventions file for Aider.
- Added safe Aider auto-configuration when `.aider.conf.yml` does not already contain a user-managed `read` setting.
- Added migration from legacy Copilot, Gemini, and Aider managed sections while preserving user-owned content outside the markers.
- Changed migration to reject corrupt legacy markers before any native skill path is modified.
- Added an all-agent preflight gate so a late conflict or corrupt migration cannot leave a partial installation.
- Added update, inventory, health-check, and uninstall support for native project skill adapters.
- Added behavioral coverage for native installs, legacy migration, conflict backups, Aider configuration, all-agent preflight, and safe uninstall.

### Phase 0A foundation hardening

- Replaced duplicated hard-coded skill arrays with one dynamically discovered inventory.
- Added ownership markers for native skill directories and generated files.
- Changed forced installation so unmanaged conflicts are backed up instead of silently deleted.
- Changed uninstall so unmanaged skill directories and generated files are preserved.
- Added strict validation for managed marker count and order before update or removal.
- Added atomic managed-section replacement.
- Expanded health checks to cover every discovered skill and report unmanaged or stale installs.
- Corrected the README support matrix to distinguish native skills, Cursor rules, and Aider conventions.
- Added Ubuntu and macOS GitHub Actions validation.
- Added behavioral install and uninstall safety tests.
- Removed the unpublished Homebrew formula stub; distribution packaging will return with a real release and checksum.

### Existing unreleased work

- Restructured from Codex-only workflows to agent-agnostic skills.
- Rewrote install and uninstall commands with agent and project options.
- Added `ios-review`, `web-review`, `changelog-writer`, `dependency-audit`, `agent-config-review`, `backend-review`, `performance-review`, `accessibility-audit`, `database-review`, `test-writer`, `kmp-review`, `docker-review`, `ci-review`, `api-design-review`, `flutter-review`, `refactor-planner`, `architecture-review`, `code-smell-detector`, `error-handling-review`, `graphql-review`, `react-native-review`, `tech-debt-audit`, and `onboarding-writer`.
- Added maintenance scripts, project-context examples, issue templates, and contributor guidance.
- Total skill count: 31.

## v0.1.0

- Initial skill pack scaffold.
- Added review, security audit, explanation, fixer, Android, release, pull request summary, and context-writer skills.
- Added project context templates and examples.
- Added local validation script.
