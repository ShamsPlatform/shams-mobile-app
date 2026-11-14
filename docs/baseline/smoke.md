# Phase 0 smoke-test baseline

Recorded: 2026-11-15 (Asia/Riyadh)

## Environment

- Flutter 3.47.1 (stable), Dart 3.13.1.
- Available targets: Moto G 5G (2024) on Android 14 (API 34), Windows
  desktop, Chrome, and Edge.
- The debug APK built successfully and was installed on the Moto G through
  ADB after USB debugging was authorized.
- Windows visual baseline was blocked: `flutter build windows` reported
  `Unable to find suitable Visual Studio toolchain.`
- The Android target replaces the unavailable Windows target for the visual
  baseline. Screenshots are in `screenshots/`.

## Automated checks

| Check | Result |
|---|---|
| `flutter analyze` | 16 pre-existing info-level issues; captured in `analyze.txt` |
| `flutter test` | Passed (1 sanity test) |

## Interactive smoke checklist

Read-only navigation was run on the connected device. Flows that mutate backend
data, send messages, or require another account are intentionally recorded as
**not run** because no disposable multi-account test setup was provided.

| ID | Area | Result | Notes |
|---|---|---|---|
| A1 | Startup | Partial | Cold start of the existing signed-in session reaches Home; logged-out startup was not exercised. |
| A2 | Email sign-in | Not run | Requires test credentials and intentional auth-state changes. |
| A3 | Sign-up & OAuth | Not run | Requires disposable test accounts. |
| A4 | Feed | Partial | Home loads in both themes and shows its expected empty state; no seeded posts were available. |
| A5 | Post interactions | Not run | Requires a runnable target and test accounts. |
| A6 | Create/edit/delete post | Not run | Requires a runnable target and test accounts. |
| A7 | Workshops | Partial | Directory opens and shows its expected empty state; city filter/search/follow were not exercised. |
| A8 | Add workshop & dashboard | Not run | Requires a runnable target and test accounts. |
| A9 | Maintenance request | Not run | Requires two test accounts. |
| A10 | Chat | Partial | Conversation list opens and shows its expected empty state; messaging and realtime need two accounts. |
| A11 | Notifications | Partial | Notifications screen opens and shows its expected empty state; realtime needs two accounts. |
| A12 | Theme | Passed | Toggled to light, cold-restarted to confirm persistence, then restored the original dark preference. |
| A13 | Sign-out | Not run | Requires a runnable target and two test accounts. |
