## Docker Review Convention

When asked to review Docker configuration:

1. Check base image pinned to specific version/digest — not `latest`.
2. Check minimal base image; container runs as non-root.
3. Check no secrets in ENV/ARG/COPY/RUN — they persist in image layers.
4. Check multi-stage build excludes build tools from final image.
5. Check .dockerignore excludes .env/.git/node_modules/keystores.
6. Check RUN commands chained and cleaned in same layer.
7. Check deps installed before source copy for layer caching.
8. Check WORKDIR set, health check defined, PID 1 signals handled.
9. docker-compose: `depends_on` health checks, no hardcoded secrets, localhost bindings.
10. Rate findings P0–P3 with file:line references.
