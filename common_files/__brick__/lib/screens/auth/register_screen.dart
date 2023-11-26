import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/app_user.dart';
import '../../service/app_router.dart';
import '../../service/firestore_manager.dart';
import '../../utils/convenient_extensions.dart';
import '../../utils/custom_exceptions.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        leading: IconButton(
          onPressed: () => _pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => ListView(
          padding: const EdgeInsets.all(8.0),
          children: [
            Container(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        } else if (!value.isEmail()) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email_outlined),
                        label: Text('Email'),
                      ),
                    ),
                    TextFormField(
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        } else if (value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline),
                        label: Text('Password'),
                      ),
                    ),
                    TextFormField(
                      controller: _confirmPasswordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        } else if (value != _passwordController.text) {
                          return 'Password does not match';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline),
                        label: Text('Confirm Password'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Consumer(
                        builder: (_, ref, __) => ElevatedButton(
                          onPressed: () => _createUser(ref),
                          child: const Text('Sign Up'),
                        ),
                      ),
                    ),
                  ],
                ),
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

  Future<void> _createUser(WidgetRef ref) async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final email = _emailController.text;
    final password = _passwordController.text;

    final status = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((credential) async {
      if (credential.user == null) return AuthStatus.unknown;

      final appUser = AppUser(id: credential.user!.uid);
      await ref.read(firestoreProvider).createUserDoc(appUser);

      return AuthStatus.successful;
    }).catchError((e) => AuthExceptionHandler.handleAuthException(
            e as FirebaseAuthException));

    if (status != AuthStatus.successful) {
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: colorScheme.error,
          content: Text(AuthExceptionHandler.generateErrorMessage(status)),
        ),
      );
    }
  }
}
