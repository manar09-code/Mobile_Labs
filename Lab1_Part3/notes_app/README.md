# Notes App (Flutter)

Flutter implementation of Lab 1, Part 3. It uses Appwrite email/password
authentication and row-level permissions so each signed-in user can access
only their own notes.

## Configure

Copy `env.example.json` to `env.json` and set `APPWRITE_ENDPOINT`,
`APPWRITE_PROJECT_ID`, `APPWRITE_DATABASE_ID`, and `APPWRITE_TABLE_ID`.
`env.json` is ignored by Git. Do not place an Appwrite API key in the app.
See the [Part 3 setup guide](../README.md) for the database columns and
row-security configuration.

## Run

```powershell
flutter pub get
flutter analyze
flutter run --dart-define-from-file=env.json
```
