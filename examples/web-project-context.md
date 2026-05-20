# Project Context

## What This Project Is

- Product: Web app or website.
- Users: End users on desktop and mobile browsers.
- Main platforms: Desktop and mobile web.

## Tech Stack

- Language: TypeScript (strict mode).
- Framework: Next.js 15 (App Router).
- Package manager: pnpm.
- Styling: Tailwind CSS.
- Data fetching: React Query for server state; Zustand for client state.
- Auth: Clerk.
- Persistence: Supabase (Postgres).
- Testing: Vitest (unit), Playwright (E2E).

## Architecture

- `app/` or `pages/`: routes and screen-level composition.
- `components/`: reusable UI components.
- `lib/`: shared utilities and API clients.
- `server/` or API routes: backend entry points and server actions.
- `tests/`: unit, integration, and E2E tests.

## Review Priorities

- Correct loading, empty, and error states for all data fetches.
- Input validation at server boundaries — never trust client input.
- No secrets in public environment variables (`NEXT_PUBLIC_*`).
- Accessibility and keyboard navigation.
- Responsive layout without text overlap or overflow.
- Performance of data fetching and rendering (avoid waterfalls).

## Commands

- Dev server: `pnpm dev --turbopack`
- Build: `pnpm build`
- Type check: `pnpm exec tsc --noEmit`
- Lint: `pnpm lint`
- Unit tests: `pnpm test`
- E2E tests: `pnpm exec playwright test`

## Known Risk Areas

- Server actions that mutate data without revalidating the relevant cache tags.
- Client components accidentally importing server-only modules.

## Active Migrations

- None currently. Add entries here when a migration is in progress.
