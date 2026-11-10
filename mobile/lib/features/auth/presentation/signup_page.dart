import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/ui_kit.dart';
import 'auth_controller.dart';

/// Écran d'inscription — style maquette. Logique inchangée (AuthController.signup()).
class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String _role = 'PET_OWNER'; // rôle choisi par défaut
  bool _obscure = true;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider).signup(
      email: _email.text.trim(),
      password: _password.text,
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      role: _role,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider).state;
    return Scaffold(
      backgroundColor: AppTokens.scaffold,
      appBar: AppBar(title: const Text('Inscription')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTokens.gap),
          child: Column(
            children: [
              const SizedBox(height: 8),
              // ── Pastille logo ──
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(color: AppTokens.mint, shape: BoxShape.circle),
                child: const Icon(Icons.pets, size: 36, color: AppTokens.primary),
              ),
              const SizedBox(height: 12),
              const Text('Créer ton compte',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),

              // ── Carte blanche contenant le formulaire ──
              AppCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _firstName,
                        decoration: const InputDecoration(
                          labelText: 'Prénom',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _lastName,
                        decoration: const InputDecoration(
                          labelText: 'Nom',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
                      ),
                      const SizedBox(height: 16),
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
                          labelText: 'Mot de passe (min. 8 caractères)',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) =>
                        (v == null || v.length < 8) ? '8 caractères minimum' : null,
                      ),
                      const SizedBox(height: 16),
                      // ── Choix du rôle (le projet autorise PET_OWNER ou VET à l'inscription) ──
                      DropdownButtonFormField<String>(
                        initialValue: _role,
                        decoration: const InputDecoration(
                          labelText: 'Je suis',
                          prefixIcon: Icon(Icons.workspace_premium_outlined),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'PET_OWNER', child: Text("Propriétaire d'animal")),
                          DropdownMenuItem(value: 'VET', child: Text('Vétérinaire')),
                        ],
                        onChanged: (v) => setState(() => _role = v ?? 'PET_OWNER'),
                      ),

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
                            : const Text('Créer mon compte'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Lien vers la connexion ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("J'ai déjà un compte", style: TextStyle(color: AppTokens.textMuted)),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Se connecter'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bandeau d'erreur (copie locale — même rendu que sur l'écran de connexion).
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