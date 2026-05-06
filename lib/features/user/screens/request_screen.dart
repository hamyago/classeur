import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controllers/request_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/provider_model.dart';
import '../../../core/models/service_type_model.dart';
import '../../../core/utils/price_calculator.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/provider_card.dart';

class RequestScreen extends StatefulWidget {
  final ProviderModel? preselectedProvider;
  const RequestScreen({super.key, this.preselectedProvider});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RequestController>().initialize(
            preselectedProvider: widget.preselectedProvider,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<RequestController>();
    return Scaffold(
      appBar: AppBar(
        title: Text(_stepTitle(ctrl.step)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            if (ctrl.step == RequestStep.selectService) {
              context.pop();
            } else {
              ctrl.goBack();
            }
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: _StepIndicator(step: ctrl.step),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: switch (ctrl.step) {
          RequestStep.selectService => _SelectServiceStep(ctrl: ctrl),
          RequestStep.selectProvider => _SelectProviderStep(ctrl: ctrl),
          RequestStep.confirm => _ConfirmStep(ctrl: ctrl),
        },
      ),
    );
  }

  String _stepTitle(RequestStep step) => switch (step) {
        RequestStep.selectService => 'Type de service',
        RequestStep.selectProvider => 'Choisir un prestataire',
        RequestStep.confirm => 'Confirmer la demande',
      };
}

// ── Step 1: Select Service ─────────────────────────────────────────────────────

class _SelectServiceStep extends StatelessWidget {
  final RequestController ctrl;
  const _SelectServiceStep({required this.ctrl});

  @override
  Widget build(BuildContext context) => GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        itemCount: ctrl.services.length,
        itemBuilder: (_, i) {
          final s = ctrl.services[i];
          return _ServiceTile(
            service: s,
            onTap: () => ctrl.selectService(s),
          );
        },
      );
}

class _ServiceTile extends StatelessWidget {
  final ServiceTypeModel service;
  final VoidCallback onTap;
  const _ServiceTile({required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Color(
                    int.parse(service.color.replaceFirst('#', '0xFF')),
                  ).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    service.icon,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                service.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'à partir de ${PriceCalculator.formatFcfa(service.basePrice)}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
}

// ── Step 2: Select Provider ─────────────────────────────────────────────────────

class _SelectProviderStep extends StatelessWidget {
  final RequestController ctrl;
  const _SelectProviderStep({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    // In a real app, fetch providers filtered by service type
    // For now, use an empty list with a "search" call
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Service : ${ctrl.selectedService?.icon} ${ctrl.selectedService?.name}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<dynamic>>(
            stream: const Stream.empty(),
            builder: (_, __) => ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Placeholder for nearby providers
                _ProviderTile(
                  name: 'Chargement des prestataires...',
                  isPlaceholder: true,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProviderTile extends StatelessWidget {
  final String name;
  final bool isPlaceholder;
  final VoidCallback onTap;
  const _ProviderTile({
    required this.name,
    required this.onTap,
    this.isPlaceholder = false,
  });

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: const CircleAvatar(child: Text('👨‍🔧')),
          title: Text(name),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: isPlaceholder ? null : onTap,
        ),
      );
}

// ── Step 3: Confirm ───────────────────────────────────────────────────────────

class _ConfirmStep extends StatelessWidget {
  final RequestController ctrl;
  const _ConfirmStep({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final estimate = ctrl.estimate;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Row(
                  '🛠️ Service',
                  '${ctrl.selectedService?.icon} ${ctrl.selectedService?.name}',
                ),
                const Divider(height: 20),
                _Row('👨‍🔧 Prestataire', ctrl.selectedProvider?.name ?? '-'),
                _Row('📍 Distance',
                    '${estimate?.distanceKm.toStringAsFixed(1) ?? '-'} km'),
                const Divider(height: 20),
                _Row(
                  'Prix de base',
                  PriceCalculator.formatFcfa(estimate?.basePrice ?? 0),
                ),
                if (estimate?.kmCostWaived == true)
                  _Row(
                    'Déplacement',
                    'Offert (abonnement)',
                    valueColor: AppColors.success,
                  )
                else
                  _Row(
                    'Déplacement',
                    PriceCalculator.formatFcfa(estimate?.kmCostCharged ?? 0),
                  ),
                const Divider(height: 20),
                _Row(
                  'TOTAL',
                  PriceCalculator.formatFcfa(estimate?.total ?? 0),
                  bold: true,
                  valueColor: AppColors.primary,
                ),
              ],
            ),
          ),

          if (auth.user?.hasSubscription == false &&
              (estimate?.kmCostFull ?? 0) > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Avec l\'abonnement Auto-SOS, les frais de déplacement (${PriceCalculator.formatFcfa(estimate?.kmCostFull ?? 0)}) seraient offerts.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
          const Text(
            'Mode de paiement',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 12),
          _PaymentMethods(
            selected: ctrl.paymentMethod,
            onSelect: ctrl.setPaymentMethod,
          ),

          if (ctrl.error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(ctrl.error!,
                  style: const TextStyle(color: AppColors.error)),
            ),
          ],

          const SizedBox(height: 32),
          AppButton(
            label: 'Envoyer la demande',
            isLoading: ctrl.isLoading,
            enabled: true,
            icon: Icons.sos,
            onPressed: () async {
              if (auth.user == null) return;
              final ok = await ctrl.submitRequest(user: auth.user!);
              if (ok && context.mounted) {
                context.go(
                  '/user/tracking/${ctrl.createdInterventionId}',
                );
              }
            },
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Le prestataire sera notifié immédiatement.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;
  const _Row(
    this.label,
    this.value, {
    this.bold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Text(label,
                style: const TextStyle(color: AppColors.textSecondary)),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: valueColor ?? AppColors.textPrimary,
                fontSize: bold ? 16 : 14,
              ),
            ),
          ],
        ),
      );
}

class _PaymentMethods extends StatelessWidget {
  final String selected;
  final void Function(String) onSelect;
  const _PaymentMethods({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final methods = [
      ('orange_money', '🟠 Orange Money'),
      ('wave', '🔵 Wave'),
      ('card', '💳 Carte bancaire'),
    ];
    return Column(
      children: methods
          .map((m) => RadioListTile<String>(
                value: m.$1,
                groupValue: selected,
                title: Text(m.$2),
                activeColor: AppColors.primary,
                onChanged: (v) => onSelect(v!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ))
          .toList(),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final RequestStep step;
  const _StepIndicator({required this.step});

  @override
  Widget build(BuildContext context) {
    final idx = step.index;
    return LinearProgressIndicator(
      value: (idx + 1) / 3,
      backgroundColor: AppColors.border,
      valueColor:
          const AlwaysStoppedAnimation<Color>(AppColors.primary),
      minHeight: 4,
    );
  }
}
