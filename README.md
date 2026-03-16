# Flutter Web Walkthrough

A Flutter Web demo app for **version-based update detection** with a simple 3-page flow:

- Landing page
- Login page
- Dashboard page (counter + update prompts)

## Features

- Detects deployment changes via `web/version.json`
- Compares server hash with cached hash in local storage
- Checks for updates every **1 minute**
- Prompts user to update (`Update Now` / `Not Now`)
- Reloads page with cache-busting query when update is accepted
- Simple login flow and dashboard counter demo

## Core Business Logic

This project’s core business goal is **safe client update orchestration for Flutter Web**.

### Business Problem

When a new web build is deployed, users may still run old JS/assets in browser cache. This can cause:

- stale UI and behavior,
- mismatch between frontend and backend expectations,
- support issues from mixed app versions.

### Business Rules (Must Keep)

1. **Single source of version truth** is `version.json` at app root.
2. App compares **server hash** vs **cached hash** (not only semantic version string).
3. If hash changed:
  - on login page: reload immediately with cache-busting query,
  - on dashboard: show update prompt (`Update Now` / `Not Now`).
4. Accepting update clears cached version state and reloads app.
5. Build process must always regenerate `version`, `hash`, and `timestamp`.

### Operational Flow

1. Build script generates new `hash` and `timestamp`.
2. Server serves updated assets + updated `version.json`.
3. Client polling detects hash change.
4. UI triggers update UX.
5. Client reloads with query suffix (cache bust) and starts on latest bundle.

### If You Copy This to Another Repository

Keep these parts together:

- Routing flow in `main.dart` (`/`, `/login`, `/dashboard`)
- `VersionService` (`lib/services/version_service.dart`)
- Update UX in `login_page.dart` and `dashboard_page.dart`
- Build scripts that update `web/version.json` before build
- Deployment rule that serves `version.json` at web root with no stale caching

If any one of these is skipped, update detection can silently fail.

### Do / Don't (For Copying or Updating)

| Do | Don't |
|---|---|
| Keep `version.json` at the web root in deployed output. | Don't move `version.json` to another folder without updating `VersionService` URL logic. |
| Regenerate `hash` and `timestamp` on every release build. | Don't reuse old hash values across deployments. |
| Compare hashes to detect updates. | Don't rely only on semantic version labels for change detection. |
| Keep login + dashboard update flows aligned with service behavior. | Don't remove update handling from one page and keep it only on another without intent. |
| Use cache-busting reload when applying updates. | Don't use plain reload in cases where stale cached assets can persist. |
| Ensure IIS/server serves latest `version.json` (no stale cache). | Don't configure long-term caching for `version.json`. |
| Keep build scripts and runtime logic in sync. | Don't modify build output structure without checking runtime fetch path assumptions. |
| Test one full release cycle locally before production deploy. | Don't deploy update logic changes without verifying prompt/reload behavior end-to-end. |

## Current Route Flow

- `/` → `LandingPage`
- `/login` → `LoginPage`
- `/dashboard` → `DashboardPage`

`LoginPage` also performs an immediate version check on load and refreshes if a new version is detected.

## Version File Format

The app reads `version.json` from the app root:

```json
{
  "version": "1.0.5",
  "hash": "1.0.5-1773226631645",
  "timestamp": 1773226631645
}
```

## Prerequisites

- Flutter SDK (stable)
- Dart SDK (bundled with Flutter)
- Chrome (for local web run)

## Run Locally

```bash
flutter pub get
flutter run -d chrome
```

## Build for Web

### Windows

```powershell
.\build.ps1 -Version "1.0.0"
```

### Linux / macOS

```bash
chmod +x build.sh
./build.sh 1.0.0
```

Build output is generated in `build/web/`.

## What the Build Script Does

1. Generates a new timestamp
2. Creates `hash = <version>-<timestamp>`
3. Writes `web/version.json`
4. Runs Flutter web build
5. Copies `version.json` into `build/web/version.json`
6. Copies IIS config (`web.config` or minimal fallback when configured)

## IIS Deployment (Current Setup)

If deploying to IIS (example used in this repo setup):

- Site name: `flutter-web`
- App pool: `flutter-web`
- URL: `http://localhost:91`

Typical deployment flow:

```powershell
.\build.ps1 -Version "1.0.0"
# copy build/web/* to IIS physical path
```

## Project Structure

```text
flutter-web-walkthrough/
├── lib/
│   ├── main.dart
│   ├── pages/
│   │   ├── landing_page.dart
│   │   ├── login_page.dart
│   │   └── dashboard_page.dart
│   └── services/
│       └── version_service.dart
├── web/
│   ├── index.html
│   ├── manifest.json
│   ├── version.json
│   ├── web.config
│   └── web.config.minimal
├── build.ps1
├── build.sh
├── deploy-iis.ps1
├── fix-iis-500.ps1
└── pubspec.yaml
```

## Configuration Notes

- Version check interval is in `VersionService`:

```dart
static const Duration _checkInterval = Duration(minutes: 1);
```

- Update prompt behavior is implemented in:
  - `lib/pages/login_page.dart`
  - `lib/pages/dashboard_page.dart`

## Troubleshooting

- **Blank page on web**: ensure `web/index.html` uses `flutter_bootstrap.js`
- **Version parse errors**: validate `web/version.json` fields (`version`, `hash`, `timestamp`)
- **No update prompt**: ensure deployed `version.json` hash changes between releases

## Docs

- Product logic notes: `docs/logics.md`
