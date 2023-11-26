import 'package:firebase_auth/firebase_auth.dart';

enum AuthStatus {
  successful,
  wrongPassword,
  emailAlreadyExists,
  invalidEmail,
  weakPassword,
  unknown,
}

class AuthExceptionHandler {
  static AuthStatus handleAuthException(FirebaseAuthException e) {
    AuthStatus status;
    switch (e.code) {
      case 'invalid-email':
        status = AuthStatus.invalidEmail;
      case 'wrong-password':
        status = AuthStatus.wrongPassword;
      case 'weak-password':
        status = AuthStatus.weakPassword;
      case 'email-already-in-use':
        status = AuthStatus.emailAlreadyExists;
      default:
        status = AuthStatus.unknown;
    }
    return status;
  }

  static String generateErrorMessage(error) {
    String errorMessage;
    switch (error) {
      case AuthStatus.invalidEmail:
        errorMessage = 'Your email address appears to be malformed.';
      case AuthStatus.weakPassword:
        errorMessage = 'Your password should be at least 6 characters.';
      case AuthStatus.wrongPassword:
        errorMessage = 'Your email or password is wrong.';
      case AuthStatus.emailAlreadyExists:
        errorMessage =
            'The email address is already in use by another account.';
      default:
        errorMessage = 'An error occured. Please try again later.';
    }
    return errorMessage;
  }
}
