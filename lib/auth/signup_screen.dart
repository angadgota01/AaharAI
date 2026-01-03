import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final email = TextEditingController();
  final pass1 = TextEditingController();
  final pass2 = TextEditingController();
  String? error;

  void doSignup() async {
    final e = email.text.trim();
    final p1 = pass1.text.trim();
    final p2 = pass2.text.trim();

    if (e.isEmpty || p1.isEmpty || p2.isEmpty) {
      setState(() => error = "All fields required");
      return;
    }

    if (p1 != p2) {
      setState(() => error = "Passwords do not match");
      return;
    }

    final result = await AuthService.signup(e, p1);

    if (result != null) {
      setState(() => error = result);
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
        title: const Text("Create Account"),
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: email, decoration: const InputDecoration(labelText: "Email")),
                TextField(controller: pass1, obscureText: true, decoration: const InputDecoration(labelText: "Password")),
                TextField(controller: pass2, obscureText: true, decoration: const InputDecoration(labelText: "Confirm Password")),
                if (error != null)
                  Text(error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: doSignup, child: const Text("Create Account")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



