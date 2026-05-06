import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controllers/provider_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/service_type_model.dart';

class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final ctrl = context.watch<ProviderController>();
    final provider = auth.provider;

    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil prestataire')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar + info
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      provider?.name?.isNotEmpty == true
                          ? provider!.name[0].toUpperCase()
                          : '👨‍🔧',
                      style: const TextStyle(
                        fontSize: 32,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    provider?.name ?? 'Prestataire',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    provider?.phone ?? '',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${provider?.rating.toStringAsFixed(1) ?? '5.0'} — ${provider?.totalInterventions ?? 0} interventions',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _VerificationBadge(isVerified: provider?.isVerified ?? false),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Services
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Services proposés',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (provider?.serviceTypes ?? []).map((id) {
                      final s = ServiceTypeModel.defaults
                          .firstWhere((s) => s.id == id, orElse: () {
                        return ServiceTypeModel(
                          id: id,
                          name: id,
                          description: '',
                          icon: '🛠️',
                          basePrice: 0,
                          color: '#6C63FF',
                        );
                      });
                      return Chip(
                        label: Text('${s.icon} ${s.name}'),
                        backgroundColor: AppColors.primaryLight,
                        labelStyle:
                            const TextStyle(color: AppColors.primary),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Documents
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _DocTile(
                    icon: Icons.badge_outlined,
                    label: 'Pièce d\'identité',
                    status: provider?.idCardUrl != null
                        ? 'Soumis ✅'
                        : 'Non soumis',
                    statusColor: provider?.idCardUrl != null
                        ? AppColors.success
                        : AppColors.warning,
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 56),
                  _DocTile(
                    icon: Icons.workspace_premium_outlined,
                    label: 'Licence professionnelle',
                    status: provider?.proLicenseUrl != null
                        ? 'Soumis ✅'
                        : 'Non soumis',
                    statusColor: provider?.proLicenseUrl != null
                        ? AppColors.success
                        : AppColors.warning,
                    onTap: () {},
                  ),
                ],
              ),
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
          ],
        ),
      ),
    );
  }
}

class _VerificationBadge extends StatelessWidget {
  final bool isVerified;
  const _VerificationBadge({required this.isVerified});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isVerified ? AppColors.successLight : AppColors.warningLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          isVerified ? '✅ Compte vérifié' : '⏳ En attente de vérification',
          style: TextStyle(
            color: isVerified ? AppColors.success : AppColors.warning,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

class _DocTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String status;
  final Color statusColor;
  final VoidCallback onTap;
  const _DocTile({
    required this.icon,
    required this.label,
    required this.status,
    required this.statusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(label),
        trailing: Text(
          status,
          style: TextStyle(color: statusColor, fontSize: 12),
        ),
        onTap: onTap,
      );
}
