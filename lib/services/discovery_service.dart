import '../models/discovery_preference.dart';
import '../models/movie.dart';
import '../core/utils/logger.dart';
import 'grok_ai_service.dart';
import 'omdb_detail_service.dart';
import 'omdb_search_service.dart';

/// Discovery service for AI-powered movie recommendations.
/// Flow:
///   1. Grok AI generates candidate movie titles.
///   2. Each candidate is searched on OMDb by title.
///   3. Only OMDb-confirmed movies with valid data are returned.
class DiscoveryService {
  final GrokAiService _grokAiService;
  final OmdbDetailService _omdbDetailService;
  final OmdbSearchService _omdbSearchService;

  DiscoveryService({
    GrokAiService? grokAiService,
    OmdbDetailService? omdbDetailService,
    OmdbSearchService? omdbSearchService,
  })  : _grokAiService = grokAiService ?? GrokAiService(),
        _omdbDetailService = omdbDetailService ?? OmdbDetailService(),
        _omdbSearchService = omdbSearchService ?? OmdbSearchService();

  /// Suggests movies based on a quiz-style [DiscoveryPreference].
  Future<List<DiscoveryResult>> suggestFromPreference(
    DiscoveryPreference pref,
  ) async {
    Logger.info('DiscoveryService: suggestFromPreference called');
    try {
      final candidates = await _grokAiService.suggestFromPreference(pref);
      if (candidates.isEmpty) {
        Logger.info('DiscoveryService: Grok returned no candidates');
        return [];
      }
      return _validateAndBuildResults(candidates, _grokAiCandidates: candidates);
    } catch (e, st) {
      Logger.error('DiscoveryService: suggestFromPreference failed', e, st);
      return [];
    }
  }

  /// Suggests movies based on a quick category key (e.g. 'action', 'highRated').
  Future<List<DiscoveryResult>> suggestFromCategory(String categoryKey) async {
    Logger.info('DiscoveryService: suggestFromCategory called for $categoryKey');
    try {
      final candidates = await _grokAiService.suggestFromCategory(categoryKey);
      if (candidates.isEmpty) {
        Logger.info('DiscoveryService: Grok returned no candidates');
        return [];
      }
      return _validateAndBuildResults(candidates, _grokAiCandidates: candidates);
    } catch (e, st) {
      Logger.error('DiscoveryService: suggestFromCategory failed', e, st);
      return [];
    }
  }

  /// Validates Grok candidates against OMDb and builds [DiscoveryResult] list.
  Future<List<DiscoveryResult>> _validateAndBuildResults(
    List<GrokMovieCandidate> candidates, {
    required List<GrokMovieCandidate> _grokAiCandidates,
  }) async {
    final results = <DiscoveryResult>[];

    // Build a reason lookup by title (case-insensitive)
    final reasonMap = <String, String>{};
    for (final c in _grokAiCandidates) {
      reasonMap[c.title.toLowerCase()] = c.reason;
    }

    // Search + fetch detail in controlled batches to avoid rate limits
    final futures = candidates.take(10).map((c) async {
      try {
        // Step 1: Search by title on OMDb
        final searchResults = await _omdbSearchService.searchMovies(c.title);
        if (searchResults.isEmpty) {
          Logger.info('DiscoveryService: Not found on OMDb: ${c.title}');
          return null;
        }

        // Step 2: Find best match (prefer exact title match)
        Movie? bestMatch;
        for (final m in searchResults) {
          if (m.title.toLowerCase() == c.title.toLowerCase()) {
            bestMatch = m;
            break;
          }
        }
        bestMatch ??= searchResults.first;

        // Step 3: Fetch full detail
        final detail = await _omdbDetailService
            .getMovieDetail(bestMatch.imdbId ?? '');
        if (detail == null) {
          Logger.info(
            'DiscoveryService: No detail for imdbId: ${bestMatch.imdbId}',
          );
          return null;
        }

        // Step 4: Validate: must have poster and reasonable rating
        if (detail.posterUrl == null || detail.posterUrl == 'N/A') {
          Logger.info('DiscoveryService: No poster for: ${detail.title}');
          return null;
        }

        final reason =
            reasonMap[c.title.toLowerCase()] ?? reasonMap[detail.title.toLowerCase()] ?? c.reason;

        return DiscoveryResult(
          imdbId: detail.imdbId ?? detail.id,
          title: detail.title,
          year: detail.year,
          genre: detail.genre,
          posterUrl: detail.posterUrl,
          imdbRating: detail.imdbRating,
          runtime: detail.runtime,
          reason: reason,
        );
      } catch (e, st) {
        Logger.error(
          'DiscoveryService: Error validating candidate ${c.title}',
          e,
          st,
        );
        return null;
      }
    }).toList();

    final resolved = await Future.wait(futures);
    for (final r in resolved) {
      if (r != null) results.add(r);
    }

    Logger.info(
      'DiscoveryService: ${results.length} validated results from ${candidates.length} candidates',
    );
    return results;
  }

  /// Converts a [DiscoveryResult] to a [Movie] for navigation to detail view.
  Movie discoveryResultToMovie(DiscoveryResult result) {
    return Movie(
      id: 'discovery_${result.imdbId}',
      imdbId: result.imdbId,
      title: result.title,
      year: result.year,
      genre: result.genre,
      posterUrl: result.posterUrl,
      imdbRating: result.imdbRating,
      runtime: result.runtime,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
