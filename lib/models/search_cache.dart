class SearchCache {
  final String query;
  final String movieTitle;
  final String? poster;
  final String year;
  final String imdbId;
  final DateTime createdAt;

  SearchCache({
    required this.query,
    required this.movieTitle,
    this.poster,
    required this.year,
    required this.imdbId,
    required this.createdAt,
  });

  factory SearchCache.fromJson(Map<String, dynamic> json) {
    return SearchCache(
      query: json['query'] as String,
      movieTitle: json['movie_title'] as String,
      poster: json['poster'] as String?,
      year: json['year'] as String,
      imdbId: json['imdb_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'movie_title': movieTitle,
      'poster': poster,
      'year': year,
      'imdb_id': imdbId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
