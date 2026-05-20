---
name: docker-review
description: Use when reviewing Dockerfiles, docker-compose files, container configuration, image builds, or container security for any project.
---

# Docker Review

## Workflow

1. Inspect `Dockerfile`, `docker-compose.yml`, `.dockerignore`, and related CI/CD config.
2. Read `PROJECT_CONTEXT.md` and `AGENTS.md` for deployment context and known risk areas.
3. Review for security, image size, layer efficiency, and correctness.
4. Do not edit files unless explicitly asked.

## Checklist

### Security
- Base image is pinned to a specific digest or version tag — not `latest`.
- Base image is minimal: prefer `alpine`, `distroless`, or official slim variants over full OS images.
- Container does not run as root: `USER` directive sets a non-root user before `CMD`/`ENTRYPOINT`.
- No secrets, API keys, or credentials in `ENV`, `ARG`, `COPY`, or `RUN` commands — they persist in image layers.
- Multi-stage build used to exclude build tools, source code, and dev dependencies from the final image.
- `.dockerignore` excludes `.env`, `node_modules`, `.git`, keystores, and other sensitive or large files.
- Read-only filesystem (`--read-only`) considered for production containers.

### Image Size / Layer Efficiency
- `RUN` commands chained with `&&` and cleaned up in the same layer (`rm -rf /var/lib/apt/lists/*` after `apt-get`).
- Dependencies installed before copying source code so the dependency layer is cached correctly.
- Only files needed at runtime are copied into the final stage.
- Large unnecessary files not included (test data, docs, CI scripts).

### Correctness
- `COPY` paths are correct and predictable — not using wildcard patterns that may match unintended files.
- `WORKDIR` set explicitly rather than relying on defaults.
- `EXPOSE` documents the correct port; matches what the application actually listens on.
- `ENTRYPOINT` vs `CMD` used correctly: `ENTRYPOINT` for the executable, `CMD` for default arguments.
- Health check defined for long-running services.
- Signals handled correctly: PID 1 forwards signals to the app process (use `exec` form or an init process).

### docker-compose
- Service dependencies declared with `depends_on` and health check conditions where order matters.
- Volumes mounted for persistent data; no important data written to the container layer.
- Environment variables loaded from `.env` file or external secrets manager — not hardcoded in compose file.
- Port bindings restricted to localhost (`127.0.0.1:8080:8080`) where external exposure is not intended.
- Networks defined explicitly; services not on the default bridge network unnecessarily.

## Output

```markdown
## Docker Review Findings

**[P0]** `Dockerfile:12` - Secret passed as ARG/ENV
Build arg `API_KEY` persists in image history. Use Docker secrets or runtime env injection.

**[P1]** `Dockerfile:1` - Base image unpinned (using latest)
`FROM node:latest` will silently change on next build. Pin to `node:20.14.0-alpine3.19`.

## Summary

Security verdict and image hygiene summary.
```
