// src/app/_layout.tsx
import { Stack } from 'expo-router';
import * as SplashScreen from 'expo-splash-screen';
import { useEffect } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';

import { AuthProvider, useAuth } from '../context/AuthContext';

// Keep the splash screen visible until we know if there is a session
SplashScreen.preventAutoHideAsync();

function RootNavigator() {
  const { user, initializing, initializationError, retryInitialization } = useAuth();

  useEffect(() => {
    if (!initializing) SplashScreen.hide();
  }, [initializing]);

  if (initializing) return null;

  if (initializationError) {
    return (
      <View style={styles.errorContainer}>
        <Text style={styles.errorTitle}>Could not restore your session</Text>
        <Text style={styles.errorText}>{initializationError}</Text>
        <Pressable onPress={() => void retryInitialization()} style={styles.retryButton}>
          <Text style={styles.retryText}>Retry</Text>
        </Pressable>
      </View>
    );
  }

  return (
    <Stack>
      <Stack.Protected guard={user !== null}>
        <Stack.Screen name="index" options={{ title: 'Notes App' }} />
        <Stack.Screen name="notes" options={{ title: 'My Notes' }} />
      </Stack.Protected>

      <Stack.Protected guard={user === null}>
        <Stack.Screen name="login" options={{ title: 'Sign in' }} />
      </Stack.Protected>
    </Stack>
  );
}

export default function RootLayout() {
  return (
    <AuthProvider>
      <RootNavigator />
    </AuthProvider>
  );
}

const styles = StyleSheet.create({
  errorContainer: { flex: 1, justifyContent: 'center', alignItems: 'center', gap: 12, padding: 24 },
  errorTitle: { fontSize: 20, fontWeight: 'bold' },
  errorText: { color: '#c0392b', textAlign: 'center' },
  retryButton: { backgroundColor: '#208AEF', borderRadius: 8, paddingHorizontal: 20, paddingVertical: 12 },
  retryText: { color: '#fff', fontWeight: 'bold' },
});