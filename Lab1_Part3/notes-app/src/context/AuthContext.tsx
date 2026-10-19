import { createContext, useCallback, useContext, useEffect, useMemo, useState, type ReactNode } from 'react';

import { errorMessage } from '../lib/errors';
import * as auth from '../services/auth';

type AuthState = {
  user: auth.User | null;
  initializing: boolean;
  initializationError: string | null;
  retryInitialization: () => Promise<void>;
  signIn: (email: string, password: string) => Promise<void>;
  signUp: (name: string, email: string, password: string) => Promise<void>;
  signOut: () => Promise<void>;
};

const AuthContext = createContext<AuthState | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<auth.User | null>(null);
  const [initializing, setInitializing] = useState(true);
  const [initializationError, setInitializationError] = useState<string | null>(null);

  useEffect(() => {
    let active = true;

    void auth
      .getCurrentUser()
      .then((currentUser) => {
        if (active) setUser(currentUser);
      })
      .catch((error: unknown) => {
        if (active) setInitializationError(errorMessage(error));
      })
      .finally(() => {
        if (active) setInitializing(false);
      });

    return () => {
      active = false;
    };
  }, []);

  const retryInitialization = useCallback(async () => {
    setInitializing(true);
    setInitializationError(null);
    try {
      setUser(await auth.getCurrentUser());
    } catch (error) {
      setInitializationError(errorMessage(error));
    } finally {
      setInitializing(false);
    }
  }, []);

  const value = useMemo<AuthState>(
    () => ({
      user,
      initializing,
      initializationError,
      retryInitialization,
      signIn: async (email, password) => setUser(await auth.signIn(email, password)),
      signUp: async (name, email, password) => setUser(await auth.signUp(name, email, password)),
      signOut: async () => {
        await auth.signOut();
        setUser(null);
      },
    }),
    [user, initializing, initializationError, retryInitialization],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth(): AuthState {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth must be used inside <AuthProvider>');
  return context;
}