import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/provider_model.dart';

class ProviderCard extends StatelessWidget {
  final ProviderModel provider;
  final VoidCallback onTap;

  const ProviderCard({
    super.key,
    required this.provider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primaryLight,
                    backgroundImage: provider.photoUrl != null
                        ? NetworkImage(provider.photoUrl!)
                        : null,
                    child: provider.photoUrl == null
                        ? Text(
                            provider.name.isNotEmpty
                                ? provider.name[0].toUpperCase()
                                : '👨‍🔧',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : null,
                  ),
                  if (provider.isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          provider.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (provider.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            color: AppColors.primary,
                            size: 14,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    _ServiceTags(serviceTypes: provider.serviceTypes),
                  ],
                ),
              ),
              // Distance + rating
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    provider.distanceKm != null
                        ? '${provider.distanceKm!.toStringAsFixed(1)} km'
                        : '—',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 13),
                      Text(
                        provider.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}

class _ServiceTags extends StatelessWidget {
  final List<String> serviceTypes;
  const _ServiceTags({required this.serviceTypes});

  @override
  Widget build(BuildContext context) {
    final icons = {
      'mechanic': '🔧',
      'towing': '🚛',
      'tire': '🔩',
      'electrical': '⚡',
      'battery': '🔋',
      'fuel': '⛽',
      'locksmith': '🔑',
      'other': '🛠️',
    };
    return Row(
      children: serviceTypes
          .take(3)
          .map((s) => Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Text(
                  icons[s] ?? '🛠️',
                  style: const TextStyle(fontSize: 13),
                ),
              ))
          .toList(),
    );
  }
}
