import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/agenda/presentation/agenda_page.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/forgot_password_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/reset_password_page.dart';
import '../../features/auth/presentation/signup_page.dart';
import '../../features/events/presentation/events_page.dart';
import '../../features/marketplace/presentation/cart_page.dart';
import '../../features/marketplace/presentation/checkout_page.dart';
import '../../features/marketplace/presentation/marketplace_page.dart';
import '../../features/marketplace/presentation/order_success_page.dart';
import '../../features/marketplace/presentation/orders_page.dart';
import '../../features/marketplace/presentation/product_detail_page.dart';
import '../../features/medical_record/presentation/medical_record_page.dart';
import '../../features/pets/presentation/pet_detail_page.dart';
import '../../features/pets/presentation/pets_page.dart';
import '../../features/profile/presentation/edit_profile_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../widgets/home_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Routeur de l'application (go_router) avec redirection selon l'état d'authentification.
final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/marketplace',
    refreshListenable: auth,
    redirect: (context, state) {
      final loggedIn = auth.isAuthenticated;
      const publicPaths = {'/login', '/signup', '/forgot-password', '/reset-password'};
      final onPublic = publicPaths.contains(state.matchedLocation);

      if (!loggedIn && !onPublic) return '/login';
      if (loggedIn && (state.matchedLocation == '/login' || state.matchedLocation == '/signup')) {
        return '/marketplace';
      }
      return null;
    },
    routes: [
      // Routes publiques
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupPage()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordPage()),
      GoRoute(
        path: '/reset-password',
        builder: (_, state) =>
            ResetPasswordPage(initialToken: state.uri.queryParameters['token']),
      ),

      // Route de détail produit mise au niveau racine (Hors ShellRoute)
      GoRoute(
        path: '/marketplace/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => ProductDetailPage(
          productId: state.pathParameters['id']!,
        ),
      ),

      // ShellRoute : Onglets principaux avec barre de navigation inférieure
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(path: '/pets', builder: (_, __) => const PetsPage()),
          GoRoute(path: '/marketplace', builder: (_, __) => const MarketplacePage()),
          GoRoute(path: '/agenda', builder: (_, __) => const AgendaPage()),
          GoRoute(path: '/events', builder: (_, __) => const EventsPage()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
        ],
      ),

      // Autres routes de détail hors shell (plein écran)
      GoRoute(
        path: '/cart',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const CartPage(),
      ),
      GoRoute(
        path: '/checkout',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const CheckoutPage(),
      ),
      GoRoute(
        path: '/order-success',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return OrderSuccessPage(
            orderRef: extra?['orderRef'] as String?,
            totalAmount: extra?['totalAmount'] as double?,
            itemCount: extra?['itemCount'] as int?,
          );
        },
      ),
      GoRoute(
        path: '/orders',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const OrdersPage(),
      ),
      GoRoute(
        path: '/pets/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => PetDetailPage(petId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/pets/:id/medical',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => MedicalRecordPage(petId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/profile/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const EditProfilePage(),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Page introuvable : ${state.uri}')),
    ),
  );
});
