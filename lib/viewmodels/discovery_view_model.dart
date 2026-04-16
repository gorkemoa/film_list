import 'dart:math';
import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/movie_cache_service.dart';
import '../services/discovery_service.dart';
import '../core/utils/logger.dart';

class DiscoveryViewModel extends ChangeNotifier {
  final MovieCacheService _movieCacheService;
  final DiscoveryService _discoveryService;

  DiscoveryViewModel({
    MovieCacheService? movieCacheService,
    DiscoveryService? discoveryService,
  }) : _movieCacheService = movieCacheService ?? MovieCacheService(),
       _discoveryService = discoveryService ?? DiscoveryService();

  List<Movie> _allMovies = []; // Combined local and suggested
  List<Movie> _filteredMovies = [];
  List<Movie> _suggestedMovies = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Movie> get filteredMovies => _filteredMovies;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Filter states
  String? selectedGenre;
  RangeValues yearRange = const RangeValues(1900, 2026);
  RangeValues ratingRange = const RangeValues(0, 10);
  RangeValues durationRange = const RangeValues(0, 300);
  String? selectedLanguage;
  String? selectedCountry;

  Future<void> init() async {
    await loadDiscovery();
  }

  Future<void> loadDiscovery() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Get local movies
      final localMovies = await _movieCacheService.getAllMovies();
      
      // 2. Get online suggestions from DiscoveryService (Smart part)
      _suggestedMovies = await _discoveryService.getSuggestions();

      // 3. Combine them for a "Unified Discovery" experience
      // Suggestions are marked with 'suggested_' prefix in their ID normally
      _allMovies = [...localMovies, ..._suggestedMovies];
      
      _filteredMovies = List.from(_allMovies);
      _updateRanges();
    } catch (e, st) {
      Logger.error('Failed to load discovery data', e, st);
      _errorMessage = 'Failed to load discovery';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateRanges() {
    if (_allMovies.isEmpty) return;
    
    int minYear = 2026;
    int maxYear = 1900;
    for (var m in _allMovies) {
      final yearStr = m.year.split('–')[0].replaceAll(RegExp(r'[^0-9]'), '');
      final year = int.tryParse(yearStr) ?? 2000;
      if (year < minYear && year > 1900) minYear = year;
      if (year > maxYear && year < 2100) maxYear = year;
    }
    
    // Safety check for ranges
    if (minYear > maxYear) {
      minYear = 1900;
      maxYear = 2026;
    }
    
    yearRange = RangeValues(minYear.toDouble(), maxYear.toDouble());
  }

  void applyFilters() {
    _filteredMovies = _allMovies.where((movie) {
      // Genre filter
      if (selectedGenre != null && !movie.genre.toLowerCase().contains(selectedGenre!.toLowerCase())) {
        return false;
      }

      // Year filter
      final yearStr = movie.year.split('–')[0].replaceAll(RegExp(r'[^0-9]'), '');
      final year = int.tryParse(yearStr) ?? 0;
      if (year > 0 && (year < yearRange.start || year > yearRange.end)) return false;

      // Rating filter
      final rating = double.tryParse(movie.imdbRating ?? '0') ?? 0.0;
      if (rating < ratingRange.start || rating > ratingRange.end) return false;

      // Duration filter
      final duration = _parseRuntime(movie.runtime);
      if (duration > 0 && (duration < durationRange.start || duration > durationRange.end)) return false;

      return true;
    }).toList();
    notifyListeners();
  }

  int _parseRuntime(String? runtime) {
    if (runtime == null || runtime == 'N/A') return 0;
    final clean = runtime.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(clean) ?? 0;
  }

  void getRandomMovie() {
    if (_allMovies.isEmpty) return;
    final random = Random();
    _filteredMovies = [_allMovies[random.nextInt(_allMovies.length)]];
    notifyListeners();
  }

  void discoverQuickMovies() {
    _filteredMovies = _allMovies.where((m) {
      final duration = _parseRuntime(m.runtime);
      return duration > 0 && duration < 90;
    }).toList();
    notifyListeners();
  }

  void discoverHighRatedShort() {
    _filteredMovies = _allMovies.where((m) {
      final duration = _parseRuntime(m.runtime);
      final rating = double.tryParse(m.imdbRating ?? '0') ?? 0.0;
      return duration > 0 && duration < 100 && rating >= 7.5;
    }).toList();
    notifyListeners();
  }

  void discoverByMood(String mood) {
    _filteredMovies = _allMovies.where((m) {
      final genre = m.genre.toLowerCase();
      switch (mood) {
        case 'fun':
          return genre.contains('comedy') || genre.contains('animation');
        case 'dark':
          return genre.contains('thriller') || genre.contains('horror') || genre.contains('crime');
        case 'mind-bending':
          return genre.contains('mystery') || genre.contains('sci-fi') || genre.contains('thriller');
        case 'family':
          return genre.contains('family') || genre.contains('animation');
        case 'solo':
          return genre.contains('drama') || genre.contains('romance');
        case 'short':
          return _parseRuntime(m.runtime) < 90 && _parseRuntime(m.runtime) > 0;
        case 'light':
          return genre.contains('comedy') || genre.contains('musical') || genre.contains('romance');
        default:
          return true;
      }
    }).toList();
    notifyListeners();
  }

  void clearFilters() {
    selectedGenre = null;
    selectedLanguage = null;
    selectedCountry = null;
    _updateRanges();
    ratingRange = const RangeValues(0, 10);
    durationRange = const RangeValues(0, 300);
    _filteredMovies = List.from(_allMovies);
    notifyListeners();
  }
}
