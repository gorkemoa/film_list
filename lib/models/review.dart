class Review {
  final String id;
  final String movieId;
  final int storyRating;
  final int musicRating;
  final int actingRating;
  final int cinematographyRating;
  final double overallRating;
  final bool recommend;
  final bool watchAgain;
  final DateTime reviewDate;
  final String? comment;

  Review({
    required this.id,
    required this.movieId,
    required this.storyRating,
    required this.musicRating,
    required this.actingRating,
    required this.cinematographyRating,
    required this.overallRating,
    required this.recommend,
    required this.watchAgain,
    required this.reviewDate,
    this.comment,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      movieId: json['movie_id'] as String,
      storyRating: json['story_rating'] as int,
      musicRating: json['music_rating'] as int,
      actingRating: json['acting_rating'] as int,
      cinematographyRating: json['cinematography_rating'] as int,
      overallRating: (json['overall_rating'] as num).toDouble(),
      recommend: json['recommend'] == 1 || json['recommend'] == true,
      watchAgain: json['watch_again'] == 1 || json['watch_again'] == true,
      reviewDate: DateTime.parse(json['review_date'] as String),
      comment: json['comment'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movie_id': movieId,
      'story_rating': storyRating,
      'music_rating': musicRating,
      'acting_rating': actingRating,
      'cinematography_rating': cinematographyRating,
      'overall_rating': overallRating,
      'recommend': recommend ? 1 : 0,
      'watch_again': watchAgain ? 1 : 0,
      'review_date': reviewDate.toIso8601String(),
      'comment': comment,
    };
  }
}
