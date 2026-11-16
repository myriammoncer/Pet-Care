import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/ui_kit.dart';
import '../data/password_reset_api.dart';

/// Écran « Mot de passe oublié » : saisie de l'email → envoi d'un jeton de reset.
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _loading = false;
  bool _sent = false; // passe à true après l'envoi → affiche la confirmation

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      // On instancie l'API avec le dio global (pas de provider dédié nécessaire).
      await PasswordResetApi(ref.read(dioProvider)).forgotPassword(_email.text.trim());
      if (mounted) setState(() => _sent = true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Erreur réseau, réessaie')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.scaffold,
      appBar: AppBar(title: const Text('Mot de passe oublié')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTokens.gap),
          child: _sent ? _confirmation(context) : _form(),
        ),
      ),
    );
  }

  Widget _form() {
    return AppCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Saisis ton email : nous t’enverrons un lien de réinitialisation.',
                style: TextStyle(color: AppTokens.textMuted)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(
                  labelText: 'Email', prefixIcon: Icon(Icons.mail_outline)),
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || !v.contains('@')) ? 'Email invalide' : null,
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
                  : const Text('Envoyer le lien'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _confirmation(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          const Icon(Icons.mark_email_read_outlined, size: 48, color: AppTokens.primary),
          const SizedBox(height: 12),
          const Text('Vérifie ta boîte mail',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text(
            'Si un compte existe pour cet email, un lien de réinitialisation a été envoyé.\n\n'
                '(En développement, le jeton s’affiche dans les logs du backend.)',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTokens.textMuted),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => context.push('/reset-password'),
            style: FilledButton.styleFrom(
                backgroundColor: AppTokens.primary, minimumSize: const Size.fromHeight(48)),
            child: const Text('J’ai mon jeton → Réinitialiser'),
          ),
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Retour à la connexion'),
          ),
        ],
      ),
    );
  }
}