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
import '../../features/auth/presentation/forgot_password_page.dart';
import '../../features/auth/presentation/reset_password_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/profile/presentation/edit_profile_page.dart';
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
    // Pages accessibles SANS être connecté :
    const publicPaths = {'/login', '/signup', '/forgot-password', '/reset-password'};
    final onPublic = publicPaths.contains(state.matchedLocation);

    // Non connecté et hors d'une page publique → vers /login.
    if (!loggedIn && !onPublic) return '/login';
    // Déjà connecté mais sur login/signup → vers l'accueil.
    if (loggedIn &&
        (state.matchedLocation == '/login' || state.matchedLocation == '/signup')) {
      return '/pets';
    }
    return null;
  },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupPage()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordPage()),
      GoRoute(path: '/reset-password', builder: (_, __) => const ResetPasswordPage()),
      // Section principale avec barre de navigation.
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
          GoRoute(path: '/pets', builder: (_, __) => const PetsPage()),
          GoRoute(path: '/marketplace', builder: (_, __) => const MarketplacePage()),
          GoRoute(path: '/agenda', builder: (_, __) => const AgendaPage()),
          GoRoute(path: '/events', builder: (_, __) => const EventsPage()),
        ],
      ),
      GoRoute(path: '/profile/edit', builder: (_, __) => const EditProfilePage()),
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
