# Local Media Backend

This project can now run media storage outside Firebase Storage by pointing the
app at a local HTTP media backend.

## What stays on Firebase

- Firebase Auth
- Cloud Firestore
- Analytics / Crashlytics / App Check

## What moves off Firebase

- Avatar uploads
- Moment original image uploads
- Moment thumbnail uploads
- Media deletes

## Start the backend

From the project root:

```bash
python3 scripts/media_backend_server.py
```

Default server:

- Base URL: `http://127.0.0.1:8081`
- Storage root: `.media_backend_storage/`

Health check:

```bash
curl http://127.0.0.1:8081/health
```

## Run the Flutter app against the backend

For iOS simulator:

```bash
flutter run \
  --dart-define=DD_MEDIA_BACKEND_URL=http://127.0.0.1:8081
```

For a real iPhone on the same day, expose the local backend with a public HTTPS
tunnel and use that URL instead:

```bash
npx --yes localtunnel --port 8081
flutter run \
  --dart-define=DD_MEDIA_BACKEND_URL=https://your-subdomain.loca.lt
```

For release builds:

```bash
flutter build ios \
  --dart-define=DD_MEDIA_BACKEND_URL=http://127.0.0.1:8081
```

## Notes

- The app still keeps Firebase Storage code as fallback.
- If `DD_MEDIA_BACKEND_URL` is set, media goes to the local backend instead.
- Files are served publicly from the local machine, which is ideal for fast local
  development and simulator testing.
- For a real production backend later, we can swap the same HTTP contract to an
  external server or object store without changing the app flow again.
