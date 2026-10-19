# Lab 1, Part 3 — Private Notes App

This folder contains both implementations from the Part 3 lab:

- `notes-app/` — Expo Router, React Native, TypeScript, and Appwrite.
- `notes_app/` — Flutter, Dart, and Appwrite.

Both apps support email/password registration and login, restore the current
session at startup, and let a user create/edit/delete notes. Notes are listed
according to Appwrite row permissions. Note privacy must be enabled in Appwrite;
client-side filtering alone is not an access-control boundary.

## Appwrite setup

1. Create an Appwrite project, a database, and a `notes` table (or use your
   existing table and set the IDs below to match).
2. Add string columns `title`, `content`, and `userId`. Make `title` required.
3. In the table permissions, grant **Create** to the **Users** role only.
   Enable **Row Security** and remove broad read, update, and delete grants.
   The app adds read/update/delete permissions for the owner of each new row.
4. Enable email/password authentication and register the app's platform in
   Appwrite. The platform ID must match the app's installed/built package ID.
5. Remove old test rows that do not have a `userId` or owner permissions.

Do not put an Appwrite API key in either mobile app. The endpoint, project,
database, table, and platform IDs are public client configuration, not secrets.

## Run the Expo app

In PowerShell:

```powershell
Set-Location .\notes-app
Copy-Item .env.example .env
```

Edit `.env` with your Appwrite endpoint and IDs. Set
`EXPO_PUBLIC_APPWRITE_PLATFORM` to the platform ID registered for the app; for
Expo Go this may be `host.exp.exponent`.

```powershell
npm ci
npm run lint
npx expo start
```

## Run the Flutter app

In PowerShell:

```powershell
Set-Location .\notes_app
Copy-Item env.example.json env.json
```

Edit `env.json` with the same Appwrite endpoint and IDs. This file is ignored
by Git.

```powershell
flutter pub get
flutter analyze
flutter run --dart-define-from-file=env.json
```

## Before pushing

- Confirm both static checks pass (`npm run lint` and `flutter analyze`).
- Test registration, sign-in, sign-out, and session restoration.
- Create a note with two separate accounts and verify each account sees only
  its own notes. Confirm the row permissions in Appwrite as well.
- Keep `.env`, `env.json`, signing keys, and other local credentials out of Git.
