# Project Context

## What This Project Is

- Product: REST API service built with Django REST Framework.
- Users: Internal and external API consumers; mobile and web clients.
- Main platform: Python 3.12 / Django 5 running on Linux containers.

## Tech Stack

- Language: Python 3.12.
- Framework: Django 5 with Django REST Framework (DRF).
- Database: PostgreSQL 16 (primary), Redis 7 (cache and Celery broker).
- Task queue: Celery 5 with Redis backend.
- Testing: pytest + pytest-django + factory_boy.
- Linting / formatting: ruff (replaces flake8 + isort + black).
- Type checking: mypy (strict mode).
- Containerization: Docker + docker-compose for local dev.
- Migrations: Django ORM migrations (tracked in version control).

## Architecture

```
project/
  apps/
    users/           # custom User model, JWT auth, profile management
    orders/          # domain models, serializers, views, tasks
    notifications/   # Celery tasks, signal handlers
  config/
    settings/        # base.py, development.py, production.py
    urls.py
    celery.py
  tests/
    factories/       # factory_boy model factories
    integration/     # API endpoint tests using APIClient
    unit/            # model and serializer unit tests
```

- Views: Class-based (`APIView`, `GenericAPIView`, `ModelViewSet`).
- Serializers: Nested DRF serializers; `validate_<field>` for field-level, `validate` for cross-field.
- Signals: Used for async side effects (e.g., send welcome email on user creation).
- Permissions: Custom `BasePermission` subclasses; DRF `IsAuthenticated` + `IsAdminUser`.
- Authentication: JWT via `djangorestframework-simplejwt`.

## Review Priorities

- SQL query efficiency: look for N+1 patterns in serializers (`select_related`, `prefetch_related`).
- Celery task idempotency: tasks must be safe to retry.
- Migration safety: large table migrations must be backward-compatible.
- Secrets: never in settings files; read via `os.environ` or `django-environ`.
- Sensitive data: no PII in logs or error responses.
- Input validation: all user input validated through serializers before reaching model layer.
- Error responses: consistent DRF error envelope format.

## Commands

- Run dev server: `python manage.py runserver`
- Apply migrations: `python manage.py migrate`
- Create migration: `python manage.py makemigrations`
- Run tests: `pytest`
- Run tests with coverage: `pytest --cov=apps --cov-report=term-missing`
- Lint: `ruff check .`
- Format: `ruff format .`
- Type check: `mypy .`
- Start Celery worker: `celery -A config worker -l info`
- Start Celery beat: `celery -A config beat -l info`

## Known Risk Areas

- Nested serializer `create`/`update` methods often bypass ORM signals — verify
  that side effects still fire when using `bulk_create`.
- Long-running Celery tasks without soft/hard time limits will silently hang.
- Django `select_related` is not applied on the default queryset for several
  ViewSets — check serializer depth before enabling browsable API in production.

## Active Migrations

- Add entries here whenever a multi-step migration is in progress (e.g., rename
  column in two deployments to stay backward-compatible).
