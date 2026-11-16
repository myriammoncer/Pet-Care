import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/ui_kit.dart';
import '../data/password_reset_api.dart';

/// Écran « Nouveau mot de passe » : jeton reçu + nouveau mot de passe.
class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _token = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _token.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await PasswordResetApi(ref.read(dioProvider))
          .resetPassword(token: _token.text.trim(), newPassword: _password.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mot de passe réinitialisé, connecte-toi')));
      context.go('/login');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Jeton invalide ou expiré')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.scaffold,
      appBar: AppBar(title: const Text('Nouveau mot de passe')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTokens.gap),
          child: AppCard(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _token,
                    decoration: const InputDecoration(
                        labelText: 'Jeton reçu', prefixIcon: Icon(Icons.vpn_key_outlined)),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Nouveau mot de passe (min. 8)',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) => (v == null || v.length < 8) ? '8 caractères minimum' : null,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _loading ? null : _submit,
                    style: FilledButton.styleFrom(
                        backgroundColor: AppTokens.primary, minimumSize: const Size.fromHeight(48)),
                    child: _loading
                        ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Réinitialiser'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}