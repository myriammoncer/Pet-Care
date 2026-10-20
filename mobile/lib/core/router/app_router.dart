import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/agenda/presentation/agenda_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/signup_page.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/events/presentation/events_page.dart';
import '../../features/marketplace/presentation/marketplace_page.dart';
import '../../features/medical_record/presentation/medical_record_page.dart';
import '../../features/pets/presentation/pet_detail_page.dart';
import '../../features/pets/presentation/pets_page.dart';
import '../widgets/home_shell.dart';

/// Routeur de l'application (go_router) avec redirection selon l'état
/// d'authentification. Les routes principales sont regroupées dans un shell
/// à barre de navigation.
final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/pets',
    refreshListenable: auth, // AuthController est un ChangeNotifier
    redirect: (context, state) {
      final loggedIn = auth.isAuthenticated;
      final loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/signup';

      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn) return '/pets';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupPage()),

      // Section principale avec barre de navigation.
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(path: '/pets', builder: (_, __) => const PetsPage()),
          GoRoute(path: '/marketplace', builder: (_, __) => const MarketplacePage()),
          GoRoute(path: '/agenda', builder: (_, __) => const AgendaPage()),
          GoRoute(path: '/events', builder: (_, __) => const EventsPage()),
        ],
      ),

      // Routes de détail (hors shell).
      GoRoute(
        path: '/pets/:id',
        builder: (_, state) => PetDetailPage(petId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/pets/:id/medical',
        builder: (_, state) => MedicalRecordPage(petId: state.pathParameters['id']!),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Page introuvable : ${state.uri}')),
    ),
  );
});
