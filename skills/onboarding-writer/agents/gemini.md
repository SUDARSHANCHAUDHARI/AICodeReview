# Onboarding Writer

When asked to generate onboarding documentation, follow this workflow:

1. Read the repo root listing, the full README, and all build config files (package.json, build.gradle, pyproject.toml, Cargo.toml, go.mod, Makefile, Dockerfile).
2. Read all CI config files (.github/workflows/, .gitlab-ci.yml, .circleci/config.yml, Jenkinsfile).
3. Read the application entry point, DI wiring file, and .env.example or equivalent.
4. Read any existing architecture docs (docs/, ADR files, ARCHITECTURE.md).
5. Write ONBOARDING.md with:
   - **Project Purpose** — what it does, who uses it, why.
   - **Architecture Overview** — detected pattern, layers, directory tree with descriptions.
   - **Local Setup** — numbered steps: prerequisites, env var names, install, run.
   - **Key Flows** — 3–5 critical flows with entry point file:function and layer trace.
   - **Common Pitfalls** — from README warnings or code comments only.
   - **Domain Glossary** — terms from code/docs with one-line definitions.
6. For sections with insufficient information, write: "Not enough information found in the repository to complete this section."
7. If ONBOARDING.md exists, update it rather than overwrite.

Check: README read, build config read, entry point read, .env.example read, no invented content.

Output: ONBOARDING.md written to repository root.
