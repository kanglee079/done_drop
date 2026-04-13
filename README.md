# DoneDrop

> **Discipline-first. Private accountability. Proof of completion.**

DoneDrop là app kỷ luật cá nhân. Người dùng tạo hoạt động/routine,
được nhắc nhở để thực hiện, hoàn thành xong thì ghi nhận completion log,
có thể chụp ảnh làm proof moment, rồi chia sẻ riêng tư với bạn bè đã kết bạn.

**DoneDrop KHÔNG PHẢI:**
- Reflection diary
- Circle-first social app
- Instagram clone
- Generic todo app

## Tech Stack

| Category | Technology |
|----------|-----------|
| Framework | Flutter 3.x |
| State Management | GetX |
| Routing | GetX Navigation |
| Backend | Firebase (Auth, Firestore, Storage, Crashlytics) |
| Subscriptions | RevenueCat |
| Notifications | flutter_local_notifications |
| Widgets | home_widget |

## Project Structure

```
lib/
├── main.dart                    # Entry point
├── app/
│   ├── app.dart                # DoneDropApp root widget
│   ├── routes/                 # GetX route definitions
│   ├── presentation/           # Screens
│   │   ├── splash/
│   │   ├── onboarding/
│   │   ├── auth/
│   │   ├── home/
│   │   ├── capture/
│   │   ├── feed/
│   │   ├── memory_wall/
│   │   ├── recap/
│   │   ├── settings/
│   │   ├── premium/
│   │   └── report/
│   └── core/
│       └── widgets/            # Shared UI components
├── core/
│   ├── constants/              # App constants
│   ├── errors/                 # Failure types, Result
│   ├── models/                 # Domain models
│   ├── services/               # Analytics, Storage, Notifications
│   └── theme/                  # Colors, Typography, Sizes, Theme
└── firebase/
    ├── firebase_setup.dart      # Firebase initialization
    └── repositories/           # Firestore data access
```

## Getting Started

### Prerequisites

- Flutter SDK >= 3.10
- Dart SDK >= 3.10
- Xcode (iOS development)
- Android Studio (Android development)

### 1. Clone & Install

```bash
flutter pub get
```

### 2. Download Fonts

Download Google Fonts and place TTF files in `assets/fonts/`:

- Newsreader (Regular, Italic, Bold, Bold Italic)
- Manrope (Regular, Bold)

Then update `pubspec.yaml` to reference them.

### 3. Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add iOS and Android apps
3. Download config files:
   - `GoogleService-Info.plist` → iOS
   - `google-services.json` → Android
4. Enable services:
   - Authentication (Google Sign-In, Apple Sign In)
   - Firestore Database
   - Storage
   - Crashlytics
5. Deploy security rules from `firestore.rules` and `storage.rules`
6. Update `lib/firebase/firebase_setup.dart` with your Firebase config

### 4. RevenueCat Setup (Phase 7)

1. Create a RevenueCat project
2. Configure App Store Connect (iOS) and Play Console (Android)
3. Add your API keys to the app

### 5. Build

```bash
# iOS
flutter build ios --simulator

# Android
flutter build apk --debug
```

## Design System

### Colors

- **Primary**: `#884532` (warm terracotta)
- **Surface**: `#FAF9F6` (warm cream)
- **Tertiary Fixed**: `#D2E7DC` (mint — for date chips)

### Typography

- **Headlines**: Newsreader (serif) — editorial, warm
- **Body/Labels**: Manrope (sans-serif) — clean, readable

### Key Principles

- No divider lines between sections
- Surface color shifts define boundaries
- Glassmorphism for floating headers/nav
- Primary gradient for CTAs
- Warm shadows (outline color tint, not black)
- 8pt grid spacing

## Sprint Recovery Plan

**Product Direction:** DoneDrop is discipline-first, private-friend, proof-of-completion.
Not a reflection diary, not a circle-first social app, not an Instagram clone.

| Sprint | Focus |
|--------|-------|
| Sprint 1 | Relock direction, infrastructure, media pipeline |
| Sprint 2 | Discipline engine, friend model, offline-first |
| Sprint 3 | UI/UX polish, responsive, beta hardening |

## License

Private — All rights reserved.
