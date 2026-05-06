import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/phone_auth_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/profile_setup_screen.dart';
import '../../features/user/screens/home_screen.dart';
import '../../features/user/screens/request_screen.dart';
import '../../features/user/screens/tracking_screen.dart';
import '../../features/user/screens/history_screen.dart';
import '../../features/user/screens/profile_screen.dart';
import '../../features/provider/screens/provider_home_screen.dart';
import '../../features/provider/screens/provider_earnings_screen.dart';
import '../../features/provider/screens/provider_profile_screen.dart';
import '../../core/models/provider_model.dart';

// User bottom navigation shell
class UserShell extends StatefulWidget {
  final Widget child;
  const UserShell({super.key, required this.child});

  @override
  State<UserShell> createState() => _UserShellState();
}

class _UserShellState extends State<UserShell> {
  int _idx = 0;

  static const _routes = ['/user/home', '/user/history', '/user/profile'];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: widget.child,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _idx,
          onTap: (i) {
            setState(() => _idx = i);
            context.go(_routes[i]);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Carte',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              activeIcon: Icon(Icons.history),
              label: 'Historique',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      );
}

GoRouter buildRouter(AuthController authCtrl) => GoRouter(
      initialLocation: '/',
      refreshListenable: authCtrl,
      routes: [
        // Splash
        GoRoute(
          path: '/',
          builder: (_, __) => const SplashScreen(),
        ),

        // Onboarding
        GoRoute(
          path: '/onboarding',
          builder: (_, __) => const OnboardingScreen(),
        ),

        // Auth routes
        GoRoute(
          path: '/auth/phone',
          builder: (ctx, state) {
            final isProvider = state.uri.queryParameters['role'] == 'provider';
            return PhoneAuthScreen(isProvider: isProvider);
          },
        ),
        GoRoute(
          path: '/auth/otp',
          builder: (ctx, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            return OtpScreen(
              phone: extra['phone'] as String? ?? '',
              isProvider: extra['isProvider'] as bool? ?? false,
            );
          },
        ),
        GoRoute(
          path: '/auth/profile-setup',
          builder: (ctx, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            return ProfileSetupScreen(
              isProvider: extra['isProvider'] as bool? ?? false,
            );
          },
        ),

        // User shell with tabs
        ShellRoute(
          builder: (_, __, child) => UserShell(child: child),
          routes: [
            GoRoute(
              path: '/user/home',
              builder: (_, __) => const UserHomeScreen(),
            ),
            GoRoute(
              path: '/user/history',
              builder: (_, __) => const HistoryScreen(),
            ),
            GoRoute(
              path: '/user/profile',
              builder: (_, __) => const UserProfileScreen(),
            ),
          ],
        ),

        // User standalone routes
        GoRoute(
          path: '/user/request',
          builder: (ctx, state) {
            final provider = state.extra as ProviderModel?;
            return RequestScreen(preselectedProvider: provider);
          },
        ),
        GoRoute(
          path: '/user/tracking/:id',
          builder: (ctx, state) => TrackingScreen(
            interventionId: state.pathParameters['id']!,
          ),
        ),

        // Provider routes
        GoRoute(
          path: '/provider/home',
          builder: (_, __) => const ProviderHomeScreen(),
        ),
        GoRoute(
          path: '/provider/earnings',
          builder: (_, __) => const ProviderEarningsScreen(),
        ),
        GoRoute(
          path: '/provider/profile',
          builder: (_, __) => const ProviderProfileScreen(),
        ),
      ],
    );
