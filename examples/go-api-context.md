# Project Context

## What This Project Is

- Product: HTTP REST API service written in Go.
- Users: Mobile and web clients consuming JSON over HTTPS.
- Main platform: Go 1.22, deployed as a single binary on Linux (Docker / Kubernetes).

## Tech Stack

- Language: Go 1.22.
- Router: chi v5 (`github.com/go-chi/chi/v5`).
- Database: PostgreSQL 16.
- SQL layer: sqlc (compile-time type-safe queries from `.sql` files).
- Migrations: golang-migrate (`migrate` CLI).
- Testing: testify v1 (`assert`, `require`, `mock`).
- Linting: golangci-lint (config in `.golangci.yml`).
- Containerization: Docker + docker-compose.
- Config: environment variables via `github.com/kelseyhightower/envconfig`.

## Architecture

```
cmd/
  api/
    main.go          # wires dependencies, starts HTTP server
internal/
  handler/           # HTTP handlers (thin layer; extract from request, call service, write response)
  service/           # business logic; accepts and returns domain types
  repository/        # DB access; sqlc-generated types; repository interfaces
  domain/            # shared value types and domain errors
  middleware/        # auth, logging, request ID, timeout
  testutil/          # shared test helpers and fixtures
db/
  queries/           # .sql files that sqlc reads
  migrations/        # up/down SQL migration files
```

- Context propagation: `context.Context` is the first argument to every function
  that does I/O; cancellation and deadline propagation is mandatory.
- Error handling: errors wrap with `%w`; handlers convert domain errors to HTTP
  status codes using a central error-mapping helper.
- Authentication: JWT validated in middleware; user identity attached to context.
- Repository interfaces: defined in `internal/repository`; implementations use
  sqlc-generated code; tests mock the interface.

## Review Priorities

- Context cancellation: every DB call and outbound HTTP call must respect ctx.
- Error wrapping: `fmt.Errorf("...: %w", err)` on every error path for stack clarity.
- Goroutine leaks: goroutines spawned in handlers must complete before the
  server shuts down (check `WaitGroup` usage in shutdown logic).
- Table-driven tests: prefer `t.Run` subtests with a slice of test cases.
- SQL injection: all queries go through sqlc — no raw string concatenation in queries.
- Migration safety: each migration must have a matching down migration.
- Linting: code must pass `golangci-lint run` with the project's `.golangci.yml`.

## Commands

- Build: `go build ./...`
- Run tests: `go test ./...`
- Run tests (verbose): `go test -v -race ./...`
- Vet: `go vet ./...`
- Lint: `golangci-lint run`
- Generate sqlc code: `sqlc generate`
- Apply migrations (up): `migrate -path db/migrations -database "$DATABASE_URL" up`
- Apply migrations (down 1): `migrate -path db/migrations -database "$DATABASE_URL" down 1`
- Run dev server: `go run ./cmd/api`

## Known Risk Areas

- Handler timeout middleware is applied globally; individual endpoints that
  legitimately need longer processing (e.g., report generation) must override
  or be excluded explicitly.
- sqlc regeneration must follow any change to `.sql` query files; stale generated
  code will silently use the old schema.
- Response JSON field names are set by struct tags — check that new fields have
  correct `json:` tags before merging.

## Active Migrations

- Add entries here whenever a migration sequence is in progress across deployments.
