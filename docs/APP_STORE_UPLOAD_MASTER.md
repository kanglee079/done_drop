# DoneDrop App Store Upload Master Doc

Last updated: 2026-04-23
Owner: DoneDrop release team
Scope: Android (Google Play) release readiness + current project status

## 1) Current snapshot (project + Play Console)

### Source project (local)

- `flutter analyze`: PASS (0 issues)
- `flutter test`: PASS (133/133)
- Release artifact ready: `build/app/outputs/bundle/release/app-release.aab` (~59 MB)
- Split release APKs ready:
  - `app-arm64-v8a-release.apk` (~30 MB)
  - `app-armeabi-v7a-release.apk` (~27 MB)
  - `app-x86_64-release.apk` (~33 MB)
- Note: `app-debug.apk` is ~157 MB and is not for store upload.

### Play Console (checked on Firefox)

App: `com.donedrop.app`

Observed in **Publishing overview**:

- `Send app for review`: disabled
- Pending/unsubmitted items include:
  - Content Rating: submit questionnaire
  - Target audience and content: update pending
  - Ads declaration: update pending
  - Data safety: questionnaire incomplete
  - App category: selection pending (Productivity)
- Test track flow still incomplete:
  - Internal/Closed testing still asks for tester setup/release confirmation steps
- Production access blocked:
  - currently `0 testers opted-in`
  - must have `>=12 testers` continuously opted-in for `14 days`

## 2) GO / NO-GO decision now

- GO for internal testing: **YES**
- GO for closed testing rollout: **YES**
- GO for production publish to everyone: **NO-GO (policy gating)**

Reason of NO-GO for production: Play policy gate on closed test requirement (12 testers / 14 days) and pending app content declarations.

## 3) What is already prepared

- Package name approved and usable: `com.donedrop.app`
- App icon, feature graphic, screenshots prepared in `store_assets/google_play/`
- Legal pages available:
  - Privacy: `https://donedrop-1d764.web.app/legal/privacy.html`
  - Terms: `https://donedrop-1d764.web.app/legal/terms.html`
- Upload signing is configured in Android Gradle via `android/key.properties`
- Fastlane pipelines present:
  - `fastlane upload_to_play`
  - `fastlane create_products`
  - `fastlane upload_store_listing`
  - `fastlane full_release`

## 4) Remaining actions to ship correctly

### A. Play Console mandatory declarations

Complete in Play Console:

1. Content Rating questionnaire
2. Target audience and content
3. Data safety questionnaire
4. Ads declaration
5. Confirm app category/contact if still pending

### B. Testing tracks

1. Internal test:
   - add testers
   - upload/review release
2. Closed test:
   - add at least 12 testers
   - keep them opted-in for 14 continuous days

### C. Billing (subscription + IAP)

Products expected by app:

- `dd_premium_monthly` (subscription)
- `dd_premium_yearly` (subscription)
- `dd_premium_lifetime` (one-time)

Before production billing:

1. Create/activate all 3 products in Play Console
2. Add license testers
3. Install app from Play test track (not local debug install) and run purchase/restore tests end-to-end

## 5) Safe command sequence (from this repo)

```bash
cd /Users/xikang/dev/project/done_drop

# Quality gate
flutter analyze
flutter test

# Build release AAB
flutter build appbundle --release

# Upload to Play internal track (requires service account JSON)
fastlane upload_to_play
```

If service-account automation is not ready yet, upload the AAB manually in Play Console track UI.

## 6) Final pre-production gate checklist

Mark all as PASS before requesting production access:

- [ ] No crash/black-screen after relaunch on QA device
- [ ] Auth flow works (email + Google Sign-In)
- [ ] Buddy flows work: send request, accept request, chat open/send
- [ ] QR scan add-friend works on real device camera
- [ ] Feed/Buddy wall displays friend moments correctly
- [ ] Loading/error/success states are visible and non-blocking on critical actions
- [ ] Content Rating/Target audience/Data safety/Ads all completed
- [ ] Closed test has >=12 opted-in testers for >=14 days
- [ ] Billing products active and purchase/restore tested from Play install

## 7) Related docs

- `docs/PLAY_CONSOLE_SETUP.md`
- `docs/store_release_checklist.md`
- `docs/BILLING_SETUP.md`
- `docs/manual_qa_google_email_qr.md`
