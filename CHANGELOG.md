# Changelog

All notable changes to AICodeReview will be documented here.

## Unreleased

- Restructured to multi-agent: skills renamed from `codex-*` to agent-agnostic names.
- Added agent configs for Cursor (`.mdc`), GitHub Copilot, Gemini CLI, and Aider alongside existing Codex and Claude Code support.
- Rewrote `install.sh` with `--agent` and `--project` flags to support all six agents.
- Rewrote `uninstall.sh` to match.
- Updated `validate.sh` to check all five agent config files per skill.
- Updated README, USAGE, and CUSTOMISING docs to reflect multi-agent support.
- Added `ios-review`, `web-review`, `changelog-writer`, `dependency-audit`, `agent-config-review` skills.
- Added `backend-review`, `performance-review`, `accessibility-audit`, `database-review`, `test-writer`, `kmp-review`, `docker-review`, `ci-review`, `api-design-review`, `flutter-review`, `refactor-planner` skills.
- Total skill count: 24.
- Added `architecture-review`, `code-smell-detector`, `error-handling-review`, `graphql-review`, `react-native-review`, `tech-debt-audit`, `onboarding-writer` skills.
- Added `update.sh`, `list-installed.sh`, `check-health.sh` maintenance scripts.
- Added `tests/` directory with bash test suite (`run-all.sh`, `test-install.sh`, `test-validate.sh`).
- Added 4 new example context files: Python/Django, Go API, React Native, iOS/Swift.
- Added GitHub community files: issue templates (bug, skill request) and PR template.
- Added `SKILL_GUIDE.md` — contributor guide for writing new skills.
- Added Homebrew formula stub (`Formula/aicodereview.rb`) and npm package stub (`package.json`).
- Total skill count: 31.

## v0.1.0

- Initial skill pack scaffold.
- Added review, security audit, explanation, fixer, Android, release, PR summary, and context writer skills.
- Added project context templates and examples.
- Added local validation script.
