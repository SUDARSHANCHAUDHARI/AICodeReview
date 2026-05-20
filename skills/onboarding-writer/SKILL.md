---
name: onboarding-writer
description: Generate an ONBOARDING.md by reading the repo structure, README, build config, and key source files — no invented content, only verified facts.
---

# Onboarding Writer

When asked to generate onboarding documentation, follow this workflow:

1. Read the repository root: list all top-level files and directories.
2. Read the existing README.md (or README.rst, README.txt) in full.
3. Read all build config files present: package.json, build.gradle / settings.gradle, pyproject.toml / setup.py, Cargo.toml, go.mod, Makefile, Dockerfile, docker-compose.yml.
4. Read all CI config files: .github/workflows/*.yml, .gitlab-ci.yml, .circleci/config.yml, Jenkinsfile.
5. Identify the primary source directories (src/, app/, lib/, pkg/, cmd/, etc.) and list their top-level subdirectories.
6. Read the entry point file(s): main function, index file, application bootstrap, or router config.
7. Read the dependency injection or service wiring file if one exists.
8. Read the environment config example file if present (.env.example, config.example.yml, application.yml).
9. Read any existing architecture docs (docs/, ADR files, ARCHITECTURE.md).
10. Based only on what you have read, write ONBOARDING.md with these sections:

    ## Project Purpose
    One paragraph: what this project does, who uses it, and why it exists — sourced from README and entry point.

    ## Architecture Overview
    Describe the architectural pattern detected (MVC, Clean Architecture, MVVM, microservices, etc.), the primary layers and what lives in each, and how data flows through the system. Include a directory tree of key folders with one-line descriptions.

    ## Local Setup
    Step-by-step numbered instructions to get a working local environment: prerequisites, environment variables (list names from .env.example, not values), install commands, database setup, and the command to run the app. All steps sourced from README or build config.

    ## Key Flows to Understand First
    List 3–5 critical user or data flows a new developer should trace first (e.g., "user login", "order placement", "data sync"). For each, name the entry point file and function and trace the path through layers.

    ## Common Pitfalls
    List known gotchas sourced from README warnings, comments in code, or TODO/FIXME context — do not invent pitfalls.

    ## Domain Glossary
    List domain-specific terms found in the codebase (class names, function names, comments that define concepts) with one-line definitions sourced from code or docs.

11. If any section cannot be populated from the files read, write: "Not enough information found in the repository to complete this section." Do not invent content.
12. Write the completed ONBOARDING.md to the repository root.

Output: ONBOARDING.md file written to the repository root.

Rules:
- Read actual files before writing any section — no assumptions from filenames alone.
- Every claim in ONBOARDING.md must be traceable to a file you read in this session.
- Do not copy-paste large code blocks into ONBOARDING.md — use file references and short snippets only.
- Do not invent setup steps, domain terms, or architecture patterns — if uncertain, say so.
- If an ONBOARDING.md already exists, read it first and update rather than overwrite.
