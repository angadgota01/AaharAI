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

  void doLogin() async {
    final e = email.text.trim();
    final p = password.text.trim();

    if (e.isEmpty || p.isEmpty) {
      setState(() => error = "Email and password required");
      return;
    }

    final result = await AuthService.login(e, p);

    if (result != null) {
      setState(() => error = result);
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                TextField(controller: email, decoration: const InputDecoration(labelText: "Email")),
                TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: "Password")),
                if (error != null)
                  Text(error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: doLogin, child: const Text("Login")),
                TextButton(
                  onPressed: () => context.go('/signup'),
                  child: const Text("Create Account"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

