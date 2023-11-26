import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../service/app_router.dart';
import '../../utils/custom_exceptions.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _key = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: IconButton(
          onPressed: () => _pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Form(
        key: _key,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Please enter your email address to recover your password.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Email address',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _emailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Empty email';
                }
                return null;
              },
              decoration: const InputDecoration(
                filled: true,
                hintText: 'email address',
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => resetPassword(_emailController.text.trim()),
                child: const Text('RECOVER PASSWORD'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pop(BuildContext context) {
    context.canPop() ? context.pop() : context.goNamed(Location.login.name);
  }

  Future<void> resetPassword(String email) async {
    final isValid = _key.currentState?.validate() ?? false;
    if (!isValid) return;

    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final status = await FirebaseAuth.instance
        .sendPasswordResetEmail(email: email)
        .then((value) => AuthStatus.successful)
        .catchError((e) => AuthExceptionHandler.handleAuthException(
            e as FirebaseAuthException));

    if (status == AuthStatus.successful) {
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: colorScheme.primary,
          content: const Text('Check your email for password reset'),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: colorScheme.error,
          content: Text(AuthExceptionHandler.generateErrorMessage(status)),
        ),
      );
    }
  }
}
