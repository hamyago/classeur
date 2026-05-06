import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/controllers/auth_controller.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar + name
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.primaryLight,
                    backgroundImage: user?.photoUrl != null
                        ? NetworkImage(user!.photoUrl!)
                        : null,
                    child: user?.photoUrl == null
                        ? Text(
                            (user?.name?.isNotEmpty == true)
                                ? user!.name![0].toUpperCase()
                                : '👤',
                            style: const TextStyle(
                              fontSize: 36,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? 'Utilisateur',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    user?.phone ?? '',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  // Rating
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${user?.rating.toStringAsFixed(1) ?? '5.0'} — ${user?.totalInterventions ?? 0} intervention(s)',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Subscription
            _SubscriptionCard(
              hasSubscription: user?.hasSubscription ?? false,
              expiry: user?.subscriptionExpiry,
            ),

            const SizedBox(height: 20),

            // Menu items
            _Section(
              title: 'Mon compte',
              items: [
                _MenuItem(
                  icon: Icons.directions_car_outlined,
                  label: 'Mes véhicules',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.history,
                  label: 'Historique',
                  onTap: () => context.go('/user/history'),
                ),
                _MenuItem(
                  icon: Icons.star_border,
                  label: 'Mes avis',
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 12),

            _Section(
              title: 'Support',
              items: [
                _MenuItem(
                  icon: Icons.phone_outlined,
                  label: 'Appeler le support',
                  onTap: () => launchUrl(
                    Uri.parse('tel:${AppConstants.supportPhone}'),
                  ),
                ),
                _MenuItem(
                  icon: Icons.chat_outlined,
                  label: 'WhatsApp Auto-SOS',
                  onTap: () => launchUrl(
                    Uri.parse(
                      'https://wa.me/${AppConstants.supportWhatsapp.replaceAll('+', '')}',
                    ),
                  ),
                ),
                _MenuItem(
                  icon: Icons.help_outline,
                  label: 'FAQ',
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 12),

            _Section(
              title: 'Légal',
              items: [
                _MenuItem(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Politique de confidentialité',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.article_outlined,
                  label: 'Conditions d\'utilisation',
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 24),

            OutlinedButton.icon(
              onPressed: () async {
                await auth.signOut();
                if (context.mounted) context.go('/onboarding');
              },
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text(
                'Se déconnecter',
                style: TextStyle(color: AppColors.error),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final bool hasSubscription;
  final DateTime? expiry;
  const _SubscriptionCard({required this.hasSubscription, this.expiry});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: hasSubscription
                ? [AppColors.success, const Color(0xFF0D7A47)]
                : [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Text('⭐', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasSubscription ? 'Abonnement actif' : 'Passer à Premium',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    hasSubscription && expiry != null
                        ? 'Expire le ${_formatDate(expiry!)}'
                        : 'Déplacement offert sur toutes vos interventions',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (!hasSubscription)
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Souscrire'),
              ),
          ],
        ),
      );

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _Section extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  const _Section({required this.title, required this.items});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: List.generate(items.length, (i) {
                final item = items[i];
                final isLast = i == items.length - 1;
                return Column(
                  children: [
                    ListTile(
                      leading: Icon(item.icon, color: AppColors.primary),
                      title: Text(item.label),
                      trailing: const Icon(Icons.chevron_right,
                          color: AppColors.textMuted),
                      onTap: item.onTap,
                    ),
                    if (!isLast)
                      const Divider(height: 1, indent: 56, endIndent: 16),
                  ],
                );
              }),
            ),
          ),
        ],
      );
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, required this.onTap});
}
