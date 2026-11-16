import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/user_profile.dart';
import 'profile_controller.dart';

/// Écran « Profil » : en-tête utilisateur, rôles, coordonnées, et zone de danger
/// (déconnexion). Inspiré de la maquette « Profil & Gestion ».
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileControllerProvider);

    return Scaffold(
      backgroundColor: AppTokens.scaffold,
      appBar: AppBar(title: const Text('Profil')),
      body: AsyncView<UserProfile>(
        value: profileAsync,
        onRetry: () => ref.read(profileControllerProvider.notifier).refresh(),
        data: (profile) => RefreshIndicator(
          onRefresh: () => ref.read(profileControllerProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.all(AppTokens.gap),
            children: [
              _HeroCard(profile: profile),
              const SizedBox(height: AppTokens.gap),

              const SectionHeader('Rôles'),
              _RolesCard(roles: profile.roles),
              const SizedBox(height: AppTokens.gap),

              SectionHeader(
                'Informations personnelles',
                trailing: TextButton.icon(
                  onPressed: () => context.push('/profile/edit'),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Modifier'),
                ),
              ),
              _InfoCard(profile: profile),
              const SizedBox(height: AppTokens.gap * 1.5),

              _DangerZone(
                onLogout: () => _confirmLogout(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Boîte de dialogue de confirmation avant déconnexion.
  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        content: const Text('Tu devras te reconnecter pour accéder à ton compte.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTokens.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
    if (ok == true) {
      // Réutilise la logique d'auth existante : vide les tokens → le routeur
      // redirige automatiquement vers /login (refreshListenable).
      await ref.read(authControllerProvider).logout();
    }
  }
}

/// En-tête : avatar, nom, email, puce « rôle principal ».
class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(profile.firstName, profile.lastName);
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppTokens.mint,
            child: Text(initials,
                style: const TextStyle(color: AppTokens.primary, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: AppTokens.gap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.fullName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(profile.email,
                    style: const TextStyle(color: AppTokens.textMuted, fontSize: 13)),
                const SizedBox(height: 8),
                StatusChip(_roleLabel(profile.roles.isNotEmpty ? profile.roles.first : '—')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String f, String l) {
    final a = f.isNotEmpty ? f[0] : '';
    final b = l.isNotEmpty ? l[0] : '';
    final res = (a + b).toUpperCase();
    return res.isEmpty ? '?' : res;
  }
}

/// Liste des rôles sous forme de puces menthe.
class _RolesCard extends StatelessWidget {
  const _RolesCard({required this.roles});
  final List<String> roles;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (roles.isEmpty)
            const Text('Aucun rôle', style: TextStyle(color: AppTokens.textMuted))
          else
            for (final r in roles) StatusChip(_roleLabel(r)),
        ],
      ),
    );
  }
}

/// Coordonnées (téléphone + email) en lignes avec icône.
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _InfoRow(icon: Icons.person_outline, label: 'Nom complet', value: profile.fullName),
          const Divider(height: 1),
          _InfoRow(icon: Icons.mail_outline, label: 'Email', value: profile.email),
          const Divider(height: 1),
          _InfoRow(
            icon: Icons.phone_outlined,
            label: 'Téléphone',
            value: (profile.phone?.isNotEmpty ?? false) ? profile.phone! : 'Non renseigné',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppTokens.mint,
        child: Icon(icon, color: AppTokens.primary, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontSize: 12, color: AppTokens.textMuted)),
      subtitle: Text(value, style: const TextStyle(fontSize: 15, color: Colors.black87)),
    );
  }
}

/// Zone de danger : bouton de déconnexion rouge sur fond rosé.
class _DangerZone extends StatelessWidget {
  const _DangerZone({required this.onLogout});
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTokens.dangerTint,
        borderRadius: BorderRadius.circular(AppTokens.radius),
      ),
      padding: const EdgeInsets.all(AppTokens.gap),
      child: Column(
        children: [
          OutlinedButton.icon(
            onPressed: onLogout,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTokens.danger,
              side: const BorderSide(color: AppTokens.danger),
              minimumSize: const Size.fromHeight(48),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Se déconnecter du compte'),
          ),
        ],
      ),
    );
  }
}

/// Traduit un code de rôle en libellé lisible (partagé par les widgets ci-dessus).
String _roleLabel(String role) {
  switch (role) {
    case 'ADMIN':
      return 'Administrateur';
    case 'VET':
      return 'Vétérinaire';
    case 'PET_OWNER':
      return "Propriétaire d'animal";
    default:
      return role;
  }
}