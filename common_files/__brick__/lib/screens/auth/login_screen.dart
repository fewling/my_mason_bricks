import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/app_user.dart';
import '../../service/app_router.dart';
import '../../service/firestore_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  var _obscurePw = true;

  @override
  Widget build(BuildContext context) {
    final txtTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) => ListView(
          padding: const EdgeInsets.all(8.0),
          children: [
            Container(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text("Don't have an account? ",
                          style: txtTheme.labelSmall),
                      TextButton(
                        onPressed: () =>
                            context.goNamed(Location.register.name),
                        child: Text(
                          'Sign up',
                          style: txtTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email_outlined),
                      label: Text('Email'),
                    ),
                  ),
                  TextFormField(
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: _obscurePw,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline),
                      label: const Text('Password'),
                      suffixIcon: IconButton(
                        tooltip: _obscurePw ? 'Show password' : 'Hide password',
                        onPressed: _togglePwObscure,
                        icon: Icon(_obscurePw
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      style:
                          TextButton.styleFrom(textStyle: txtTheme.labelSmall),
                      onPressed: () =>
                          context.goNamed(Location.resetPassword.name),
                      child: const Text('Forgot password?'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Sign in'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Text('OR', style: txtTheme.labelSmall),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: Consumer(
                      builder: (context, ref, child) => TextButton(
                        onPressed: () => _signInAnonymously(context, ref),
                        child: const Text('Sign in as Guest'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signInAnonymously(BuildContext context, WidgetRef ref) async {
    final userCredential = await FirebaseAuth.instance.signInAnonymously();
    if (!mounted) return;
    _createUserDoc(context, ref, userCredential);
  }

  void _togglePwObscure() {
    setState(() {
      _obscurePw = !_obscurePw;
    });
  }

  Future<void> _createUserDoc(
    BuildContext context,
    WidgetRef ref,
    UserCredential userCredential,
  ) async {
    final user = userCredential.user;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in failed')),
        );
      }
      return;
    }

    final appUser = AppUser(id: user.uid, name: user.displayName);
    await ref.read(firestoreProvider).createUserDoc(appUser);
  }
}
