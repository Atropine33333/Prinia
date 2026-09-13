# Prinia

[简体中文](README_zh.md)

A local-first productivity app for students. Prinia combines an expense tracker, a Pomodoro timer, and a class timetable in a single offline Android application, with optional Bluetooth device-to-device synchronization.

## Features

### Expense Tracker
- Income and expense records with 7 preset categories plus user-defined tags
- Monthly summary with balance, daily expense bar chart (0-300 coordinate system), and category pie chart
- Tap a bar in the chart to inspect a single day; the pie chart follows the selection
- Tap a pie slice or legend entry to highlight that category and show its exact amount
- Custom tags with searchable icon picker and fallback mascot icon
- Soft delete with confirmation

### Pomodoro Timer
- Configurable focus and rest durations (persisted across restarts)
- Continuous focus/rest cycling with completion alerts (vibration and sound)
- Leave-app detection during focus: the timer pauses and a notification asks you to come back
- Statistics with a 7-day line chart and per-day history

### Class Timetable
- Weekly grid from 07:00 laid out by the 12-period schedule with a live "now" indicator
- 15-minute granularity for course start time and duration
- Multi-weekday course creation, custom card colors, week range and odd/even week support, adjustable card font size
- Built-in 12-period daily schedule (08:00–22:20); tap the time column to switch between clock times and period numbers
- Custom period schedules (Settings → Timetable): add or remove periods and adjust their times; stored in `app_meta` and synced across devices
- Import schedules from the unified cross-school JSON format (Settings → Data); imported rows join the normal sync flow
- Long-press quick edit to move a course with conflict detection
- Per-course reminders delivered as local notifications at 08:00 on the due date

### Multi-Device Sync (Android to Android)
- Bluetooth RFCOMM transport: no network, no hotspot, works on isolated campus networks
- CRDT (LWW per row) merge: edits on any device converge automatically
- Incremental transfer with per-peer cursors; first session is a full sync
- Edits are pushed automatically (debounced) while the peer app is running
- Selectable sync peers: pick which paired devices participate

### General
- Meal-time expense reminders at two user-configured times per day
- 8 built-in color themes plus a custom palette editor (12 semantic colors, HSV picker with hex input)
- Adaptive layout: bottom navigation on phones, navigation rail on tablets
- High refresh rate support (up to 120 fps where available)
- All data stored locally in SQLite (Drift); rows carry `uuid`, `updated_at`, `device_id`, and `is_deleted` columns for CRDT merge

## Platforms

- Android (phones and tablets), API level supported by Flutter 3.47
- **Windows: not supported and untested.** The Windows runner files are present and CI may build them, but no testing or support is provided.

## Building

Requirements:

- Flutter 3.47.1 (stable)
- Android SDK with platform 36, build-tools 34+, NDK 28.2, and CMake 3.22.1
- JDK 17

```bash
flutter pub get
flutter build apk --release --split-per-abi
```

The resulting APKs are written to `build/app/outputs/flutter-apk/`. Install the one matching your device ABI (usually `app-arm64-v8a-release.apk`).

Releases are built automatically by GitHub Actions when a `v*` tag is pushed.

## Project Layout

```
lib/
  app/            app shell and adaptive navigation
  core/
    theme/        oklch-based theme engine, 8 presets, custom palettes
    db/           Drift schema, DAOs, providers
    icons/        curated icon catalog with keyword search
    notifications/ local notification service
    sync/         CRDT sync: protocol, engine, Bluetooth transport
  features/
    ledger/       expense tracking
    pomodoro/     focus timer
    timetable/    class schedule
    settings/     themes, sync, reminders, data management
  shared/         shared widgets
```

## License

Licensed under the [Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0).
