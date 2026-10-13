# Part 2: Notes app with Appwrite

This folder contains the second version of the Notes app, updated to persist data in an Appwrite database instead of local memory.

## Apps included

- `notes-app` — Expo / React Native
- `notes_app` — Flutter

## What changed from Part 1

- Added Appwrite configuration
- Stored notes in a real database table
- Loaded notes from Appwrite on startup
- Created, updated, and deleted rows from both app versions

## Environment setup

Create an Appwrite project, database, and `notes` table with `title` and
`content` string columns. Enable row create, read, update, and delete
permissions for the role used by your app.

Use your own Appwrite values. The committed example files contain placeholders;
the local files with actual project settings are intentionally not included.

### Expo / React Native

- Copy `.env.example` to `.env` and fill in the `EXPO_PUBLIC_APPWRITE_*` values.
- Install dependencies with `npm install`.
- Start Expo with `npx expo start`.

### Flutter

- Copy `env.example.json` to `env.json` and fill in the `APPWRITE_*` values.
- Fetch packages with `flutter pub get`.
- Run with `flutter run --dart-define-from-file=env.json`.

## Result

The app reads and writes real Appwrite rows, so notes remain available after closing and reopening the application.
