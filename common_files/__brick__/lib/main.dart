import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'service/app_router.dart';
import 'service/preference_provider.dart';
import 'utils/riverpod_observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kDebugMode) {
    try {
      FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
      await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    } catch (e) {
      debugPrint('Failed to connect to the Firebase Emulator Suite.');
      debugPrint(e.toString());
    }
  }

  usePathUrlStrategy();
  GoRouter.optionURLReflectsImperativeAPIs = true;

  final sp = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferenceProvider.overrideWith((_) => sp)],
      observers: [RiverpodObserver()],
      child: const MainApp(),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appPreference = ref.watch(appPreferenceProvider);
    final colorSeed = appPreference.colorSchemeSeed;
    final isDarkMode = appPreference.isDarkMode;

    return MaterialApp.router(
      title: '{{app_title}}',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        colorSchemeSeed: Color(colorSeed),
      ),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
