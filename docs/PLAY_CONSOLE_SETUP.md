# Play Console Setup Guide for DoneDrop

## Status: Ready to Deploy

AAB built: `build/app/outputs/bundle/release/app-release.aab` (62.4MB)
Signed APKs for verification: `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (31.9MB), `app-armeabi-v7a-release.apk` (28.4MB)
Assets ready: icon, feature graphic, 6 screenshots
Legal pages deployed: https://donedrop-1d764.web.app/legal/

## One-time Setup: Google Play Developer API

### Step 1: Create Service Account

1. Open Play Console: https://play.google.com/console
2. Go to **Users & permissions** → **Service accounts**
3. Click **Invite new users**
4. Click **Create service account**
5. Name it: `DoneDrop CI/CD`
6. Click **Create Google Cloud service account** (opens new tab)
7. Leave defaults, click **Done**
8. Back in Play Console, find the new service account
9. Click **Grant access** next to it
10. Select these permissions:
    - `Release manager`
    - `View financial data`
    - `Manage product holdings`

### Step 2: Create JSON Key

1. Go to **Users & permissions** → **Service accounts**
2. Click on your new service account
3. Click **Keys** tab → **Add key** → **Create new key**
4. Choose **JSON** → **Create**
5. Save the downloaded file as `fastlane/donedrop-service-account.json`

### Step 3: Enable Play Developer API

1. Go to https://console.cloud.google.com/apis/library/androidpublisher.googleapis.com
2. Select your Cloud project (same one used in Step 1)
3. Click **Enable**

### Step 4: Verify Setup

```bash
cd /Users/xikang/dev/project/done_drop
fastlane run validate_play_store_auth_json json_key_file:fastlane/donedrop-service-account.json
```

## Upload AAB

```bash
cd /Users/xikang/dev/project/done_drop

# Build new AAB
flutter build appbundle --release

# Upload to internal testing
fastlane upload_to_play

# Or full release (includes products)
fastlane full_release
```

## QA Build Safety Note

If the app ever opens to a black debug screen showing `Ready: ...`, that device is running the QA bootstrap target (`lib/qa_auth_bootstrap.dart`) instead of the real app entrypoint.

Install the normal app target again:

```bash
flutter run -d QV7034R71H -t lib/main.dart --debug --no-resident
```

## Create IAP Products Manually (if needed)

1. Play Console → **Monetize** → **Products** → **Subscriptions**
2. Create `dd_premium_monthly`:
   - Product ID: `dd_premium_monthly`
   - Billing type: Subscription
   - Billing period: Monthly
   - Price: $1.99 USD
3. Create `dd_premium_yearly`:
   - Product ID: `dd_premium_yearly`
   - Billing period: Annual
   - Price: $9.99 USD
4. **Products** → **In-app products** → Create `dd_premium_lifetime`:
   - Product ID: `dd_premium_lifetime`
   - Price: $29.99 USD

## Remaining Manual Steps (Play Console UI)

These require browser access:

1. **Content Rating** → Fill out questionnaire (Productivity category)
2. **Data Safety** → Complete the form using `listing_copy.md` as reference
3. **Ads** → Declare "No, this app does not contain ads"
4. **App access** → Already done with QA test account
5. **Internal testing** → Add testers, upload AAB
6. **Production** → After internal testing, promote to production

## Test Purchase (License Testing)

After creating products:
1. Add tester email in **License testing**
2. On device, add tester Google account
3. Clear Play Store cache
4. Test purchase flow in app

## Support Email

Use `support@donedrop.app` consistently in Play Console and store metadata.
