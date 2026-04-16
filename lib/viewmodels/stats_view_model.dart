import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';
import '../core/utils/logger.dart';

class StatsViewModel extends ChangeNotifier {
  final MovieService _movieService = MovieService();

  List<Movie> _allMovies = [];
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Stats Data
  Map<String, double> genreRatings = {};
  List<Movie> favoritesPost2020 = [];
  Map<String, int> directorCounts = {};
  Map<String, int> actorCounts = {};
  List<Movie> watchedThisMonth = [];

  Future<void> init() async {
    await loadStats();
  }

  Future<void> loadStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allMovies = await _movieService.getMovies();
      _calculateStats();
    } catch (e, st) {
      Logger.error('Failed to calculate stats', e, st);
      _errorMessage = 'Failed to load statistics';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _calculateStats() {
    genreRatings.clear();
    favoritesPost2020.clear();
    directorCounts.clear();
    actorCounts.clear();
    watchedThisMonth.clear();

    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);

    Map<String, List<double>> genreValues = {};

    for (var m in _allMovies) {
      final rating = double.tryParse(m.imdbRating ?? '0') ?? 0.0;
      final year = int.tryParse(m.year.split('–')[0]) ?? 0;

      // Genre Ratings
      final genres = m.genre.split(', ');
      for (var g in genres) {
        genreValues.putIfAbsent(g, () => []).add(rating);
      }

      // Favorites Post 2020
      if (year >= 2020 && rating >= 7.0 && m.isWatched) {
        favoritesPost2020.add(m);
      }

      // Directors
      if (m.director != null && m.director != 'N/A') {
        final directors = m.director!.split(', ');
        for (var d in directors) {
          directorCounts[d] = (directorCounts[d] ?? 0) + 1;
        }
      }

      // Actors
      if (m.actors != null && m.actors != 'N/A') {
        final actors = m.actors!.split(', ');
        for (var a in actors) {
          actorCounts[a] = (actorCounts[a] ?? 0) + 1;
        }
      }

      // Watched this month
      if (m.isWatched && m.lastViewedAt != null && m.lastViewedAt!.isAfter(firstDayOfMonth)) {
        watchedThisMonth.add(m);
      } else if (m.isWatched && m.updatedAt.isAfter(firstDayOfMonth)) {
        // Fallback to updatedAt if lastViewedAt is null
        watchedThisMonth.add(m);
      }
    }

    // Average Genre Ratings
    genreValues.forEach((genre, ratings) {
      if (ratings.isNotEmpty) {
        genreRatings[genre] = ratings.reduce((a, b) => a + b) / ratings.length;
      }
    });

    // Sort Lists
    favoritesPost2020.sort((a, b) {
      final rA = double.tryParse(a.imdbRating ?? '0') ?? 0.0;
      final rB = double.tryParse(b.imdbRating ?? '0') ?? 0.0;
      return rB.compareTo(rA);
    });

    watchedThisMonth.sort((a, b) => (b.lastViewedAt ?? b.updatedAt).compareTo(a.lastViewedAt ?? a.updatedAt));
  }

  String get mostRatedGenre {
    if (genreRatings.isEmpty) return '-';
    var best = genreRatings.entries.first;
    for (var e in genreRatings.entries) {
      if (e.value > best.value) best = e;
    }
    return best.key;
  }
}
