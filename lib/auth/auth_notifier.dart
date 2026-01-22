import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A ChangeNotifier that listens to Supabase auth state changes
/// and notifies GoRouter to rebuild when auth state changes
class AuthNotifier extends ChangeNotifier {
  AuthNotifier() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      notifyListeners();
    });
  }

  bool get isAuthenticated => Supabase.instance.client.auth.currentUser != null;
}
