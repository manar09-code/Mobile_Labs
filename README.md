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
