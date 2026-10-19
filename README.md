# Mobile Labs

Course projects for cross-platform mobile app development.

## Part 1: Notes app

The [`Lab1_Part1`](./Lab1_Part1/) folder contains the same local Notes app in
two frameworks:

- **Expo / React Native** — [`notes-app`](./Lab1_Part1/notes-app/)
- **Flutter** — [`notes_app`](./Lab1_Part1/notes_app/)

Both versions support adding, editing, and deleting notes. Notes are held in
memory and reset to the sample notes when the app restarts; database storage
and authentication are outside Part 1.

### Run the Expo app

```powershell
cd Lab1_Part1/notes-app
npm install
npx expo start
```

### Run the Flutter app

```powershell
cd Lab1_Part1/notes_app
flutter pub get
flutter run
```

## Part 2: Notes app with Appwrite

The [`Lab1_Part 2`](./Lab1_Part%202/) folder contains the same Notes app with
persistent Appwrite storage:

- **Expo / React Native** — [`notes-app`](./Lab1_Part%202/notes-app/)
- **Flutter** — [`notes_app`](./Lab1_Part%202/notes_app/)

Both versions load notes from Appwrite and support creating, updating, and
deleting notes. Configure your own Appwrite project using the example
environment files in each app before running it.

## Part 3: Private Notes app with Appwrite authentication

The [`Lab1_Part3`](./Lab1_Part3/) folder builds on Part 2 with email/password
registration and sign-in, session restoration, private per-user notes, and an
empty state:

- **Expo / React Native** — [`notes-app`](./Lab1_Part3/notes-app/)
- **Flutter** — [`notes_app`](./Lab1_Part3/notes_app/)

### Appwrite setup

Follow the [Part 3 setup guide](./Lab1_Part3/README.md). In summary, configure
an Appwrite project with email/password authentication, a database table with
`title`, `content`, and `userId` columns, and row security. Grant the **Users**
role table-level **Create** permission; the app assigns each new note's owner
read, update, and delete permissions. Register the app platform in Appwrite.

### Run the Expo app

```powershell
cd Lab1_Part3/notes-app
Copy-Item .env.example .env
```

Set the Appwrite endpoint, project, platform, database, and table IDs in `.env`,
then run:

```powershell
npm ci
npx expo start
```

For Expo Go on a phone, scan the QR code while your phone and computer are on
the same network. Keep the Expo terminal running.

### Run the Flutter app

```powershell
cd Lab1_Part3/notes_app
Copy-Item env.example.json env.json
```

Set the Appwrite endpoint, project, database, and table IDs in `env.json`, then
run:

```powershell
flutter pub get
flutter run --dart-define-from-file=env.json
```

The local `.env` and `env.json` files contain project-specific configuration
and should not be committed. Never put an Appwrite API key in a client app.
