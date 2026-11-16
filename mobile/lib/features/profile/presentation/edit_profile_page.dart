import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_tokens.dart';
import 'profile_controller.dart';

/// Formulaire d'édition du profil (prénom, nom, téléphone).
/// Pré-rempli avec les valeurs actuelles, puis PUT /users/me à la validation.
class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _phone;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Pré-remplit depuis l'état déjà chargé (valueOrNull : null si pas encore prêt).
    final current = ref.read(profileControllerProvider).valueOrNull;
    _firstName = TextEditingController(text: current?.firstName ?? '');
    _lastName = TextEditingController(text: current?.lastName ?? '');
    _phone = TextEditingController(text: current?.phone ?? '');
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(profileControllerProvider.notifier).updateProfile(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        phone: _phone.text.trim(),
      );
      if (!mounted) return;
      // Retour à l'écran Profil + petit message de succès.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour')),
      );
      context.pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Échec de la mise à jour, réessaie')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.scaffold,
      appBar: AppBar(title: const Text('Modifier le profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTokens.gap),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _firstName,
                decoration: const InputDecoration(labelText: 'Prénom'),
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: AppTokens.gap),
              TextFormField(
                controller: _lastName,
                decoration: const InputDecoration(labelText: 'Nom'),
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: AppTokens.gap),
              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(
                  labelText: 'Téléphone (optionnel)',
                  hintText: '+216 ...',
                ),
                keyboardType: TextInputType.phone,
                // Validation souple : si rempli, au moins 6 caractères.
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null; // optionnel
                  return v.trim().length < 6 ? 'Numéro trop court' : null;
                },
              ),
              const SizedBox(height: AppTokens.gap * 1.5),
              FilledButton(
                onPressed: _saving ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTokens.primary,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: _saving
                    ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}