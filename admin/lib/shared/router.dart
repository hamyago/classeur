import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../features/auth/login_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/providers/providers_screen.dart';
import '../features/users/users_screen.dart';
import '../features/interventions/interventions_screen.dart';
import '../features/transactions/transactions_screen.dart';

final adminRouter = GoRouter(
  initialLocation: '/dashboard',
  redirect: (context, state) {
    final loggedIn = FirebaseAuth.instance.currentUser != null;
    final onLogin  = state.matchedLocation == '/login';
    if (!loggedIn && !onLogin) return '/login';
    if (loggedIn  &&  onLogin) return '/dashboard';
    return null;
  },
  refreshListenable: _AuthNotifier(),
  routes: [
    GoRoute(path: '/login',         builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/dashboard',     builder: (_, __) => const DashboardScreen()),
    GoRoute(path: '/providers',     builder: (_, __) => const ProvidersScreen()),
    GoRoute(path: '/users',         builder: (_, __) => const UsersScreen()),
    GoRoute(path: '/interventions', builder: (_, __) => const InterventionsScreen()),
    GoRoute(path: '/transactions',  builder: (_, __) => const TransactionsScreen()),
  ],
);

class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((_) => notifyListeners());
  }
}
