
import '../models/movie.dart';

class DiscoveryMovie {
  final Movie movie;
  final String recommendationReason;

  DiscoveryMovie({
    required this.movie,
    required this.recommendationReason,
  });
}

class SurveyAnswers {
  final String? mood;
  final String? genre;
  final String? duration;
  final String? companion;
  final String? period; // New / Classic

  SurveyAnswers({
    this.mood,
    this.genre,
    this.duration,
    this.companion,
    this.period,
  });

  bool get isComplete =>
      mood != null &&
      genre != null &&
      duration != null &&
      companion != null &&
      period != null;
}
