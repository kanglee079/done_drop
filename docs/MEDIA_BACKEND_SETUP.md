# Media Backend Setup

This project is ready for a faster "upload one original, generate thumbnails on Firebase" path.

## What the app supports

- Default mode: client uploads `original.jpg` and `thumb.jpg`.
- Backend mode: client uploads only `original.jpg`.
- The app then expects Firebase Resize Images to generate:
  - `original_280x420.jpg`
- While that thumbnail is still being generated, the UI falls back to the original download URL.

Enable backend mode with:

```bash
flutter run --dart-define=DD_USE_SERVER_THUMBNAILS=true
```

For release builds:

```bash
flutter build appbundle --dart-define=DD_USE_SERVER_THUMBNAILS=true
flutter build ipa --dart-define=DD_USE_SERVER_THUMBNAILS=true
```

## Firebase steps

1. Put the Firebase project on Blaze.
2. Install the official Firebase extension:
   - Resize Images
   - Source: https://extensions.dev/extensions/firebase/storage-resize-images
3. Point the extension at the same Storage bucket used by the app.
4. Configure one resized dimension:
   - `280x420`
5. Keep the original image.
6. Use JPEG output.

The app assumes Firebase names the generated file by suffixing the original file name with the resized dimensions, for example:

```text
moments/{userId}/{momentId}/original.jpg
moments/{userId}/{momentId}/original_280x420.jpg
```

## Why this is faster

- The client compresses only one image.
- Only one upload blocks the post flow.
- Thumbnail generation moves off-device and off the critical path.
- Feed/wall/recap can still render immediately by falling back to the original URL until the resized file appears.

## App Check

App Check is already activated in code.

- Debug Android uses the debug provider.
- Release Android uses Play Integrity.
- Debug Apple uses the debug provider.
- Release Apple uses App Attest with DeviceCheck fallback.

If debug uploads fail after enabling App Check enforcement, register the debug token shown by Firebase in the console.

## Deploy commands

Deploy rules and hosting:

```bash
firebase deploy --only firestore:rules,storage,hosting
```

## Notes

- The extension runs with admin privileges, so it can write generated resized files even though end-user Storage rules only allow the owner upload path.
- The app also deletes `original_280x420.jpg` when a moment is deleted.
- If you later change the resize dimensions, update the generated suffix expectation in:
  - `lib/core/services/media_service.dart`
  - `lib/firebase/repositories/moment_repository.dart`
