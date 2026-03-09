import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/movie.dart';
import '../models/search_cache.dart';
import 'dart:convert';
import '../core/database/local_db.dart';
import '../services/movie_cache_service.dart';
import '../services/omdb_search_service.dart';
import '../services/omdb_detail_service.dart';
import '../services/poster_download_service.dart';
import '../core/utils/logger.dart';

class AddMovieViewModel extends ChangeNotifier {
  final MovieCacheService _movieCacheService;
  final OmdbSearchService _omdbSearchService;
  final OmdbDetailService _omdbDetailService;
  final PosterDownloadService _posterDownloadService;

  AddMovieViewModel({
    MovieCacheService? movieCacheService,
    OmdbSearchService? omdbSearchService,
    OmdbDetailService? omdbDetailService,
    PosterDownloadService? posterDownloadService,
  }) : _movieCacheService = movieCacheService ?? MovieCacheService(),
       _omdbSearchService = omdbSearchService ?? OmdbSearchService(),
       _omdbDetailService = omdbDetailService ?? OmdbDetailService(),
       _posterDownloadService =
           posterDownloadService ?? PosterDownloadService();

  bool isLoading = false;
  String? errorMessage;

  List<Movie> movies = [];

  Timer? _debounceTimer;

  Future<void> init() async {
    isLoading = false;
    errorMessage = null;
    movies = [];
    notifyListeners();
  }

  Future<void> searchMovies(String query) async {
    if (query.trim().length < 3) {
      // Clear results if user types less than 3 chars
      movies = [];
      errorMessage = null;
      notifyListeners();
      return;
    }

    // Debounce Logic 400ms
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 400), () async {
      await _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    isLoading = true;
    errorMessage = null;
    movies = [];
    notifyListeners();

    try {
      // 1. Check Local DB Search Cache
      final cachedResults = await _checkSearchCache(query);
      if (cachedResults.isNotEmpty) {
        movies = cachedResults;
        Logger.info('Loaded search results from cache for query: $query');
        isLoading = false;
        notifyListeners();
        return;
      }

      // 2. Fetch from Omdb Search Service
      final results = await _omdbSearchService.searchMovies(query);
      
      // OPTIMIZATION: Fetch basic details (genre/rating) for all results 
      // to avoid empty fields in the search list and provide better caching
      final List<Movie> enrichedResults = [];
      for (var movie in results.take(10)) {
        final detailed = await _omdbDetailService.getMovieDetail(movie.imdbId ?? '');
        enrichedResults.add(detailed ?? movie);
      }

      movies = enrichedResults;

      // 3. Save to Search Cache
      await _saveSearchCache(query, enrichedResults);
    } catch (e) {
      errorMessage = e.toString();
      Logger.error('AddMovieViewModel.searchMovies error', e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Movie>> _checkSearchCache(String query) async {
    try {
      final box = LocalDb.searchCacheBox;
      final lowercaseQuery = query.toLowerCase();
      final List<SearchCache> cacheItems = [];

      for (final value in box.values) {
        final jsonMap = jsonDecode(value);
        final cache = SearchCache.fromJson(jsonMap);
        if (cache.query.toLowerCase() == lowercaseQuery) {
          cacheItems.add(cache);
        }
      }

      return cacheItems
          .map(
            (c) => Movie(
              id: const Uuid().v4(), // Temporary ID for list view
              imdbId: c.imdbId,
              title: c.movieTitle,
              year: c.year,
              genre: '', // Genre is now enriched during search and stored separately in local DB if saved
              posterUrl: c.poster,
              isWatched: false,
              createdAt: c.createdAt,
              updatedAt: c.createdAt,
            ),
          )
          .toList();
    } catch (e, st) {
      Logger.error('Failed to check search cache', e, st);
      return [];
    }
  }

  Future<void> _saveSearchCache(String query, List<Movie> results) async {
    try {
      final box = LocalDb.searchCacheBox;

      for (final movie in results) {
        if (movie.imdbId == null) continue;

        final cache = SearchCache(
          query: query,
          movieTitle: movie.title,
          poster: movie.posterUrl,
          year: movie.year,
          imdbId: movie.imdbId!,
          createdAt: DateTime.now(),
        );

        await box.put('${query}_${movie.imdbId}', jsonEncode(cache.toJson()));
      }
    } catch (e, st) {
      Logger.error('Failed to save search cache', e, st);
    }
  }

  Future<bool> selectAndSaveMovie(Movie searchResult) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (searchResult.imdbId == null) {
        throw Exception('Invalid IMDB ID');
      }

      // 1. Check local DB
      final localMovie = await _movieCacheService.getMovieByImdbId(
        searchResult.imdbId!,
      );
      if (localMovie != null) {
        Logger.info('Movie already exists in cache');
        isLoading = false;
        notifyListeners();
        return true; // Already saved
      }

      // 2. Not in local DB, fetch details via new service
      final detailedMovie = await _omdbDetailService.getMovieDetail(
        searchResult.imdbId!,
      );
      if (detailedMovie == null) {
        throw Exception('Could not fetch movie details');
      }

      // 3. Download poster
      String? localPosterPath;
      if (detailedMovie.posterUrl != null) {
        localPosterPath = await _posterDownloadService.downloadPoster(
          detailedMovie.posterUrl!,
        );
      }

      // 4. Save to local DB
      final finalMovie = detailedMovie.copyWith(
        id: const Uuid().v4(),
        posterLocalPath: localPosterPath,
        isWatched: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _movieCacheService.saveMovie(finalMovie);
      Logger.info('Movie fetched and saved to cache');

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      Logger.error('AddMovieViewModel.selectAndSaveMovie error', e);
      notifyListeners();
      return false;
    }
  }

  Future<void> addMovie() async {}
  Future<void> deleteMovie(String id) async {}
  Future<void> rateMovie() async {}
  Future<void> toggleWatched(Movie movie) async {}

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
