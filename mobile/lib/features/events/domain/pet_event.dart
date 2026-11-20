/// Entité métier d'un événement communautaire (sans dépendance Flutter).
class PetEvent {
  const PetEvent({
    required this.id,
    required this.title,
    required this.type,
    required this.startAt,
    required this.location,
    required this.capacity,
    required this.registeredCount,
    required this.full,
    required this.registered,
    this.description,
    this.endAt,
    this.myPetId,
    this.createdBy,
  });

  final String id;
  final String title;
  final String? description;
  final String type; // GROUP_WALK, BEAUTY_CONTEST, HEALTH_DAY, ADOPTION, TRAINING_WORKSHOP
  final DateTime startAt;
  final DateTime? endAt;
  final String location;
  final int capacity;
  final int registeredCount;
  final bool full;

  /// L'utilisateur courant est inscrit (calculé par le backend).
  final bool registered;

  /// Animal avec lequel l'utilisateur courant est inscrit.
  final String? myPetId;
  final String? createdBy;

  int get remainingSpots => (capacity - registeredCount).clamp(0, capacity);

  /// Taux de remplissage entre 0 et 1.
  double get fillRatio => capacity <= 0 ? 1 : (registeredCount / capacity).clamp(0, 1).toDouble();

  bool hasStarted([DateTime? now]) => !startAt.isAfter(now ?? DateTime.now());

  /// Inscription possible : pas commencé, pas complet, pas déjà inscrit.
  bool get canRegister => !hasStarted() && !full && !registered;

  /// Désinscription possible : inscrit et pas encore commencé.
  bool get canUnregister => registered && !hasStarted();

  factory PetEvent.fromJson(Map<String, dynamic> json) {
    return PetEvent(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      type: json['type'] as String? ?? '',
      startAt: DateTime.parse(json['startAt'] as String),
      endAt: json['endAt'] == null ? null : DateTime.parse(json['endAt'] as String),
      location: json['location'] as String? ?? '',
      capacity: (json['capacity'] as num?)?.toInt() ?? 0,
      registeredCount: (json['registeredCount'] as num?)?.toInt() ?? 0,
      full: json['full'] as bool? ?? false,
      registered: json['registered'] as bool? ?? false,
      myPetId: json['myPetId'] as String?,
      createdBy: json['createdBy'] as String?,
    );
  }
}

/// Participant d'un événement (vue admin).
class EventParticipant {
  const EventParticipant({
    required this.userId,
    required this.petId,
    this.userName,
    this.userEmail,
    this.petName,
    this.registeredAt,
  });

  final String userId;
  final String? userName;
  final String? userEmail;
  final String petId;
  final String? petName;
  final DateTime? registeredAt;

  factory EventParticipant.fromJson(Map<String, dynamic> json) {
    return EventParticipant(
      userId: json['userId'] as String,
      userName: json['userName'] as String?,
      userEmail: json['userEmail'] as String?,
      petId: json['petId'] as String? ?? '',
      petName: json['petName'] as String?,
      registeredAt: json['registeredAt'] == null
          ? null
          : DateTime.parse(json['registeredAt'] as String),
    );
  }
}
