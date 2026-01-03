import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _userKey = "mock_users";

  // Save new user
  static Future<String?> signup(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList(_userKey) ?? [];

    // Check if user exists
    for (var u in users) {
      final parts = u.split("|");
      if (parts[0] == email) {
        return "User already exists";
      }
    }

    users.add("$email|$password");
    await prefs.setStringList(_userKey, users);
    return null; // success
  }

  // Login existing user
  static Future<String?> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList(_userKey) ?? [];

    for (var u in users) {
      final parts = u.split("|");
      if (parts[0] == email && parts[1] == password) {
        return null; // success
      }
    }

    return "Invalid email or password";
  }
}

