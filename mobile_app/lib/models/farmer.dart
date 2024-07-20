class Farmer {
  final int id;
  final String name;
  final String contact;
  final String location;
  final String createdAt;
  final String? updatedAt;

  Farmer(
      {required this.id,
      required this.name,
      required this.contact,
      required this.location,
      required this.createdAt,
      this.updatedAt});

  factory Farmer.fromSqfliteDatabase(Map<String, dynamic> map) => Farmer(
        id: map['id']?.toInt() ?? 0,
        name: map['name'] ?? '',
        contact: map['contact'] ?? '',
        location: map['location'] ?? '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
            .toIso8601String(),
        updatedAt: map['updatedAt'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
                .toIso8601String(),
      );
}