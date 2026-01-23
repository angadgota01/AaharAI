import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  String? error;
  bool isLoading = false;

  void doLogin() async {
    final e = email.text.trim();
    final p = password.text.trim();

    if (e.isEmpty || p.isEmpty) {
      setState(() => error = "Email and password required");
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    final result = await AuthService.login(e, p);

    if (!mounted) return;

    setState(() => isLoading = false);

    if (result != null) {
      setState(() => error = result);
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Login", style: TextStyle(fontSize: 24)),
                const SizedBox(height: 16),
                TextField(
                  controller: email,
                  decoration: const InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                  enabled: !isLoading,
                ),
                TextField(
                  controller: password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password"),
                  enabled: !isLoading,
                  onSubmitted: (_) => doLogin(),
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(error!, style: const TextStyle(color: Colors.red)),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : doLogin,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("Login"),
                  ),
                ),
                TextButton(
                  onPressed: isLoading ? null : () => context.go('/forgot-password'),
                  child: const Text("Forgot Password?"),
                ),
                TextButton(
                  onPressed: isLoading ? null : () => context.go('/signup'),
                  child: const Text("Create Account"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white24),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
    );
  }
}
