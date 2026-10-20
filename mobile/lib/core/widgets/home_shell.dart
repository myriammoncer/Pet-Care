import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Coquille principale : barre de navigation entre les 4 sections racines.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.child});

  final Widget child;

  static const _tabs = <_Tab>[
    _Tab('/pets', Icons.pets, 'Animaux'),
    _Tab('/marketplace', Icons.storefront, 'Boutique'),
    _Tab('/agenda', Icons.event, 'Agenda'),
    _Tab('/events', Icons.celebration, 'Événements'),
  ];

  int _indexFor(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final i = _tabs.indexWhere((t) => location.startsWith(t.path));
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final index = _indexFor(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => context.go(_tabs[i].path),
        destinations: [
          for (final t in _tabs)
            NavigationDestination(icon: Icon(t.icon), label: t.label),
        ],
      ),
    );
  }
}

class _Tab {
  const _Tab(this.path, this.icon, this.label);
  final String path;
  final IconData icon;
  final String label;
}
