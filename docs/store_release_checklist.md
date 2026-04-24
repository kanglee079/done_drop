# Store Release Checklist

Last updated: April 23, 2026

## Current Status

| Item | Status | Notes |
|------|--------|-------|
| Package name verified | ✅ PASS | `com.donedrop.app` verified |
| Release AAB built | ✅ PASS | 62.4MB at `build/app/outputs/bundle/release/app-release.aab` |
| Signed APK (split ABI) | ✅ PASS | `arm64-v8a` 31.9MB, `armeabi-v7a` 28.4MB |
| Release signing key | ✅ PASS | `upload-keystore.jks` configured |
| Legal pages deployed | ✅ PASS | https://donedrop-1d764.web.app/legal/ |
| Store assets ready | ✅ PASS | Icon, feature graphic, 6 phone screenshots saved in Play listing |
| Relaunch black-screen regression | ✅ PASS | Root cause found: QA bootstrap build was installed; main build restored and relaunch retested |
| Flutter analyze | ✅ PASS | No issues found |
| Flutter test | ✅ PASS | 133/133 tests passing |
| Fastlane setup | ✅ PASS | `fastlane/` directory ready |
| Service account for API | ❌ PENDING | Need JSON key from Play Console |
| Play Console - Content Rating | ❌ MANUAL | Browser required |
| Play Console - Data Safety | ❌ MANUAL | Browser required |
| Play Console - Ads declaration | ❌ MANUAL | Browser required |
| Play Console - Upload AAB | ⏳ READY | Just needs service account |
| Play Console - Create IAP products | ⏳ READY | Browser or fastlane |
| Play Console - Internal testing | ⏳ READY | Browser or fastlane |

## Quick Start (After Service Account Setup)

```bash
cd /Users/xikang/dev/project/done_drop

# 1. Save JSON key as: fastlane/donedrop-service-account.json
# 2. Enable API: https://console.cloud.google.com/apis/library/androidpublisher.googleapis.com

# 3. Upload to internal testing
fastlane upload_to_play

# 4. Create IAP products
fastlane create_products
```

See `docs/PLAY_CONSOLE_SETUP.md` for detailed instructions.

## Required Manual Actions (Browser Only)

These must be done in Play Console UI:

1. **Content Rating** → Answer questionnaire (Productivity app)
2. **Data Safety** → Complete form using `store_assets/google_play/listing_copy.md`
3. **Ads** → Declare "No ads"
4. **Internal Testing** → Add testers, verify AAB uploaded
5. **Production rollout** → After internal testing passes

## Required Before Publishing

1. Create service account + download JSON key
2. Enable Play Developer API in Cloud Console
3. Upload AAB to internal testing track
4. Complete Content Rating questionnaire
5. Complete Data Safety form
6. Declare ads = No
7. Test purchase flow with license tester
8. Promote from internal testing to production

## Files Reference

| Purpose | Path |
|---------|------|
| AAB | `build/app/outputs/bundle/release/app-release.aab` |
| App icon | `store_assets/google_play/app_icon_512.png` |
| Feature graphic | `store_assets/google_play/feature_graphic_1024x500.png` |
| Screenshots | `store_assets/google_play/screenshots_phone/*.png` |
| Listing copy | `store_assets/google_play/listing_copy.md` |
| Privacy policy | `web/legal/privacy.html` |
| Terms | `web/legal/terms.html` |
| Fastlane | `fastlane/` |
| Billing setup | `docs/BILLING_SETUP.md` |
