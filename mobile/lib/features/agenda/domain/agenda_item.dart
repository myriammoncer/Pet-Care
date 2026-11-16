/// Entité métier d'un élément d'agenda (rappel / rendez-vous de soin).
class AgendaItem {
  const AgendaItem({
    required this.id,
    required this.petId,
    required this.type,
    required this.title,
    required this.scheduledAt,
    required this.status,
    this.notes,
    this.reminderAt,
    this.recurrence,
    this.vetName,
    this.location,
    this.durationMinutes,
    this.urgent = false,
  });

  final String id;
  final String petId;
  final String type;        // VACCINATION, DEWORMING, MEDICATION, VET_APPOINTMENT, GROOMING
  final String title;
  final DateTime scheduledAt;
  final String status;      // SCHEDULED, DONE, MISSED, CANCELLED
  final String? notes;
  final DateTime? reminderAt;
  final String? recurrence; // EVERY_WEEK, EVERY_MONTH, EVERY_3_MONTHS, EVERY_6_MONTHS, EVERY_YEAR
  final String? vetName;
  final String? location;
  final int? durationMinutes;
  final bool urgent;

  factory AgendaItem.fromJson(Map<String, dynamic> json) {
    return AgendaItem(
      id: json['id'] as String,
      petId: json['petId'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      reminderAt: json['reminderAt'] == null
          ? null
          : DateTime.parse(json['reminderAt'] as String),
      recurrence: json['recurrence'] as String?,
      vetName: json['vetName'] as String?,
      location: json['location'] as String?,
      durationMinutes: json['durationMinutes'] as int?,
      urgent: json['urgent'] as bool? ?? false,
    );
  }
}