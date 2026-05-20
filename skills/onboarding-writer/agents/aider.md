## Onboarding Writer Convention

When asked to generate onboarding documentation:

1. Read the repo root listing, full README, and all build config files (package.json, build.gradle, pyproject.toml, Cargo.toml, go.mod, Makefile, Dockerfile).
2. Read all CI config files (.github/workflows/, .gitlab-ci.yml, .circleci/config.yml).
3. Read the application entry point, DI wiring file, and .env.example or equivalent.
4. Read any existing architecture docs (docs/, ARCHITECTURE.md, ADRs).
5. Write ONBOARDING.md with:
   - Project Purpose (what, who, why — from README and entry point).
   - Architecture Overview (detected pattern, layers, directory tree with descriptions).
   - Local Setup (numbered steps: prerequisites, env var names, install, run).
   - Key Flows to Understand First (3–5 flows with entry point file:function and layer trace).
   - Common Pitfalls (from README warnings or code comments only — nothing invented).
   - Domain Glossary (terms from code or docs with one-line definitions).
6. If a section lacks sufficient source material, write: "Not enough information found in the repository to complete this section."
7. If ONBOARDING.md already exists, read it first and update rather than overwrite.
