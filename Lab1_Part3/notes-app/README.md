# Notes App (Expo)

Expo Router and React Native implementation of Lab 1, Part 3. The app uses
Appwrite email/password authentication and row-level permissions so each
signed-in user can access only their own notes.

## Configure

Create `.env` from `.env.example` and set:

- `EXPO_PUBLIC_APPWRITE_ENDPOINT`
- `EXPO_PUBLIC_APPWRITE_PROJECT_ID`
- `EXPO_PUBLIC_APPWRITE_PLATFORM`
- `EXPO_PUBLIC_APPWRITE_DATABASE_ID`
- `EXPO_PUBLIC_APPWRITE_TABLE_ID`

Register the matching platform ID in Appwrite. Do not place an Appwrite API key
in the client app. See the [Part 3 setup guide](../README.md) for the database
columns and row-security configuration.

## Run

```powershell
npm ci
npm run lint
npx expo start
```
