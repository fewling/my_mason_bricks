import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userChangesProvider = StreamProvider((ref) {
  return FirebaseAuth.instance.userChanges();
});

final idTokenChangesProvider = StreamProvider((ref) {
  return FirebaseAuth.instance.idTokenChanges();
});

final authStateChangesProvider = StreamProvider((ref) {
  return FirebaseAuth.instance.authStateChanges();
});
