import 'package:flutter/foundation.dart';
import '../models/discovery_preference.dart';
import '../services/discovery_service.dart';

enum DiscoveryMode { idle, quiz, category }

enum DiscoveryState { idle, loading, success, error }

class DiscoveryViewModel extends ChangeNotifier {
  final DiscoveryService _discoveryService;

  DiscoveryViewModel({DiscoveryService? discoveryService})
      : _discoveryService = discoveryService ?? DiscoveryService();

  // ── State ──────────────────────────────────────────────
  DiscoveryMode mode = DiscoveryMode.idle;
  DiscoveryState state = DiscoveryState.idle;
  String? errorMessage;
  List<DiscoveryResult> results = [];

  // ── Quiz answers ───────────────────────────────────────
  String selectedMood = '';
  String selectedGenre = '';
  String selectedDuration = 'any';
  String selectedViewingContext = 'solo';
  String selectedEra = 'any';

  // ── Selected category ──────────────────────────────────
  String selectedCategoryKey = '';

  // ── Init ───────────────────────────────────────────────
  Future<void> init() async {
    // Discovery screen is opt-in: no auto-load on open
  }

  // ── Quiz setters ───────────────────────────────────────
  void setMood(String mood) {
    selectedMood = mood;
    notifyListeners();
  }

  void setGenre(String genre) {
    selectedGenre = genre;
    notifyListeners();
  }

  void setDuration(String duration) {
    selectedDuration = duration;
    notifyListeners();
  }

  void setViewingContext(String ctx) {
    selectedViewingContext = ctx;
    notifyListeners();
  }

  void setEra(String era) {
    selectedEra = era;
    notifyListeners();
  }

  // ── Actions ────────────────────────────────────────────
  Future<void> fetchFromQuiz() async {
    if (selectedMood.isEmpty || selectedGenre.isEmpty) return;

    mode = DiscoveryMode.quiz;
    state = DiscoveryState.loading;
    errorMessage = null;
    results = [];
    notifyListeners();

    try {
      final pref = DiscoveryPreference(
        mood: selectedMood,
        genre: selectedGenre,
        duration: selectedDuration,
        viewingContext: selectedViewingContext,
        era: selectedEra,
      );
      final fetched = await _discoveryService.suggestFromPreference(pref);
      results = fetched;
      state = fetched.isEmpty
          ? DiscoveryState.error
          : DiscoveryState.success;
      if (fetched.isEmpty) {
        errorMessage = 'noResults';
      }
    } catch (_) {
      state = DiscoveryState.error;
      errorMessage = 'errorOccurred';
    }
    notifyListeners();
  }

  Future<void> fetchFromCategory(String categoryKey) async {
    selectedCategoryKey = categoryKey;
    mode = DiscoveryMode.category;
    state = DiscoveryState.loading;
    errorMessage = null;
    results = [];
    notifyListeners();

    try {
      final fetched = await _discoveryService.suggestFromCategory(categoryKey);
      results = fetched;
      state = fetched.isEmpty
          ? DiscoveryState.error
          : DiscoveryState.success;
      if (fetched.isEmpty) {
        errorMessage = 'noResults';
      }
    } catch (_) {
      state = DiscoveryState.error;
      errorMessage = 'errorOccurred';
    }
    notifyListeners();
  }

  void reset() {
    mode = DiscoveryMode.idle;
    state = DiscoveryState.idle;
    errorMessage = null;
    results = [];
    selectedMood = '';
    selectedGenre = '';
    selectedDuration = 'any';
    selectedViewingContext = 'solo';
    selectedEra = 'any';
    selectedCategoryKey = '';
    notifyListeners();
  }

  bool get isLoading => state == DiscoveryState.loading;
  bool get hasResults => state == DiscoveryState.success && results.isNotEmpty;
  bool get hasError => state == DiscoveryState.error;
  bool get isIdle => state == DiscoveryState.idle;

  bool get quizIsReady => selectedMood.isNotEmpty && selectedGenre.isNotEmpty;
}
