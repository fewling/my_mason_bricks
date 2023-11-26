import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../service/app_info_provider.dart';
import '../../service/app_router.dart';
import '../../service/auth_provider.dart';
import '../../service/preference_provider.dart';
import '../../widgets/color_picker_sheet.dart';
import '../../widgets/error_info.dart';
import '../../widgets/loading_widget.dart';

class SettingScreen extends ConsumerWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;

    final authAsync = ref.watch(authStateChangesProvider);
    final appInfoAsync = ref.watch(appInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('Settings'),
            SizedBox(width: 4),
          ],
        ),
        actions: [
          authAsync.when(
            data: (user) => user == null
                ? const SizedBox.shrink()
                : ElevatedButton.icon(
                    icon: Icon(Icons.logout, color: primary),
                    label: const Text('Sign Out'),
                    onPressed: () => FirebaseAuth.instance.signOut(),
                  ),
            error: (e, s) => ErrorInfo(e: e, s: s),
            loading: () => const LoadingWidget(),
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.language_outlined, color: primary),
            title: const Text('Language'),
            onTap: () {},
            trailing: const Icon(Icons.arrow_forward_ios_outlined),
          ),
          ListTile(
            leading: Icon(Icons.person_outline_outlined, color: primary),
            title: const Text('Profile'),
            onTap: () => context.pushNamed(Location.profile.name),
            trailing: const Icon(Icons.arrow_forward_ios_outlined),
          ),
          ListTile(
            leading: Icon(Icons.brightness_2_outlined, color: primary),
            title: const Text('Use Dark Mode'),
            onTap: () => _toggleBrightness(ref),
            trailing: Switch(
              value: ref.watch(appPreferenceProvider).isDarkMode,
              onChanged: (_) => _toggleBrightness(ref),
            ),
          ),
          ListTile(
            leading: Icon(Icons.color_lens_outlined, color: primary),
            title: const Text('Color Scheme'),
            trailing: Icon(Icons.square, color: colorScheme.primary),
            onTap: () => showModalBottomSheet(
              context: context,
              builder: (_) => const ColorPickerSheet(),
            ),
          ),
          ButtonBar(
            children: [
              // Chip(label: Text(commitHash.first7())),
              appInfoAsync.when(
                data: (info) => Chip(
                  label: Text(info.version),
                ),
                error: (e, s) => ErrorInfo(e: e, s: s),
                loading: () => const LoadingWidget(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleBrightness(WidgetRef ref) {
    ref.read(appPreferenceProvider.notifier).toggleBrightness();
  }
}

class RoundChip extends StatelessWidget {
  const RoundChip({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
