import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/ui_kit.dart';
import 'auth_controller.dart';

/// Écran de connexion — style maquette (fond clair, carte blanche, vert soin).
/// La LOGIQUE est inchangée : on appelle toujours AuthController.login().
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true; // afficher / masquer le mot de passe

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Valide le formulaire avant d'appeler le réseau.
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider).login(_email.text.trim(), _password.text);
  }

  @override
  Widget build(BuildContext context) {
    // On observe l'état d'auth (loading / error) pour réagir dans l'UI.
    final state = ref.watch(authControllerProvider).state;
    return Scaffold(
      backgroundColor: AppTokens.scaffold,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTokens.gap),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Logo dans une pastille menthe ──
                Container(
                  width: 84,
                  height: 84,
                  decoration: const BoxDecoration(color: AppTokens.mint, shape: BoxShape.circle),
                  child: const Icon(Icons.pets, size: 42, color: AppTokens.primary),
                ),
                const SizedBox(height: 16),
                const Text('Bon retour',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                const Text('Connecte-toi à ton espace Pet-Care',
                    style: TextStyle(color: AppTokens.textMuted)),
                const SizedBox(height: 24),

                // ── Carte blanche contenant le formulaire ──
                AppCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _email,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.mail_outline),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) =>
                          (v == null || !v.contains('@')) ? 'Email invalide' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _password,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            prefixIcon: const Icon(Icons.lock_outline),
                            // Bouton œil pour afficher / masquer le mot de passe.
                            suffixIcon: IconButton(
                              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
                        ),

                        // ── Bandeau d'erreur (fond rosé) si l'auth a échoué ──
                        if (state.error != null) ...[
                          const SizedBox(height: 12),
                          _ErrorBanner(state.error!),
                        ],

                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: state.loading ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTokens.primary,
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: state.loading
                              ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                              : const Text('Se connecter'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Lien vers l'inscription ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Pas encore de compte ?',
                        style: TextStyle(color: AppTokens.textMuted)),
                    TextButton(
                      onPressed: () => context.go('/signup'),
                      child: const Text('Créer un compte'),
                    ),
                  ],
                ),
                // NOTE : le lien « Mot de passe oublié ? » sera ajouté ici en Fonctionnalité 2.
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bandeau d'erreur réutilisé (fond rosé + icône). Privé à ce fichier.
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTokens.dangerTint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTokens.danger, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(color: AppTokens.danger))),
        ],
      ),
    );
  }
}