import 'dart:convert';

import '../core/database/local_db.dart';
import '../core/utils/logger.dart';
import '../models/movie.dart';
import 'omdb_detail_service.dart';

enum DiscoveryCatalogFilter { all, movies, series }

class DiscoveryCatalogPage {
  final List<Movie> movies;
  final int nextOffset;
  final bool hasMore;

  const DiscoveryCatalogPage({
    required this.movies,
    required this.nextOffset,
    required this.hasMore,
  });
}

class DiscoveryCatalogService {
  DiscoveryCatalogService({OmdbDetailService? omdbDetailService})
    : _omdbDetailService = omdbDetailService ?? OmdbDetailService();

  final OmdbDetailService _omdbDetailService;
  final Map<String, Movie> _cache = {};

  static const String _cacheKeyPrefix = 'discovery_catalog_v1_';

  Future<DiscoveryCatalogPage> fetchPage({
    required DiscoveryCatalogFilter filter,
    required int offset,
    required int limit,
  }) async {
    final ids = _idsFor(filter);
    if (offset >= ids.length) {
      return DiscoveryCatalogPage(
        movies: const [],
        nextOffset: offset,
        hasMore: false,
      );
    }

    final end = (offset + limit).clamp(0, ids.length);
    final pageIds = ids.sublist(offset, end);
    final movies = <Movie>[];

    for (final imdbId in pageIds) {
      final movie = await _getMovie(imdbId);
      if (movie != null) {
        movies.add(movie);
      }
    }

    return DiscoveryCatalogPage(
      movies: movies,
      nextOffset: end,
      hasMore: end < ids.length,
    );
  }

  Future<Movie?> _getMovie(String imdbId) async {
    final memoryCachedMovie = _cache[imdbId];
    if (memoryCachedMovie != null) return memoryCachedMovie;

    final diskCachedMovie = _getCachedMovie(imdbId);
    if (diskCachedMovie != null) {
      _cache[imdbId] = diskCachedMovie;
      return diskCachedMovie;
    }

    final apiMovie = await _omdbDetailService.getMovieDetail(imdbId);
    if (apiMovie == null) {
      Logger.info('Discovery catalog skipped missing API detail for $imdbId');
      return null;
    }

    _cache[imdbId] = apiMovie;
    await _cacheMovie(apiMovie);
    return apiMovie;
  }

  Movie? _getCachedMovie(String imdbId) {
    try {
      final rawValue = LocalDb.searchCacheBox.get(_cacheKey(imdbId));
      if (rawValue == null) return null;

      final jsonMap = jsonDecode(rawValue) as Map<String, dynamic>;
      return Movie.fromJson(jsonMap);
    } catch (e, st) {
      Logger.error('Discovery catalog cache read failed for $imdbId', e, st);
      return null;
    }
  }

  Future<void> _cacheMovie(Movie movie) async {
    final imdbId = movie.imdbId;
    if (imdbId == null || imdbId.isEmpty) return;

    try {
      await LocalDb.searchCacheBox.put(
        _cacheKey(imdbId),
        jsonEncode(movie.toJson()),
      );
    } catch (e, st) {
      Logger.error('Discovery catalog cache write failed for $imdbId', e, st);
    }
  }

  String _cacheKey(String imdbId) => '$_cacheKeyPrefix$imdbId';

  List<String> _idsFor(DiscoveryCatalogFilter filter) {
    switch (filter) {
      case DiscoveryCatalogFilter.movies:
        return _topMovieImdbIds;
      case DiscoveryCatalogFilter.series:
        return _topSeriesImdbIds;
      case DiscoveryCatalogFilter.all:
        return [..._topMovieImdbIds, ..._topSeriesImdbIds];
    }
  }

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
    'tt0167261',
    'tt0109830',
    'tt0137523',
    'tt1375666',
    'tt0080684',
    'tt0133093',
    'tt0099685',
    'tt0073486',
    'tt0114369',
    'tt0816692',
    'tt0038650',
    'tt0047478',
    'tt0102926',
    'tt0120815',
    'tt0317248',
    'tt0118799',
    'tt0120689',
    'tt0103064',
    'tt0076759',
    'tt0088763',
    'tt0245429',
    'tt0253474',
    'tt6751668',
    'tt0110413',
    'tt0110357',
    'tt0172495',
    'tt0120586',
    'tt0407887',
    'tt2582802',
    'tt0482571',
    'tt0082971',
    'tt1675434',
    'tt4154756',
    'tt0054215',
    'tt0056058',
    'tt0027977',
    'tt0095327',
    'tt0064116',
    'tt0034583',
    'tt0095765',
    'tt0021749',
    'tt1853728',
    'tt1345836',
    'tt0209144',
    'tt0910970',
    'tt0081505',
    'tt0090605',
    'tt0169547',
    'tt0364569',
    'tt7286456',
    'tt4154796',
    'tt4633694',
    'tt8267604',
    'tt5311514',
    'tt2380307',
    'tt1187043',
    'tt0986264',
    'tt5074352',
    'tt8503618',
    'tt2106476',
    'tt4016934',
    'tt0119698',
    'tt0091251',
    'tt0043014',
    'tt0057012',
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
    'tt0081846',
    'tt9253866',
    'tt0944947',
    'tt1355642',
    'tt3032476',
    'tt4574334',
    'tt1475582',
    'tt2861424',
    'tt0386676',
    'tt0096697',
    'tt0098904',
    'tt0108778',
    'tt2356777',
    'tt2802850',
    'tt0407362',
    'tt0098936',
    'tt1520211',
    'tt0455275',
    'tt0411008',
    'tt0106179',
    'tt2442560',
    'tt2085059',
    'tt1119644',
    'tt5180504',
    'tt8111088',
    'tt0103359',
    'tt0436992',
    'tt0092337',
    'tt0118421',
    'tt0348914',
    'tt0388629',
    'tt2560140',
    'tt9335498',
    'tt0877057',
    'tt0213338',
    'tt3398228',
    'tt1486217',
    'tt0460649',
    'tt0898266',
    'tt1632701',
    'tt1439629',
    'tt0412142',
    'tt1870479',
    'tt0979432',
    'tt0773262',
    'tt4158110',
    'tt5071412',
    'tt5290382',
    'tt2306299',
    'tt5753856',
    'tt6468322',
    'tt1442437',
    'tt1266020',
    'tt1796960',
    'tt1190634',
    'tt9140554',
    'tt0475784',
    'tt10048342',
    'tt3581920',
    'tt0367279',
    'tt0182576',
    'tt0384766',
    'tt0121955',
    'tt0092455',
    'tt3322312',
  ];
}
