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
  bool isLoading = false;

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void doSignup() async {
    final e = email.text.trim();
    final p1 = pass1.text.trim();
    final p2 = pass2.text.trim();

    if (e.isEmpty || p1.isEmpty || p2.isEmpty) {
      setState(() => error = "All fields required");
      return;
    }

    if (!_isValidEmail(e)) {
      setState(() => error = "Please enter a valid email address");
      return;
    }

    if (p1.length < 6) {
      setState(() => error = "Password must be at least 6 characters");
      return;
    }

    if (p1 != p2) {
      setState(() => error = "Passwords do not match");
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    final result = await AuthService.signup(e, p1);

    if (!mounted) return;

    setState(() => isLoading = false);

    if (result != null) {
      setState(() => error = result);
    } else {
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! Please login.'),
            backgroundColor: Colors.green,
          ),
        );
      }
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: isLoading ? null : () => context.go('/login'),
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
                TextField(
                  controller: email,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    hintText: "your@email.com",
                  ),
                  keyboardType: TextInputType.emailAddress,
                  enabled: !isLoading,
                ),
                TextField(
                  controller: pass1,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    hintText: "Min. 6 characters",
                  ),
                  enabled: !isLoading,
                ),
                TextField(
                  controller: pass2,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Confirm Password"),
                  enabled: !isLoading,
                  onSubmitted: (_) => doSignup(),
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
                    onPressed: isLoading ? null : doSignup,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("Create Account"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
