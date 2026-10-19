// lib/main.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/notes_screen.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.validate();

  final auth = AuthProvider(AuthService())..init();
  runApp(
    ChangeNotifierProvider.value(
      value: auth,
      child: NotesApp(auth: auth),
    ),
  );
}

class NotesApp extends StatefulWidget {
  const NotesApp({super.key, required this.auth});

  final AuthProvider auth;

  @override
  State<NotesApp> createState() => _NotesAppState();
}

class _NotesAppState extends State<NotesApp> {
  late final GoRouter _router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: widget.auth,
    redirect: (context, state) {
      final location = state.matchedLocation;

      // 1. We do not know yet if a session exists: show the splash screen
      if (widget.auth.initializing) {
        return location == '/splash' ? null : '/splash';
      }
      if (widget.auth.initializationError != null) {
        return location == '/splash' ? null : '/splash';
      }
      // 2. Logged out: only the login screen is allowed
      if (widget.auth.user == null) {
        return location == '/login' ? null : '/login';
      }
      // 3. Logged in: leave the login and splash screens
      if (location == '/login' || location == '/splash') return '/';
      return null; // no redirection
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => AuthStatusScreen(auth: widget.auth),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/notes', builder: (context, state) => const NotesScreen()),
    ],
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Notes App',
      theme: ThemeData(colorSchemeSeed: const Color(0xFF208AEF)),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF208AEF),
        brightness: Brightness.dark,
      ),
      routerConfig: _router,
    );
  }
}

class AuthStatusScreen extends StatelessWidget {
  const AuthStatusScreen({super.key, required this.auth});

  final AuthProvider auth;

  @override
  Widget build(BuildContext context) {
    final initializationError = context
        .watch<AuthProvider>()
        .initializationError;
    return Scaffold(
      body: Center(
        child: initializationError == null
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 12,
                  children: [
                    const Text('Could not restore your session'),
                    Text(initializationError, textAlign: TextAlign.center),
                    FilledButton(
                      onPressed: auth.init,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
