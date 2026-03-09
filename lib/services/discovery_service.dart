import 'dart:math';
import '../models/movie.dart';
import 'omdb_detail_service.dart';
import 'omdb_search_service.dart';
import 'movie_cache_service.dart';
import '../core/utils/logger.dart';

class DiscoveryService {
  final OmdbDetailService _omdbDetailService;
  final OmdbSearchService _omdbSearchService;
  final MovieCacheService _movieCacheService;

  DiscoveryService({
    OmdbDetailService? omdbDetailService,
    OmdbSearchService? omdbSearchService,
    MovieCacheService? movieCacheService,
  }) : _omdbDetailService = omdbDetailService ?? OmdbDetailService(),
       _omdbSearchService = omdbSearchService ?? OmdbSearchService(),
       _movieCacheService = movieCacheService ?? MovieCacheService();

  // Keywords for broad searches as fallback
  // Removed 'the' and 'a' as they often cause "Too many results" error
  final List<String> _keywords = [
    'dark',
    'man',
    'love',
    'star',
    'world',
    'life',
    'war',
    'space',
    'hero',
    'time',
    'blue',
    'night',
    'dream',
    'force',
    'quest',
    'king',
    'dragon',
    'fire',
    'black',
    'white',
    'gold',
    'dead',
    'lost',
    'city',
    'road',
  ];

  // Simple in-memory cache to avoid repeated heavy API calls in one session
  List<Movie>? _cachedSuggestions;
  DateTime? _lastFetch;
  static const _cacheDuration = Duration(hours: 1);

  /// Returns a randomized list of high-rated movies fetched from the API.
  /// Strategy:
  /// 1. Analyze user's current list for genres/keywords.
  /// 2. If empty, use generic keywords.
  /// 3. Fetch details -> Filter by IMDb rating >= 7.0 for better availability.
  /// 4. Exclude movies already in user's list.
  Future<List<Movie>> getSuggestions() async {
    // Return cache if valid
    if (_cachedSuggestions != null &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < _cacheDuration) {
      Logger.info('Returning cached suggestions');
      return _cachedSuggestions!;
    }

    try {
      final userMovies = await _movieCacheService.getAllMovies();
      final userImdbIds = userMovies
          .map((m) => m.imdbId)
          .whereType<String>()
          .toSet();

      final random = Random();
      String keyword;
      int page =
          random.nextInt(5) + 1; // Slightly wider page range to get variety

      if (userMovies.isEmpty) {
        keyword = _keywords[random.nextInt(_keywords.length)];
        Logger.info(
          'User list empty, searching discovery for generic: $keyword (page $page)',
        );
      } else {
        // Try to find a keyword from genres or titles
        final movieToAnalyze = userMovies[random.nextInt(userMovies.length)];
        final genres = movieToAnalyze.genre
            .split(',')
            .map((e) => e.trim())
            .where((g) => g.isNotEmpty && g != 'N/A')
            .toList();

        if (genres.isNotEmpty && random.nextDouble() < 0.7) {
          keyword = genres[random.nextInt(genres.length)];
          Logger.info(
            'Searching discovery based on user genre: $keyword (page $page)',
          );
        } else {
          // Fallback to title keyword or generic
          final titleWords = movieToAnalyze.title
              .split(' ')
              .where((w) => w.length > 3)
              .toList();
          if (titleWords.isNotEmpty && random.nextDouble() < 0.5) {
            keyword = titleWords[random.nextInt(titleWords.length)];
            Logger.info(
              'Searching discovery based on user title: $keyword (page $page)',
            );
          } else {
            keyword = _keywords[random.nextInt(_keywords.length)];
            Logger.info('Fallback to generic discovery: $keyword (page $page)');
          }
        }
      }

      List<Movie> searchResults = await _omdbSearchService.searchMovies(
        keyword,
        page: page,
      );

      // If search failed or was too broad, or returned few results,
      // try with guaranteed generic keywords and page 1
      if (searchResults.length < 3) {
        Logger.info(
          'Search found insufficient results (${searchResults.length}), trying guaranteed generic fallback',
        );
        final fallbackKeyword = _keywords[random.nextInt(_keywords.length)];
        final fallbackResults = await _omdbSearchService.searchMovies(
          fallbackKeyword,
          page: 1,
        );
        if (fallbackResults.isNotEmpty) {
          searchResults = [...searchResults, ...fallbackResults];
        }
      }

      return await _processSearchResults(searchResults, userImdbIds);
    } catch (e, st) {
      Logger.error('Failed to get random suggestions', e, st);
      return _cachedSuggestions ?? [];
    }
  }

  /// Helper to process search results: filter, fetch details, and filter by rating.
  Future<List<Movie>> _processSearchResults(
    List<Movie> searchResults,
    Set<String> userImdbIds,
  ) async {
    if (searchResults.isEmpty) return [];

    // Filter out movies already in user list before fetching details
    final filteredSearch = searchResults
        .where((m) => !userImdbIds.contains(m.imdbId))
        .toList();

    if (filteredSearch.isEmpty) return [];

    // Limit search results to avoid too many API calls (max 10 details for better hit rate)
    final itemsToCheck = filteredSearch.take(10).toList();

    // Fetch details in parallel
    final detailFutures = itemsToCheck.map(
      (m) => _omdbDetailService.getMovieDetail(m.imdbId ?? ''),
    );
    final details = await Future.wait(detailFutures);

    // Filter by rating >= 7.0 (more inclusive for consistent suggestions) and valid poster
    final highRated = details
        .whereType<Movie>()
        .where((m) {
          final rating = double.tryParse(m.imdbRating ?? '0') ?? 0.0;
          return rating >= 7.0 &&
              m.posterUrl != null &&
              m.posterUrl != 'N/A' &&
              !userImdbIds.contains(m.imdbId);
        })
        .map((m) => m.copyWith(id: 'suggested_${m.imdbId}'))
        .toList();

    if (highRated.isNotEmpty) {
      _cachedSuggestions = highRated;
      _lastFetch = DateTime.now();
    } else if (_cachedSuggestions == null || _cachedSuggestions!.isEmpty) {
      // If we found NOTHING and have nothing cached, try one more desperate attempt
      // with a very popular movie to ensure the UI isn't empty
      Logger.info('No high rated movies found, attempting desperate fallback');
      final topMovie = await _omdbDetailService.getMovieDetail('tt0468569'); // The Dark Knight
      if (topMovie != null) {
        final suggestion = topMovie.copyWith(id: 'suggested_${topMovie.imdbId}');
        _cachedSuggestions = [suggestion];
        _lastFetch = DateTime.now();
        return [suggestion];
      }
    }

    return highRated.isEmpty ? (_cachedSuggestions ?? []) : highRated;
  }
}

