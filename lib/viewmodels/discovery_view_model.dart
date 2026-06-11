import 'package:flutter/foundation.dart';

import '../core/utils/logger.dart';
import '../models/movie.dart';
import '../services/discovery_catalog_service.dart';

class DiscoveryViewModel extends ChangeNotifier {
  DiscoveryViewModel({DiscoveryCatalogService? discoveryCatalogService})
    : _discoveryCatalogService =
          discoveryCatalogService ?? DiscoveryCatalogService();

  static const int _pageSize = 18;

  final DiscoveryCatalogService _discoveryCatalogService;

  DiscoveryCatalogFilter filter = DiscoveryCatalogFilter.all;
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;
  String? errorMessage;
  List<Movie> movies = [];

  int _offset = 0;

  Future<void> init() async {
    if (movies.isNotEmpty || isLoading) return;
    await refresh();
  }

  Future<void> refresh() async {
    isLoading = true;
    isLoadingMore = false;
    errorMessage = null;
    hasMore = true;
    _offset = 0;
    movies = [];
    notifyListeners();

    try {
      final page = await _discoveryCatalogService.fetchPage(
        filter: filter,
        offset: _offset,
        limit: _pageSize,
      );
      movies = page.movies;
      _offset = page.nextOffset;
      hasMore = page.hasMore;
    } catch (e, st) {
      errorMessage = e.toString();
      Logger.error('DiscoveryViewModel refresh failed', e, st);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (isLoading || isLoadingMore || !hasMore) return;

    isLoadingMore = true;
    errorMessage = null;
    notifyListeners();

    try {
      final page = await _discoveryCatalogService.fetchPage(
        filter: filter,
        offset: _offset,
        limit: _pageSize,
      );
      movies = [...movies, ...page.movies];
      _offset = page.nextOffset;
      hasMore = page.hasMore;
    } catch (e, st) {
      errorMessage = e.toString();
      Logger.error('DiscoveryViewModel loadMore failed', e, st);
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> setFilter(DiscoveryCatalogFilter nextFilter) async {
    if (filter == nextFilter) return;
    filter = nextFilter;
    await refresh();
  }
}
