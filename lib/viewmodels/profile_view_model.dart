import 'package:flutter/material.dart';
import '../services/movie_cache_service.dart';
import '../services/review_service.dart';
import '../core/database/local_db.dart';
import '../core/utils/logger.dart';
import '../app/translations.dart';

class ProfileViewModel extends ChangeNotifier {
  final MovieCacheService _movieCacheService;
  final ReviewService _reviewService;

  ProfileViewModel({
    required MovieCacheService movieCacheService,
    required ReviewService reviewService,
  }) : _movieCacheService = movieCacheService,
       _reviewService = reviewService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Language get currentLanguage => Translations.currentLanguage;

  Future<void> changeLanguage(Language lang) async {
    await Translations.changeLanguage(lang);
    notifyListeners();
  }

  Future<void> clearAllData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _movieCacheService.clearAllMovies();
      await _reviewService.clearAllReviews();
      await LocalDb.searchCacheBox.clear();
      Logger.info('All data cleared successfully');
    } catch (e, st) {
      _errorMessage = e.toString();
      Logger.error('Error clearing data', e, st);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
