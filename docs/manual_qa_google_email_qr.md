# Manual QA - Google, Email, QR

Use this checklist before a release candidate is marked ready.

## Current status (2026-04-23)

- `PASS` Email login on physical Samsung with manual form input.
  - QA account: `1@1.io`
  - Result: Sign In -> Initial Setup, no blank stall, session restored after force-close.
- `PASS` Relaunch black-screen investigation.
  - Root cause: device had a debug build launched with `lib/qa_auth_bootstrap.dart` (screen showed `Ready: ...`).
  - Fix: reinstall and relaunch `lib/main.dart` build; startup now returns to normal onboarding/home flow.
- `PASS` Google Sign-In Android app-side flow up to chooser and cancel handling.
  - Result: chooser opens, cancel returns to Sign In with readable error.
- `BLOCKER` Google Sign-In Android final success path on this device account.
  - Reason: selected Google account triggers Google re-auth (`Verify it's you`) in `accounts.google.com`, which requires entering the account password. This is not an in-app crash, but the flow cannot be completed automatically without the account password.
- `BLOCKER` Real QR camera scan manual confirmation.
  - Reason: scan logic is covered by automated tests and buddy send/accept was already validated manually, but camera-to-screen/two-device scanning still needs a final physical pass.

QA references:
- Buddy code for `q1@dd.io`: `59LRE5`
- Buddy code for `1@1.io`: `8WLXHE`

## Google Sign-In (Android)

- [x] Start from a signed-out state on a physical Android device.
- [x] Tap `Continue with Google`.
- [x] Verify the Google account chooser opens without a blank screen or stuck loader.
- [x] Cancel once and confirm the app returns to Sign In with a clear message.
- [ ] Try again, choose a real test account, and confirm the app reaches Initial Setup or Home.
- [ ] Force-close and reopen the app. Confirm the signed-in session is restored.

Pass criteria:
- No `DEVELOPER_ERROR` or silent failure in UI.
- Loading state stays visible until the next screen is ready.

## Email Login

- [x] Create or reuse a QA email/password account.
- [x] Sign in from the real Sign In form.
- [x] Confirm the loading overlay stays on until Initial Setup or Home is visible.
- [x] Enter a wrong password once and verify the inline error is clear and actionable.
- [x] Retry with the correct password and confirm the error clears as soon as the user edits the field.
- [x] Force-close and reopen the app. Confirm the session is restored.

Pass criteria:
- No blank gap between loading and navigation.
- Wrong-credential, network, and provider-disabled states show readable copy.

## Real QR Buddy Scan

- [ ] Device A: open `My Code`.
- [ ] Device B: open `Scan`.
- [ ] Scan Device A's live QR code from the camera, not a copied string.
- [x] Confirm Device B routes to `Add Buddy` and auto-sends the request.
- [x] Confirm Device A receives the incoming request in `Buddy -> Requests`.
- [x] Tap accept on Device A and confirm both devices show the friendship in `Buddy Crew`.
- [x] Open each buddy wall and verify navigation works without restart.

Pass criteria:
- Request send, accept, and crew refresh happen without manual reload.
- Invalid QR codes show a clear scanner error instead of failing silently.

## Current known release gate

- Google Android success path still needs one manual pass on a device/account that does not force Google password re-auth.
- Real QR camera scan still needs one final physical confirmation on a fresh build.
