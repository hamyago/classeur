import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/intervention_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/utils/price_calculator.dart';

class TrackingScreen extends StatefulWidget {
  final String interventionId;
  const TrackingScreen({super.key, required this.interventionId});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final _db = FirestoreService();
  GoogleMapController? _mapCtrl;
  InterventionModel? _intervention;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _sub = _db.watchIntervention(widget.interventionId).listen((i) {
      setState(() => _intervention = i);
      if (i != null &&
          i.providerLatitude != null &&
          i.providerLongitude != null) {
        _mapCtrl?.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(i.providerLatitude!, i.providerLongitude!),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _mapCtrl?.dispose();
    super.dispose();
  }

  Set<Marker> get _markers {
    final markers = <Marker>{};
    if (_intervention == null) return markers;

    markers.add(Marker(
      markerId: const MarkerId('user'),
      position: LatLng(
        _intervention!.userLatitude,
        _intervention!.userLongitude,
      ),
      infoWindow: const InfoWindow(title: 'Votre position'),
    ));

    if (_intervention!.providerLatitude != null &&
        _intervention!.providerLongitude != null) {
      markers.add(Marker(
        markerId: const MarkerId('provider'),
        position: LatLng(
          _intervention!.providerLatitude!,
          _intervention!.providerLongitude!,
        ),
        infoWindow: InfoWindow(
          title: _intervention!.providerName ?? 'Prestataire',
        ),
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ));
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final i = _intervention;
    return Scaffold(
      body: Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: i != null
                  ? LatLng(i.userLatitude, i.userLongitude)
                  : const LatLng(5.3599517, -4.0082563), // Abidjan
              zoom: 14,
            ),
            onMapCreated: (c) => _mapCtrl = c,
            markers: _markers,
            zoomControlsEnabled: false,
            myLocationEnabled: false,
          ),

          // Back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                  onPressed: () => context.go('/user/home'),
                ),
              ),
            ),
          ),

          // Bottom info panel
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: i == null
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status badge
                        _StatusBadge(status: i.status),
                        const SizedBox(height: 16),

                        // Provider info
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.primaryLight,
                              child: Text('👨‍🔧', style: TextStyle(fontSize: 22)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    i.providerName ?? 'En attente...',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '${i.serviceTypeName} — ${PriceCalculator.formatFcfa(i.totalPrice)}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (i.providerPhone != null)
                              Row(
                                children: [
                                  _ActionBtn(
                                    icon: Icons.phone,
                                    color: AppColors.success,
                                    onTap: () => launchUrl(
                                      Uri.parse('tel:${i.providerPhone}'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _ActionBtn(
                                    icon: Icons.chat,
                                    color: AppColors.primary,
                                    onTap: () => launchUrl(
                                      Uri.parse(
                                        'https://wa.me/${i.providerPhone?.replaceAll('+', '')}',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),

                        if (i.isActive) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          Center(
                            child: TextButton.icon(
                              onPressed: () {
                                _showCancelDialog(context, i.id);
                              },
                              icon: const Icon(Icons.cancel_outlined,
                                  color: AppColors.error),
                              label: const Text(
                                'Annuler l\'intervention',
                                style: TextStyle(color: AppColors.error),
                              ),
                            ),
                          ),
                        ],

                        if (i.isCompleted) ...[
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () =>
                                context.push('/user/review/${i.id}'),
                            child: const Text('Noter le prestataire'),
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Annuler l\'intervention ?'),
        content: const Text(
            'Cette action est irréversible. Des frais d\'annulation peuvent s\'appliquer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () async {
              await _db.updateInterventionStatus(
                  id, AppConstants.statusCancelled);
              if (mounted) {
                Navigator.pop(context);
                context.go('/user/home');
              }
            },
            child: const Text('Oui, annuler',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      'pending' => ('En attente d\'acceptation', AppColors.warning, '⏳'),
      'accepted' => ('Prestataire en route', AppColors.primary, '🚗'),
      'in_progress' => ('Intervention en cours', AppColors.success, '🔧'),
      'completed' => ('Terminée', AppColors.success, '✅'),
      'cancelled' => ('Annulée', AppColors.error, '❌'),
      _ => ('Inconnu', AppColors.textMuted, '❓'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      );
}
