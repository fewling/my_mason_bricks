import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/profile_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/base/base_screen.dart';
import '../screens/error/route_not_found_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/setting/setting_screen.dart';

enum Location {
  home('/'),
  setting('/setting'),
  login('/login'),
  register('/register'),
  resetPassword('/forgot_password'),
  profile('/profile'),
  ;

  const Location(this.path);

  final String path;
}

final routerProvider = Provider(
  (ref) {
    final rootKey = GlobalKey<NavigatorState>();
    final shellKey = GlobalKey<NavigatorState>();

    final authStream = FirebaseAuth.instance.authStateChanges();
    final refreshListenable = GoRouterRefreshStream(authStream);

    return GoRouter(
      navigatorKey: rootKey,
      initialLocation: Location.home.path,
      refreshListenable: refreshListenable,
      errorBuilder: (context, state) => const RouteNotFoundScreen(),
      redirect: (context, state) {
        // ? if any redirect is needed, do it here
        return null;
      },
      routes: [
        GoRoute(
          parentNavigatorKey: rootKey,
          path: Location.login.path,
          name: Location.login.name,
          pageBuilder: (context, state) =>
              const MaterialPage(child: LoginScreen()),
        ),
        GoRoute(
          parentNavigatorKey: rootKey,
          path: Location.register.path,
          name: Location.register.name,
          pageBuilder: (context, state) =>
              const MaterialPage(child: RegisterScreen()),
        ),
        GoRoute(
          parentNavigatorKey: rootKey,
          path: Location.resetPassword.path,
          name: Location.resetPassword.name,
          pageBuilder: (context, state) =>
              const MaterialPage(child: ResetPasswordScreen()),
        ),
        GoRoute(
          parentNavigatorKey: rootKey,
          path: Location.profile.path,
          name: Location.profile.name,
          pageBuilder: (context, state) =>
              const MaterialPage(child: ProfileScreen()),
        ),
        ShellRoute(
          navigatorKey: shellKey,
          builder: (context, state, child) => BaseScreen(child: child),
          routes: [
            GoRoute(
              parentNavigatorKey: shellKey,
              path: Location.home.path,
              name: Location.home.name,
              pageBuilder: (context, state) =>
                  const MaterialPage(child: HomeScreen()),
            ),
            GoRoute(
              parentNavigatorKey: shellKey,
              path: Location.setting.path,
              name: Location.setting.name,
              pageBuilder: (context, state) =>
                  const MaterialPage(child: SettingScreen()),
            ),
          ],
        ),
      ],
    );
  },
);

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
