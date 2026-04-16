class CustomList {
  final String id;
  final String name;
  final List<String> movieIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomList({
    required this.id,
    required this.name,
    required this.movieIds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomList.fromJson(Map<String, dynamic> json) {
    return CustomList(
      id: json['id'] as String,
      name: json['name'] as String,
      movieIds: (json['movie_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'movie_ids': movieIds,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  CustomList copyWith({
    String? id,
    String? name,
    List<String>? movieIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomList(
      id: id ?? this.id,
      name: name ?? this.name,
      movieIds: movieIds ?? this.movieIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
