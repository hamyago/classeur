import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/colors.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final route = GoRouterState.of(context).matchedLocation;
    return Container(
      width: 240,
      color: AdminColors.sidebar,
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AdminColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(child: Text('🚗', style: TextStyle(fontSize: 18))),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Auto-SOS', style: TextStyle(color: AdminColors.textLight,
                        fontWeight: FontWeight.w700, fontSize: 15)),
                    Text('Admin', style: TextStyle(color: AdminColors.textMuted, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: AdminColors.border, height: 1),
          const SizedBox(height: 8),
          _NavItem(icon: Icons.dashboard_outlined, label: 'Dashboard', route: '/dashboard', current: route),
          _NavItem(icon: Icons.people_outline, label: 'Prestataires', route: '/providers', current: route),
          _NavItem(icon: Icons.person_outline, label: 'Utilisateurs', route: '/users', current: route),
          _NavItem(icon: Icons.build_outlined, label: 'Interventions', route: '/interventions', current: route),
          _NavItem(icon: Icons.account_balance_wallet_outlined, label: 'Transactions', route: '/transactions', current: route),
          const Spacer(),
          const Divider(color: AdminColors.border, height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: AdminColors.textMuted, size: 20),
            title: const Text('Déconnexion', style: TextStyle(color: AdminColors.textMuted, fontSize: 13)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String current;
  const _NavItem({required this.icon, required this.label, required this.route, required this.current});

  @override
  Widget build(BuildContext context) {
    final selected = current == route;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: selected ? AdminColors.primary.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: selected ? AdminColors.primary : AdminColors.textMuted, size: 20),
        title: Text(label, style: TextStyle(
          color: selected ? AdminColors.primary : AdminColors.textMuted,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          fontSize: 14,
        )),
        onTap: () => context.go(route),
        dense: true,
      ),
    );
  }
}
