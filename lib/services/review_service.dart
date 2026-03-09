import 'dart:convert';
import '../models/review.dart';
import '../core/database/local_db.dart';
import '../core/utils/logger.dart';

class ReviewService {
  Future<Review?> getReviewByMovieId(String movieId) async {
    try {
      final box = LocalDb.reviewBox;
      for (final value in box.values) {
        final Map<String, dynamic> jsonMap = jsonDecode(value);
        if (jsonMap['movie_id'] == movieId) {
          return Review.fromJson(jsonMap);
        }
      }
      return null;
    } catch (e, st) {
      Logger.error('Failed to get review for movie: $movieId', e, st);
      return null;
    }
  }

  Future<void> addReview(Review review) async {
    try {
      final box = LocalDb.reviewBox;
      // Using movieId as key to ensure 1 review per movie, or review.id
      await box.put(review.id, jsonEncode(review.toJson()));
      Logger.info('Review added for movie: ${review.movieId}');
    } catch (e, st) {
      Logger.error('Failed to add review', e, st);
      throw Exception('Failed to add review');
    }
  }
}
