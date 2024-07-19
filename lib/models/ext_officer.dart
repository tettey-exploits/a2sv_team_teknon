class ExtensionOfficer {
  final int id;
  final String name;
  final String email;
  final String location;
  final String imagePath;
  final String createdAt;
  final String? updatedAt;

  ExtensionOfficer(
      {required this.id,
      required this.name,
      required this.email,
      required this.location,
      required this.imagePath,
      required this.createdAt,
      this.updatedAt});

  factory ExtensionOfficer.fromSqfliteDatabase(Map<String, dynamic> map) =>
      ExtensionOfficer(
        email: map['email'] ?? '',
        location: map['location'] ?? '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
            .toIso8601String(),
        imagePath: map['imagePath'] ?? '',
        id: map['id']?.toInt() ?? 0,
        name: map['name'] ?? '',
        updatedAt: map['updatedAt'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
                .toIso8601String(),
      );
}
