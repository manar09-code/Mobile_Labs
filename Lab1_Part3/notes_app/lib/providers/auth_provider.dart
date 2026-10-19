// lib/providers/auth_provider.dart
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service);

  final AuthService _service;

  models.User? user;
  bool initializing = true; // true until we know if a session exists
  bool busy = false; // true while a sign-in/sign-up request is running
  String? error;
  String? initializationError;

  /// Called once at startup: restores the session stored by the SDK.
  Future<void> init() async {
    initializing = true;
    initializationError = null;
    notifyListeners();
    try {
      user = await _service.currentUser();
    } catch (caught) {
      initializationError = caught is AppwriteException
          ? caught.message ?? 'Could not restore your session'
          : caught.toString();
    } finally {
      initializing = false;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) =>
      _run(() async => user = await _service.signIn(email, password));

  Future<bool> signUp(String name, String email, String password) =>
      _run(() async => user = await _service.signUp(name, email, password));

  Future<bool> signOut() => _run(() async {
    await _service.signOut();
    user = null;
  });

  Future<bool> _run(Future<void> Function() action) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on AppwriteException catch (e) {
      error = e.message ?? 'Something went wrong';
      return false;
    } catch (caught) {
      error = caught.toString();
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}
