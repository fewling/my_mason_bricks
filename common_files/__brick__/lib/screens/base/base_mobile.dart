import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/screens/base/base_screen.dart';

import '../../service/app_router.dart';

final _scaffoldKeyProvider = Provider((ref) {
  return GlobalKey<ScaffoldState>();
});

class BaseMobile extends ConsumerWidget {
  const BaseMobile({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = ref.watch(_scaffoldKeyProvider);

    final loc = GoRouterState.of(context).matchedLocation;
    final index = kBaseDrawerLocations.indexWhere((e) => e.pathName == loc);
    final title = index == -1 ? 'Unknown' : kBaseDrawerLocations[index].label;

    return Scaffold(
      key: key,
      appBar: AppBar(title: Text(title)),
      drawer: NavigationDrawer(
        selectedIndex: index == -1 ? 0 : index,
        onDestinationSelected: (i) {
          final location = Location.values[i];
          context.goNamed(location.name);

          Future.delayed(const Duration(milliseconds: 250))
              .then((value) => key.currentState?.closeDrawer());
        },
        children: [
          for (final loc in kBaseDrawerLocations)
            NavigationDrawerDestination(
              icon: Tooltip(
                message: loc.label,
                child: Icon(loc.icon),
              ),
              selectedIcon: Tooltip(
                message: loc.label,
                child: Icon(loc.selectedIcon),
              ),
              label: Text(loc.label),
            ),
        ],
      ),
      body: child,
    );
  }
}
