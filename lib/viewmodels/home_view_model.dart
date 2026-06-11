import 'package:flutter/foundation.dart';
import '../models/movie.dart';
import '../models/watch_status.dart';
import '../services/movie_cache_service.dart';
import '../core/utils/logger.dart';

class HomeViewModel extends ChangeNotifier {
  final MovieCacheService _movieCacheService;

  HomeViewModel({MovieCacheService? movieCacheService})
    : _movieCacheService = movieCacheService ?? MovieCacheService();

  bool isLoading = false;
  String? errorMessage;
  List<Movie> movies = [];

  Movie? get featuredMovie {
    if (movies.isEmpty) return null;
    var topMovie = movies.first;
    var maxVal = 0.0;
    for (var m in movies) {
      final rating = double.tryParse(m.imdbRating ?? '0') ?? 0.0;
      if (rating > maxVal) {
        maxVal = rating;
        topMovie = m;
      }
    }
    return topMovie;
  }

  List<Movie> get recommendedMovies {
    var recs = movies.where((m) {
      final rating = double.tryParse(m.imdbRating ?? '0') ?? 0.0;
      return rating >= 8.0;
    }).toList();

    recs.sort((a, b) {
      final rA = double.tryParse(a.imdbRating ?? '0') ?? 0.0;
      final rB = double.tryParse(b.imdbRating ?? '0') ?? 0.0;
      return rB.compareTo(rA);
    });
    return recs;
  }

  List<Movie> get sliderMovies {
    final localToWatch = movies.where((m) => !m.isWatched).toList();
    final combined = <Movie>[];
    combined.addAll(localToWatch.reversed.take(3));

    if (combined.isEmpty && movies.isNotEmpty) {
      combined.addAll(movies.reversed.take(5));
    }

    return combined.toSet().toList();
  }

  List<Movie> get latestMovies => movies.reversed.toList();

  List<Movie> get watchedMovies =>
      movies.where((m) => m.watchStatus == WatchStatus.watched).toList();

  List<Movie> get toWatchMovies =>
      movies.where((m) => m.watchStatus == WatchStatus.toWatch).toList();

  List<Movie> get watchingMovies =>
      movies.where((m) => m.watchStatus == WatchStatus.watching).toList();

  List<Movie> get droppedMovies =>
      movies.where((m) => m.watchStatus == WatchStatus.dropped).toList();

  List<Movie> get rewatchMovies =>
      movies.where((m) => m.watchStatus == WatchStatus.rewatch).toList();

  List<Movie> get recentlyAdded {
    final sorted = [...movies];
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(15).toList();
  }

  List<Movie> get recentlyViewed {
    final viewed = movies.where((m) => m.lastViewedAt != null).toList();
    viewed.sort((a, b) => b.lastViewedAt!.compareTo(a.lastViewedAt!));
    return viewed.take(15).toList();
  }

  Future<void> init() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      movies = await _movieCacheService.getAllMovies();
    } catch (e) {
      errorMessage = e.toString();
      Logger.error('HomeViewModel init error', e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMovie(Movie movie) async {
    try {
      await _movieCacheService.saveMovie(movie);
      await init();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteMovie(String id) async {
    try {
      await _movieCacheService.deleteMovie(id);
      await init();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleWatched(Movie movie) async {
    try {
      final newStatus = movie.isWatched
          ? WatchStatus.toWatch
          : WatchStatus.watched;
      final updated = movie.copyWith(watchStatus: newStatus);
      await _movieCacheService.updateMovie(updated);
      await init();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateWatchStatus(Movie movie, WatchStatus status) async {
    try {
      int newWatchCount = movie.watchCount;
      if (status == WatchStatus.watched && movie.watchCount == 0) {
        newWatchCount = 1;
      }
      final updated = movie.copyWith(
        watchStatus: status,
        watchCount: newWatchCount,
      );
      await _movieCacheService.updateMovie(updated);
      await init();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> rateMovie() async {}
}
