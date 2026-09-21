# Dreaming

Dreaming is a private, local-first dream-memory journal built with Flutter for web and mobile. It records dreams on the user's device and visualizes yearly dream-recording history with a GitHub-style binary heatmap.

## Product scope

- No accounts, authentication, backend, Firebase, Supabase, cloud database, or AI.
- Dream content stays in local device storage.
- One Flutter codebase supports Android, iOS, and web.

## Tech stack

| Layer | Technology | Version |
|-------|------------|---------|
| Framework | Flutter | 3.35.4 (stable channel) |
| Language | Dart | 3.9.2 |
| App version | — | 0.1.0 |
| State management | `provider` | 6.1.5+1 |
| Local storage | `shared_preferences` | 2.5.5 (schema version 1) |
| Unique IDs | `uuid` | 4.6.0 |
| Date formatting | `intl` | 0.19.0 |
| CSV export | `csv` | 6.0.0 |
| File sharing/download | `share_plus` | 10.1.4 |
| File paths | `path_provider` | 2.1.5 |
| Linting | `flutter_lints` | 5.0.0 |
| Testing | `flutter_test` (SDK) | — |

Additional platform details:
- Android: AGP 8.9.1, Kotlin 2.1.0, Gradle 8.12, Java 11
- iOS/macOS: native Swift/Kotlin runners scaffolded
- Windows/Linux: desktop runners scaffolded (functional locally)
- Web: PWA manifest and index.html retain stock Flutter defaults

## Getting started

Prerequisites:
- Flutter SDK 3.35+ (Dart 3.9.2 included)
- Android Studio / VS Code with Flutter extensions for mobile development
- Chrome for web development

Setup:
```bash
flutter pub get
flutter run -d chrome       # web
flutter run -d windows      # Windows desktop
flutter run -d <device-id>  # connected Android/iOS device
```

No accounts, backend, environment variables, or database setup required — the app is fully local-first.

## Platform support

- **Primary**: Android, iOS, Web
- **Desktop scaffolding**: Windows, Linux, macOS runners exist and build locally; not yet feature-complete

## Features

- Yearly GitHub-style heatmap with correct weekday alignment, leap-year support, future-date handling, and year navigation.
- Day quick preview before opening the complete day view.
- Multiple independent dreams per day.
- Dream creation and editing with title, dream text, emoji mood, reusable tags, and exact date/time.
- Dream detail view with edit, duplicate, and confirmed permanent delete actions.
- Global search across title, content, tags, and mood.
- Composable filters for mood, tags, and date ranges.
- Lightweight yearly statistics: dreams this year, days with dreams, current streak, and longest streak.
- Export all dreams as human-readable JSON or correctly escaped CSV.
- Responsive navigation: bottom navigation on compact screens and a navigation rail on desktop.
- Accessible heatmap cell labels such as “August 12, 2026 — 3 dreams recorded”.

## Architecture

The app uses a simple clean architecture:

```text
lib/
├── app/                    # App shell and theme
├── core/                   # Shared utilities
└── features/
    ├── dreams/             # Domain model, repository abstraction, state, CRUD UI
    ├── heatmap/            # Year calendar generation and heatmap widget
    ├── search/             # Search/filter model and UI
    ├── export/             # JSON/CSV export and share/download handoff
    └── settings/           # Storage, export, and about screen
```

Widgets do not manipulate storage directly. UI talks to `DreamStore`, which persists through the `DreamRepository` abstraction. `LocalDreamRepository` stores a versioned JSON payload in `shared_preferences`.

## State management choice

Dreaming uses `provider` with a single `DreamStore` because V1 has one core domain collection and benefits from a small, easy-to-review state layer. The heatmap, day views, statistics, search, and filters derive from the dream list instead of keeping separate copies of dream state.

## Persistence and migrations

Local data is saved under schema version `1`:

```json
{
  "schemaVersion": 1,
  "exportedAt": "...",
  "dreams": []
}
```

Future imports/migrations should inspect `schemaVersion`, transform older records into the current `Dream` model, skip or report malformed records without crashing, and then persist through `DreamRepository`.

## Export formats

- JSON: structured, indented, includes schema version and all dream fields.
- CSV: uses the `csv` package so commas, quotes, newlines, and Unicode are escaped correctly.

`share_plus` is used to hand the generated file to the platform. On web this falls back to browser download behavior where supported by the plugin.

## Verification

Run:

```bash
flutter analyze
flutter test
```

Tests cover serialization/deserialization, older-data tolerance, CRUD behavior, duplicate/delete behavior, date grouping, heatmap generation, leap years, future dates, sorting, statistics, search, combined filtering, JSON export, CSV escaping, and key widget flows.

## Known limitations and future improvements

- Import is intentionally not implemented for V1, but JSON exports are schema-versioned for future import support.
- Theme follows the system theme; an explicit in-app theme preference can be added later.
- Export relies on platform sharing/downloading capabilities rather than a custom file picker.
- Integration tests can be expanded with a real app restart once platform runners are configured in CI.

## Screenshots (placeholder)

<!-- TODO: add heatmap view screenshot -->
<!-- TODO: add editor & search screenshots -->
<!-- TODO: add settings/export screenshots -->

## Related docs

- Product specification: [`dreaming_agent_product_prompt(1).md`](dreaming_agent_product_prompt\(1\).md) — authoritative product build spec (UX flows, data model, testing matrix)
- Run configuration: IntelliJ/Android Studio run config in `.idea/runConfigurations/main.dart.xml`
