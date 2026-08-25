# Prinia

A local-first productivity app for students. Prinia combines an expense tracker, a Pomodoro timer, and a class timetable in a single offline Android application.

## Features

### Expense Tracker
- Income and expense records with 7 preset categories plus user-defined tags
- Monthly summary with balance, daily expense bar chart (0-300 coordinate system), and category pie chart
- Tap a bar in the chart to inspect a single day; the pie chart follows the selection
- Custom tags with searchable icon picker and fallback mascot icon
- Soft delete with confirmation

### Pomodoro Timer
- Configurable focus and rest durations (15-minute aware, persisted across restarts)
- Continuous focus/rest cycling with completion alerts (vibration and sound)
- Leave-app detection during focus: the timer pauses and a notification asks you to come back
- Statistics with a 7-day line chart and per-day history

### Class Timetable
- Weekly grid on a 24-hour timeline with a live "now" indicator
- 15-minute granularity for course start time and duration
- Multi-weekday course creation, custom card colors, week range support
- Long-press quick edit to move a course with conflict detection
- Per-course reminders delivered as local notifications at 08:00 on the due date

### General
- Meal-time expense reminders at two user-configured times per day
- 8 built-in color themes plus a custom palette editor (12 semantic colors, HSV picker with hex input)
- Adaptive layout: bottom navigation on phones, navigation rail on tablets and desktop-width screens
- High refresh rate support (up to 120 fps where available)
- All data stored locally in SQLite (Drift); tables carry `updated_at`, `device_id`, and `is_deleted` columns so future cross-device sync can be added without breaking changes

## Platforms

- Android (primary; phones and tablets)

Windows and Linux targets are included in the repository but not yet validated.

## Building

Requirements:

- Flutter 3.47.1 (stable)
- Android SDK with platform 36 and NDK 28.2
- JDK 17

```bash
flutter pub get
flutter build apk --release --split-per-abi
```

The resulting APKs are written to `build/app/outputs/flutter-apk/`. Install the one matching your device ABI (usually `app-arm64-v8a-release.apk`).

## Project Layout

```
lib/
  app/            app shell and adaptive navigation
  core/
    theme/        oklch-based theme engine, 8 presets, custom palettes
    db/           Drift schema, DAOs, providers
    icons/        curated icon catalog with keyword search
    notifications/ local notification service
    sync/         sync interface stub for future P2P support
  features/
    ledger/       expense tracking
    pomodoro/     focus timer
    timetable/    class schedule
    settings/     themes, reminders, data management
  shared/         shared widgets
```

## License

All rights reserved.
