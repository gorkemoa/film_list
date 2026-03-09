import 'package:flutter/foundation.dart';
import '../models/movie.dart';
import '../services/movie_cache_service.dart';
import '../services/discovery_service.dart';
import '../core/utils/logger.dart';

class HomeViewModel extends ChangeNotifier {
  final MovieCacheService _movieCacheService;
  final DiscoveryService _discoveryService;

  HomeViewModel({
    MovieCacheService? movieCacheService,
    DiscoveryService? discoveryService,
  }) : _movieCacheService = movieCacheService ?? MovieCacheService(),
       _discoveryService = discoveryService ?? DiscoveryService();

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

    if (recs.isEmpty && _suggestions.isNotEmpty) {
      // Use suggestions that aren't already in the slider (slider takes up to 5)
      return _suggestions.skip(movies.isEmpty ? 5 : 3).take(10).toList();
    }

    recs.sort((a, b) {
      final rA = double.tryParse(a.imdbRating ?? '0') ?? 0.0;
      final rB = double.tryParse(b.imdbRating ?? '0') ?? 0.0;
      return rB.compareTo(rA);
    });
    return recs;
  }

  List<Movie> get sliderMovies {
    // Priority: Combinining "To Watch" (unwatched in local DB) and "Suggestions"
    final localToWatch = movies.where((m) => !m.isWatched).toList();

    List<Movie> combined = [];

    // Add up to 3 local "To Watch" movies (prioritize newest)
    combined.addAll(localToWatch.reversed.take(3));

    // Add up to 3 high-rated suggestions from DiscoveryService
    // These are already sorted or representative
    if (_suggestions.isNotEmpty) {
      combined.addAll(_suggestions.take(3));
    }

    // fallback if still too short and we have local movies
    if (combined.isEmpty && movies.isNotEmpty) {
      combined = movies.reversed.take(5).toList();
    }

    // fallback for empty case (initial state)
    if (combined.isEmpty && _suggestions.isNotEmpty) {
      combined = _suggestions.take(5).toList();
    }

    return combined.toSet().toList(); // Ensure unique movies
  }

  List<Movie> _suggestions = [];

  List<Movie> get latestMovies {
    return movies.reversed.toList();
  }

  List<Movie> get watchedMovies {
    return movies.where((m) => m.isWatched).toList();
  }

  List<Movie> get toWatchMovies {
    return movies.where((m) => !m.isWatched).toList();
  }

  Future<void> init() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      movies = await _movieCacheService.getAllMovies();
      _suggestions = await _discoveryService.getSuggestions();
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
      final updated = movie.copyWith(isWatched: !movie.isWatched);
      await _movieCacheService.updateMovie(updated);
      await init();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> rateMovie() async {}
}
