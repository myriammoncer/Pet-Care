/// Profil utilisateur (entité de domaine, SANS dépendance Flutter → testable).
///
/// Représente la réponse de `GET /users/me`. On garde les rôles sous forme de
/// liste de chaînes (ex. ["PET_OWNER"]) comme le fait déjà `AuthUser`.
class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.roles,
    this.phone,
    this.enabled = true,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;      // optionnel (peut être null côté API)
  final List<String> roles;
  final bool enabled;

  /// Nom complet affiché dans l'en-tête du profil.
  String get fullName => '$firstName $lastName'.trim();

  bool get isAdmin => roles.contains('ADMIN');
  bool get isVet => roles.contains('VET');
  bool get isOwner => roles.contains('PET_OWNER');

  /// Construit l'entité à partir du JSON `data` renvoyé par l'API.
  /// (L'enveloppe { success, data } est déballée dans la couche data.)
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      phone: json['phone'] as String?,
      roles: (json['roles'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      enabled: json['enabled'] as bool? ?? true,
    );
  }
}