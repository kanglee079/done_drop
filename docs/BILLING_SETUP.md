# DoneDrop Billing Setup

This app now expects one shared Premium entitlement backed by:

- `dd_premium_monthly` — auto-renewable monthly subscription
- `dd_premium_yearly` — auto-renewable yearly subscription
- `dd_premium_lifetime` — one-time lifetime unlock

These default IDs are wired directly into the app. If the store uses different IDs, override them with `--dart-define`:

```bash
flutter run \
  --dart-define=DD_IAP_PREMIUM_MONTHLY=your.monthly.id \
  --dart-define=DD_IAP_PREMIUM_YEARLY=your.yearly.id \
  --dart-define=DD_IAP_PREMIUM_LIFETIME=your.lifetime.id
```

Platform-specific overrides are also supported:

```bash
--dart-define=DD_IAP_ANDROID_PREMIUM_MONTHLY=...
--dart-define=DD_IAP_ANDROID_PREMIUM_YEARLY=...
--dart-define=DD_IAP_ANDROID_PREMIUM_LIFETIME=...
--dart-define=DD_IAP_IOS_PREMIUM_MONTHLY=...
--dart-define=DD_IAP_IOS_PREMIUM_YEARLY=...
--dart-define=DD_IAP_IOS_PREMIUM_LIFETIME=...
```

If billing is not ready to be exposed in a release yet, keep Premium hidden from
settings by default and opt into the preview UI only for internal builds:

```bash
flutter run --dart-define=DD_SHOW_PREMIUM_PREVIEW=true
```

## Product model

- Monthly and yearly both unlock the same Premium entitlement.
- Lifetime is a one-time purchase that unlocks the same entitlement without renewal.
- Premium currently unlocks one live feature in the app:
  - Unlimited buddies beyond the free 5-buddy cap.
- When the store catalog is not live yet, the app now keeps Premium entry points
  hidden unless `DD_SHOW_PREMIUM_PREVIEW=true` is supplied.

## Google Play Console

Create these products under package `com.donedrop.app`:

1. Subscription: `dd_premium_monthly`
2. Subscription: `dd_premium_yearly`
3. One-time product: `dd_premium_lifetime`

Recommended checklist:

1. Keep monthly and yearly in the same logical Premium family for upgrade/downgrade testing.
2. Activate the products and publish them to an internal testing track.
3. Add the tester Google accounts both to:
   - the internal testing track
   - license testing for Play billing
4. Install the app from the Play internal test listing before testing purchases.

## App Store Connect

Create these products under the iOS app:

1. Auto-renewable subscription: `dd_premium_monthly`
2. Auto-renewable subscription: `dd_premium_yearly`
3. Non-consumable: `dd_premium_lifetime`

Recommended checklist:

1. Put the two subscriptions in the same subscription group.
2. Create a Sandbox Apple Account for purchase testing.
3. Confirm the bundle identifier used by the build matches the App Store Connect app.

## Manual QA

Android:

1. Install from the Play internal test listing.
2. Open Premium screen and confirm all 3 products load with localized prices.
3. Buy monthly, verify the app unlocks unlimited buddies.
4. Use `Manage subscription` and confirm it opens the Play subscription management page.
5. Use `Restore` on a fresh install signed into the same tester account.
6. Switch from monthly to yearly and confirm Premium remains active.
7. Buy lifetime on a clean tester state and confirm no renewal messaging remains.

iOS:

1. Sign into the sandbox tester account.
2. Open Premium screen and confirm all 3 products load.
3. Buy monthly or yearly, then restore on a second install.
4. Buy lifetime on a clean tester state and confirm restore works.

## Known limitation

The current implementation syncs entitlement to Firestore from the device. It does not include a server-side receipt validation service yet. For stronger fraud resistance and cleaner cross-account entitlement policy, add server verification later.
