import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/logger.dart';
import '../models/movie.dart';
import '../models/watch_status.dart';
import 'movie_cache_service.dart';
import 'omdb_detail_service.dart';

class InitialSeedService {
  InitialSeedService({
    MovieCacheService? movieCacheService,
    OmdbDetailService? omdbDetailService,
  }) : _movieCacheService = movieCacheService ?? MovieCacheService(),
       _omdbDetailService = omdbDetailService ?? OmdbDetailService();

  static const String _seedAppliedKey = 'initial_seed_v2_applied';

  static const List<String> _topMovieImdbIds = [
    'tt0111161',
    'tt0068646',
    'tt0468569',
    'tt0071562',
    'tt0050083',
    'tt0167260',
    'tt0108052',
    'tt0120737',
    'tt0110912',
    'tt0060196',
  ];

  static const List<String> _topSeriesImdbIds = [
    'tt0903747',
    'tt5491994',
    'tt0795176',
    'tt0185906',
    'tt7366338',
    'tt0306414',
    'tt0417299',
    'tt0141842',
    'tt6769208',
    'tt2395695',
  ];

  final MovieCacheService _movieCacheService;
  final OmdbDetailService _omdbDetailService;

  Future<void> seedIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final seedApplied = prefs.getBool(_seedAppliedKey) ?? false;
      if (seedApplied) return;

      final existingMovies = await _movieCacheService.getAllMovies();
      if (existingMovies.isNotEmpty) {
        final refreshedCount = await _refreshLegacySeedMovies();
        await prefs.setBool(_seedAppliedKey, true);
        Logger.info(
          'Initial seed skipped insert; refreshed $refreshedCount legacy seed titles',
        );
        return;
      }

      final seedIds = [..._topMovieImdbIds, ..._topSeriesImdbIds];
      var insertedCount = 0;
      final now = DateTime.now();

      for (var index = 0; index < seedIds.length; index++) {
        final imdbId = seedIds[index];
        final movie = await _omdbDetailService.getMovieDetail(imdbId);
        if (movie == null) {
          Logger.info('Initial seed skipped missing API detail for $imdbId');
          continue;
        }

        final createdAt = now.subtract(
          Duration(minutes: seedIds.length - index),
        );
        await _movieCacheService.saveMovie(
          _prepareSeedMovie(
            movie,
            createdAt: createdAt,
            fallbackType: _topSeriesImdbIds.contains(imdbId)
                ? 'series'
                : 'movie',
          ),
        );
        insertedCount++;
      }

      if (insertedCount > 0) {
        await prefs.setBool(_seedAppliedKey, true);
      }

      Logger.info('Initial seed inserted $insertedCount API titles');
    } catch (e, st) {
      Logger.error('Initial seed failed', e, st);
    }
  }

  Future<int> _refreshLegacySeedMovies() async {
    var refreshedCount = 0;
    final seedIds = [..._topMovieImdbIds, ..._topSeriesImdbIds];

    for (final imdbId in seedIds) {
      final existingMovie = await _movieCacheService.getMovieByImdbId(imdbId);
      if (existingMovie == null || !existingMovie.id.startsWith('seed_')) {
        continue;
      }

      final apiMovie = await _omdbDetailService.getMovieDetail(imdbId);
      if (apiMovie == null) {
        Logger.info(
          'Initial seed refresh skipped missing API detail for $imdbId',
        );
        continue;
      }

      await _movieCacheService.updateMovie(
        _mergeLegacySeedMovie(
          existingMovie: existingMovie,
          apiMovie: apiMovie,
          fallbackType: _topSeriesImdbIds.contains(imdbId) ? 'series' : 'movie',
        ),
      );
      refreshedCount++;
    }

    return refreshedCount;
  }

  Movie _prepareSeedMovie(
    Movie movie, {
    required DateTime createdAt,
    required String fallbackType,
  }) {
    return movie.copyWith(
      id: movie.imdbId ?? movie.id,
      watchStatus: WatchStatus.toWatch,
      createdAt: createdAt,
      updatedAt: createdAt,
      type: movie.type ?? fallbackType,
    );
  }

  Movie _mergeLegacySeedMovie({
    required Movie existingMovie,
    required Movie apiMovie,
    required String fallbackType,
  }) {
    return apiMovie.copyWith(
      id: existingMovie.id,
      watchStatus: existingMovie.watchStatus,
      createdAt: existingMovie.createdAt,
      updatedAt: DateTime.now(),
      type: apiMovie.type ?? existingMovie.type ?? fallbackType,
      watchCount: existingMovie.watchCount,
      lastViewedAt: existingMovie.lastViewedAt,
    );
  }
}
