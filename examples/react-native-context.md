# Project Context

## What This Project Is

- Product: Cross-platform mobile application (iOS + Android) built with React Native.
- Users: Consumer-facing; available on Apple App Store and Google Play.
- Main platform: React Native 0.74, TypeScript, targeting iOS 16+ and Android API 26+.

## Tech Stack

- Framework: React Native 0.74.
- Language: TypeScript (strict mode).
- Navigation: React Navigation v6 (`@react-navigation/native`, stack, bottom tabs).
- Global state: Zustand v4.
- Server state / data fetching: React Query (TanStack Query v5).
- API communication: `axios` (REST) or `graphql-request` (GraphQL endpoints).
- Forms: React Hook Form + Zod schema validation.
- Styling: StyleSheet API; design tokens via a theme context.
- Testing: Jest + React Native Testing Library (unit/component), Detox (E2E).
- Linting / formatting: ESLint + Prettier.
- Native modules: `react-native-permissions`, `react-native-camera`, `react-native-fs`.

## Architecture

```
src/
  screens/           # one folder per screen; Screen.tsx + Screen.test.tsx
  components/        # shared UI components
  hooks/             # custom hooks (useAuth, useCamera, etc.)
  stores/            # Zustand stores (one file per domain)
  queries/           # React Query query/mutation definitions
  services/          # API clients, native module wrappers
  navigation/        # navigator definitions and typed navigation params
  theme/             # colors, spacing, typography tokens
  utils/             # pure utility functions
e2e/                 # Detox test specs
```

- Screen components: receive navigation props only; delegate data fetching to
  React Query hooks and reads from Zustand stores.
- Custom hooks: encapsulate side effects and business logic; named `use*`.
- NativeModules: wrapped in a TypeScript service class to isolate platform diffs.

## Review Priorities

- Bridge calls (NativeModules): must not block the JS thread; async callbacks only.
- Navigation type safety: all route params defined in `RootParamList`; no `any` casts.
- React Query cache keys: must be deterministic and not include unstable object refs.
- Zustand selectors: use shallow equality where derived state would cause unnecessary
  re-renders.
- Permissions: always check and request before accessing camera, location, or contacts.
- Platform-specific code: isolate in `*.ios.ts` / `*.android.ts` files or guard with
  `Platform.OS`.
- Accessibility: `accessibilityLabel`, `accessible`, and `accessibilityRole` on all
  interactive elements.
- Bundle size: no large dependencies imported wholesale (e.g., `import * as _ from 'lodash'`).

## Commands

- Start Metro: `yarn start`
- Run on iOS: `yarn ios`
- Run on Android: `yarn android`
- Unit tests: `yarn test`
- Unit tests with coverage: `yarn test --coverage`
- Lint: `yarn lint`
- Type check: `yarn tsc --noEmit`
- E2E (iOS): `detox test --configuration ios.sim.debug`
- E2E (Android): `detox test --configuration android.emu.debug`
- Clean Metro cache: `yarn start --reset-cache`

## Known Risk Areas

- Old architecture (`JSI` bridge mode) still active on some native modules — check
  for deprecated `NativeModules` references before enabling the new architecture.
- Detox tests are flaky on CI if the emulator/simulator starts before the Metro
  bundler is fully ready; the CI job must include a health-check wait step.
- React Query's `staleTime` defaults to 0 — review cache settings per query to
  avoid excessive network calls on re-focus.

## Active Migrations

- Add entries here when a platform API or major dependency migration is in progress
  (e.g., migrating from AsyncStorage to MMKV, or enabling the New Architecture).
