import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _formKey   = GlobalKey<FormState>();
  bool _loading    = false;
  String? _error;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (mounted) context.go('/dashboard');
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _msg(e.code));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _msg(String code) => switch (code) {
    'user-not-found'  => 'Aucun compte trouvé pour cet email.',
    'wrong-password'  => 'Mot de passe incorrect.',
    'invalid-email'   => 'Email invalide.',
    'too-many-requests' => 'Trop de tentatives. Réessayez plus tard.',
    _ => 'Erreur de connexion. Réessayez.',
  };

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AdminColors.dark,
        body: Center(
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AdminColors.sidebar,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AdminColors.border),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      color: AdminColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text('🚗', style: TextStyle(fontSize: 32)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Auto-SOS Admin',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700,
                          color: AdminColors.textLight)),
                  const SizedBox(height: 4),
                  const Text('Oyop MT — Tableau de bord',
                      style: TextStyle(color: AdminColors.textMuted, fontSize: 13)),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Email administrateur',
                      prefixIcon: Icon(Icons.email_outlined, color: AdminColors.textMuted),
                    ),
                    style: const TextStyle(color: AdminColors.textLight),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v == null || !v.contains('@') ? 'Email invalide' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Mot de passe',
                      prefixIcon: Icon(Icons.lock_outline, color: AdminColors.textMuted),
                    ),
                    style: const TextStyle(color: AdminColors.textLight),
                    obscureText: true,
                    validator: (v) => v == null || v.length < 6 ? 'Minimum 6 caractères' : null,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AdminColors.error.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(children: [
                        const Icon(Icons.error_outline, color: AdminColors.error, size: 16),
                        const SizedBox(width: 8),
                        Text(_error!, style: const TextStyle(color: AdminColors.error, fontSize: 13)),
                      ]),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? const SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Se connecter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
