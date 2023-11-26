import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unique_name_generator/unique_name_generator.dart';

import '../../service/app_router.dart';
import '../../service/firestore_manager.dart';
import '../../widgets/loading_widget.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<ProfileScreen> {
  final _kDictionaries = {
    'adjectives': adjectives,
    'animals': animals,
    'colors': colors,
    'countries': countries,
    'languages': languages,
    'names': names,
  };

  final _selectedDicts = [adjectives, animals];

  late final _nameGenerator = UniqueNameGenerator(
    dictionaries: _selectedDicts,
    style: NameStyle.capital,
    separator: ' ',
  );

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  var _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final colorScheme = Theme.of(context).colorScheme;

    if (user == null) return const Center(child: Text('No user found'));

    ref.listen(
      userProvider(user.uid),
      (previous, next) {
        next.maybeWhen(
          data: (data) => _nameController.text = data.name ?? '',
          orElse: () => _nameController.text = _nameGenerator.generate(),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => _pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Delete account',
            onPressed: () => _delete(context),
            icon: Icon(
              Icons.delete_forever_outlined,
              color: colorScheme.error,
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // User avatar
              CircleAvatar(
                radius: 50,
                backgroundImage:
                    user.photoURL == null ? null : NetworkImage(user.photoURL!),
                child: user.photoURL == null
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),

              const SizedBox(height: 16),

              // User name
              TextFormField(
                controller: _nameController,
                validator: _validateUserName,
                maxLength: 40,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person_outline),
                  labelText: 'Display Name*',
                  suffixIcon: IconButton(
                    tooltip: 'Random name',
                    onPressed: _generateName,
                    icon: const Icon(Icons.casino_outlined),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              ListTile(
                title: const Text('Random Name Style'),
                subtitle: Wrap(
                  children: [
                    for (final dict in _kDictionaries.entries)
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: FilterChip(
                          selected: _selectedDicts.contains(dict.value),
                          label: Text(dict.key),
                          onSelected: (value) => _onDictSelected(value, dict),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : _save,
        icon: _isSaving ? const LoadingWidget() : const Icon(Icons.save),
        label: const Text('Save'),
      ),
    );
  }

  void _pop(BuildContext context) {
    context.canPop() ? context.pop() : context.goNamed(Location.home.name);
  }

  void _onDictSelected(bool value, MapEntry<String, Dictionary> dict) {
    setState(() {
      if (value) {
        _selectedDicts.add(dict.value);
      } else {
        if (_selectedDicts.length > 1) _selectedDicts.remove(dict.value);
      }
      _nameGenerator.dictionaries = _selectedDicts;
    });
  }

  void _generateName() {
    _nameController.text = _nameGenerator.generate();
  }

  /// Validates the user name.
  /// Returns null if the name is valid, otherwise returns an error message.
  String? _validateUserName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a name';
    }

    if (value.length > 40) {
      return 'Name must be less than 40 characters';
    }

    if (value.contains('/') || value.contains('.')) {
      return 'Symbols / and . are not allowed';
    }

    return null;
  }

  Future<void> _save() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final colorScheme = Theme.of(context).colorScheme;

    setState(() => _isSaving = true);

    final name = _nameController.text;
    final isTaken = await ref.read(firestoreProvider).isNameTaken(name);

    if (!mounted) return;
    if (isTaken) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Name is already taken'),
          backgroundColor: colorScheme.error,
        ),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final appUser = await ref.read(userProvider(uid).future);

    await ref
        .read(firestoreProvider)
        .updateUserName(appUser: appUser, name: name);

    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: colorScheme.primary,
        content: const Text('Saved'),
      ),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;

    // Prompt the user to confirm the deletion.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.warning, color: colorScheme.error),
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == null || !confirmed) return;

    // If the user confirmed the deletion, delete the account.
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final appUser = await ref.read(userProvider(uid).future);
    await ref.read(firestoreProvider).deleteUser(appUser);
  }
}
