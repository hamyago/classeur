import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';

class PhoneAuthScreen extends StatefulWidget {
  final bool isProvider;
  const PhoneAuthScreen({super.key, this.isProvider = false});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  String _phoneNumber = '';
  bool _valid = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go('/onboarding'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('📱', style: TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Votre numéro',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.isProvider
                      ? 'Entrez le numéro de votre compte prestataire.'
                      : 'Entrez votre numéro de téléphone pour continuer.',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                IntlPhoneField(
                  decoration: const InputDecoration(
                    labelText: 'Numéro de téléphone',
                    hintText: '07 00 00 00 00',
                  ),
                  initialCountryCode: 'CI',
                  onChanged: (phone) {
                    _phoneNumber = phone.completeNumber;
                    _valid = phone.isValidNumber();
                    setState(() {});
                  },
                ),
                if (auth.error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            auth.error!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Spacer(),
                AppButton(
                  label: 'Recevoir le code',
                  isLoading: auth.isLoading,
                  enabled: _valid,
                  onPressed: () async {
                    await auth.sendOtp(_phoneNumber);
                    if (!mounted) return;
                    if (auth.error == null) {
                      context.go(
                        '/auth/otp',
                        extra: {
                          'phone': _phoneNumber,
                          'isProvider': widget.isProvider,
                        },
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Un code à 6 chiffres sera envoyé par SMS.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
