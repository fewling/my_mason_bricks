import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';
import 'auth_provider.dart';

final firestoreProvider = Provider((ref) => FirestoreManager());

final userProvider = StreamProvider.family.autoDispose((ref, String id) {
  return ref.watch(firestoreProvider).getUser(id);
});

final currentUserProvider = StreamProvider((ref) {
  final user = ref.watch(authStateChangesProvider).maybeWhen(
        data: (user) => user,
        orElse: () => null,
      );

  if (user == null) return Stream.value(null);

  return ref.watch(firestoreProvider).getUser(user.uid);
});

class FirestoreManager {
  // Root collection path.
  static const _kUserCollectionPath = 'Users';
  static const _kUserNameCollectionPath = 'UserNames';

  static final _instance = FirebaseFirestore.instance;

  Future<void> createUserDoc(AppUser user) {
    final batch = _instance.batch();

    final userDoc = _instance.collection(_kUserCollectionPath).doc(user.id);
    final userObj = jsonDecode(jsonEncode(user.toJson()));
    batch.set(userDoc, userObj);

    final userNameDoc =
        _instance.collection(_kUserNameCollectionPath).doc(user.name);
    batch.set(userNameDoc, {'belong': user.id});

    return batch.commit();
  }

  Stream<AppUser> getUser(String id) {
    return _instance
        .collection(_kUserCollectionPath)
        .doc(id)
        .snapshots()
        .map((doc) {
      if (!doc.exists) throw Exception('User not found');
      if (doc.data() == null) throw Exception('User data is null');

      return AppUser.fromJson(doc.data()!);
    });
  }

  Future<void> updateUserName({
    required AppUser appUser,
    required String name,
  }) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not found');

    final batch = _instance.batch();

    final userDoc = _instance.collection(_kUserCollectionPath).doc(user.uid);
    batch.update(userDoc, {'name': name});

    final oldUserNameDoc =
        _instance.collection(_kUserNameCollectionPath).doc(appUser.name);
    batch.delete(oldUserNameDoc);

    final newUserNameDoc =
        _instance.collection(_kUserNameCollectionPath).doc(name);
    batch.set(newUserNameDoc, {'belong': user.uid});

    return batch.commit();
  }

  Future<void> deleteUser(AppUser user) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not found');

    final batch = _instance.batch();

    final userDoc = _instance.collection(_kUserCollectionPath).doc(user.uid);
    batch.delete(userDoc);

    final userNameDoc =
        _instance.collection(_kUserNameCollectionPath).doc(user.displayName);
    batch.delete(userNameDoc);

    return batch.commit();
  }

  Future<bool> isNameTaken(String name) async {
    final doc =
        await _instance.collection(_kUserNameCollectionPath).doc(name).get();

    if (!doc.exists) return false;
    if (doc.data() == null) return false;

    final userID = doc.data()!['belong'] as String?;
    if (userID == null) return false;

    return true;
  }
}
