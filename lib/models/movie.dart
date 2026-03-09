import 'rating.dart';

class Movie {
  final String id;
  final String? imdbId;
  final String title;
  final String year;
  final String? runtime;
  final String genre;
  final String? awards;
  final String? posterUrl;
  final String? posterLocalPath;
  final String? imdbRating;
  final String? imdbVotes;
  final String? metascore;
  final List<Rating> ratings;
  final bool isWatched;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? type; // Keeping type to not crash existing UI
  final int watchCount;

  Movie({
    required this.id,
    this.imdbId,
    required this.title,
    required this.year,
    this.runtime,
    required this.genre,
    this.awards,
    this.posterUrl,
    this.posterLocalPath,
    this.imdbRating,
    this.imdbVotes,
    this.metascore,
    this.ratings = const [],
    required this.isWatched,
    required this.createdAt,
    required this.updatedAt,
    this.type,
    this.watchCount = 0,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as String,
      imdbId: json['imdb_id'] as String?,
      title: json['title'] as String,
      year: json['year'].toString(),
      runtime: json['runtime'] as String?,
      genre: json['genre'] as String,
      awards: json['awards'] as String?,
      posterUrl: json['poster_url'] as String?,
      posterLocalPath: json['poster_local_path'] as String?,
      imdbRating: json['imdb_rating'] as String?,
      imdbVotes: json['imdb_votes'] as String?,
      metascore: json['metascore'] as String?,
      ratings:
          (json['ratings'] as List<dynamic>?)
              ?.map((e) => Rating.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isWatched: json['is_watched'] == 1 || json['is_watched'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      type: json['type'] as String?,
      watchCount:
          json['watch_count'] as int? ??
          (json['is_watched'] == 1 || json['is_watched'] == true ? 1 : 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imdb_id': imdbId,
      'title': title,
      'year': year,
      'runtime': runtime,
      'genre': genre,
      'awards': awards,
      'poster_url': posterUrl,
      'poster_local_path': posterLocalPath,
      'imdb_rating': imdbRating,
      'imdb_votes': imdbVotes,
      'metascore': metascore,
      'ratings': ratings.map((e) => e.toJson()).toList(),
      'is_watched': isWatched ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'type': type,
      'watch_count': watchCount,
    };
  }

  Movie copyWith({
    String? id,
    String? imdbId,
    String? title,
    String? year,
    String? runtime,
    String? genre,
    String? awards,
    String? posterUrl,
    String? posterLocalPath,
    String? imdbRating,
    String? imdbVotes,
    String? metascore,
    List<Rating>? ratings,
    bool? isWatched,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? type,
    int? watchCount,
  }) {
    return Movie(
      id: id ?? this.id,
      imdbId: imdbId ?? this.imdbId,
      title: title ?? this.title,
      year: year ?? this.year,
      runtime: runtime ?? this.runtime,
      genre: genre ?? this.genre,
      awards: awards ?? this.awards,
      posterUrl: posterUrl ?? this.posterUrl,
      posterLocalPath: posterLocalPath ?? this.posterLocalPath,
      imdbRating: imdbRating ?? this.imdbRating,
      imdbVotes: imdbVotes ?? this.imdbVotes,
      metascore: metascore ?? this.metascore,
      ratings: ratings ?? this.ratings,
      isWatched: isWatched ?? this.isWatched,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
      watchCount: watchCount ?? this.watchCount,
    );
  }
}
