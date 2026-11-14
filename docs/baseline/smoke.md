# Phase 0 smoke-test baseline

Recorded: 2026-11-15 (Asia/Riyadh)

## Environment

- Flutter 3.47.1 (stable), Dart 3.13.1.
- Available targets: Windows desktop, Chrome, and Edge. No Android or iOS
  device/emulator was connected.
- Windows visual baseline was blocked: `flutter build windows` reported
  `Unable to find suitable Visual Studio toolchain.`
- Consequently, no runnable target was available for the interactive baseline
  or screenshots. This is an environment limitation, not an application
  regression.

## Automated checks

| Check | Result |
|---|---|
| `flutter analyze` | 16 pre-existing info-level issues; captured in `analyze.txt` |
| `flutter test` | Passed (1 sanity test) |

## Interactive smoke checklist

All checks below are pending a device/emulator with the required test accounts.
They are intentionally recorded as **not run**, rather than assumed to pass.

| ID | Area | Result | Notes |
|---|---|---|---|
| A1 | Startup | Not run | Requires a runnable target. |
| A2 | Email sign-in | Not run | Requires a runnable target and test credentials. |
| A3 | Sign-up & OAuth | Not run | Requires a runnable target and test accounts. |
| A4 | Feed | Not run | Requires a runnable target and seeded data. |
| A5 | Post interactions | Not run | Requires a runnable target and test accounts. |
| A6 | Create/edit/delete post | Not run | Requires a runnable target and test accounts. |
| A7 | Workshops | Not run | Requires a runnable target and seeded data. |
| A8 | Add workshop & dashboard | Not run | Requires a runnable target and test accounts. |
| A9 | Maintenance request | Not run | Requires two test accounts. |
| A10 | Chat | Not run | Requires two test accounts and two devices. |
| A11 | Notifications | Not run | Requires two test accounts and two devices. |
| A12 | Theme | Not run | Requires a runnable target. |
| A13 | Sign-out | Not run | Requires a runnable target and two test accounts. |
