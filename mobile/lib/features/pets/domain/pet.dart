/// Entité métier représentant un animal de compagnie.
class Pet {
  const Pet({
    required this.id,
    required this.name,
    required this.species,
    this.breed,
    this.ageYears,
    this.sex,
    this.weight,
    this.color,
    this.photoUrl,
    this.microchipNumber,
    this.status,
  });

  final String id;
  final String name;
  final String species;
  final String? breed;
  final int? ageYears;
  final String? sex;
  final double? weight;
  final String? color;
  final String? photoUrl;
  final String? microchipNumber;
  final String? status;

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as String,
      name: json['name'] as String,
      species: json['species'] as String,
      breed: json['breed'] as String?,
      ageYears: json['ageYears'] as int?,
      sex: json['sex'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      color: json['color'] as String?,
      photoUrl: json['photoUrl'] as String?,
      microchipNumber: json['microchipNumber'] as String?,
      status: json['status'] as String?,
    );
  }
}
