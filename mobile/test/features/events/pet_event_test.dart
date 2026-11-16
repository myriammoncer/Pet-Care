import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/features/events/domain/pet_event.dart';

Map<String, dynamic> _json({
  required DateTime startAt,
  int capacity = 10,
  int registeredCount = 3,
  bool full = false,
  bool registered = false,
  String? myPetId,
}) =>
    {
      'id': 'evt1',
      'title': 'Promenade',
      'type': 'GROUP_WALK',
      'startAt': startAt.toUtc().toIso8601String(),
      'endAt': startAt.add(const Duration(hours: 2)).toUtc().toIso8601String(),
      'location': 'Parc',
      'capacity': capacity,
      'registeredCount': registeredCount,
      'full': full,
      'registered': registered,
      'myPetId': myPetId,
    };

void main() {
  final future = DateTime.now().add(const Duration(days: 2));
  final past = DateTime.now().subtract(const Duration(days: 1));

  test('fromJson lit les champs du backend', () {
    final e = PetEvent.fromJson(_json(startAt: future, registered: true, myPetId: 'pet1'));
    expect(e.id, 'evt1');
    expect(e.type, 'GROUP_WALK');
    expect(e.endAt, isNotNull);
    expect(e.registered, isTrue);
    expect(e.myPetId, 'pet1');
    expect(e.remainingSpots, 7);
    expect(e.fillRatio, closeTo(0.3, 0.001));
  });

  test('inscription possible seulement si à venir, non complet et non inscrit', () {
    expect(PetEvent.fromJson(_json(startAt: future)).canRegister, isTrue);
    expect(PetEvent.fromJson(_json(startAt: future, full: true, registeredCount: 10)).canRegister, isFalse);
    expect(PetEvent.fromJson(_json(startAt: future, registered: true)).canRegister, isFalse);
    expect(PetEvent.fromJson(_json(startAt: past)).canRegister, isFalse);
  });

  test('désinscription possible seulement si inscrit et pas commencé', () {
    expect(PetEvent.fromJson(_json(startAt: future, registered: true)).canUnregister, isTrue);
    expect(PetEvent.fromJson(_json(startAt: past, registered: true)).canUnregister, isFalse);
    expect(PetEvent.fromJson(_json(startAt: future)).canUnregister, isFalse);
  });

  test('participant : champs optionnels tolérés', () {
    final p = EventParticipant.fromJson({'userId': 'u1', 'petId': 'p1'});
    expect(p.userName, isNull);
    expect(p.registeredAt, isNull);
  });
}
