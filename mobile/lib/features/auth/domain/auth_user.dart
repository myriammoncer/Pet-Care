/// Utilisateur authentifié (entité de domaine, sans dépendance framework).
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.roles,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final List<String> roles;

  bool get isAdmin => roles.contains('ADMIN');
  bool get isVet => roles.contains('VET');
  bool get isOwner => roles.contains('PET_OWNER');
}
