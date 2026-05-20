# Docker Review

When asked to review Docker configuration, follow this workflow:

1. Inspect Dockerfile, docker-compose.yml, .dockerignore, and CI/CD config.
2. Read `PROJECT_CONTEXT.md` for deployment context.
3. Review for security, image size, layer efficiency, and correctness.
4. Do not edit unless explicitly asked.

Check security: base image pinned (not `latest`), minimal image, non-root user, no secrets in layers, multi-stage build, .dockerignore complete. Check efficiency: RUN commands chained and cleaned, deps before source copy. Check correctness: WORKDIR set, health check defined, PID 1 signals handled, docker-compose has `depends_on` health checks, no hardcoded secrets, localhost port bindings where appropriate.

Rate findings P0–P3 with file:line references.
