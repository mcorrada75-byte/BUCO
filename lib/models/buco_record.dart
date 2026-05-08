import 'dart:convert';

/// Modello di un buco salvato.
class BucoRecord {
  final int? id;
  final String title;
  final String description;
  final double? latitude;
  final double? longitude;
  final List<String> photos; // percorsi file locali
  final DateTime createdAt;
  final DateTime updatedAt;

  const BucoRecord({
    this.id,
    required this.title,
    required this.description,
    this.latitude,
    this.longitude,
    required this.photos,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get hasLocation => latitude != null && longitude != null;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'photos': jsonEncode(photos),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory BucoRecord.fromMap(Map<String, dynamic> map) => BucoRecord(
        id: map['id'] as int?,
        title: (map['title'] as String?) ?? 'Buco senza titolo',
        description: (map['description'] as String?) ?? '',
        latitude: map['latitude'] == null
            ? null
            : (map['latitude'] as num).toDouble(),
        longitude: map['longitude'] == null
            ? null
            : (map['longitude'] as num).toDouble(),
        photos: List<String>.from(
          jsonDecode((map['photos'] as String?) ?? '[]') as List,
        ),
        createdAt: DateTime.tryParse((map['createdAt'] as String?) ?? '') ??
            DateTime.now(),
        updatedAt: DateTime.tryParse((map['updatedAt'] as String?) ?? '') ??
            DateTime.now(),
      );

  BucoRecord copyWith({
    int? id,
    String? title,
    String? description,
    double? latitude,
    double? longitude,
    List<String>? photos,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      BucoRecord(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        photos: photos ?? this.photos,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
