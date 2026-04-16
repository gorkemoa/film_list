
import 'package:flutter/foundation.dart';
import '../models/discovery_models.dart';
import '../models/movie.dart';
import '../services/grok_ai_service.dart';
import '../services/omdb_detail_service.dart';
import '../core/utils/logger.dart';

enum DiscoveryState { Initial, Survey, Loading, Results, Error }

class DiscoveryViewModel extends ChangeNotifier {
  final GrokAiService _grokAiService = GrokAiService();
  final OmdbDetailService _omdbDetailService = OmdbDetailService();

  DiscoveryState _state = DiscoveryState.Initial;
  DiscoveryState get state => _state;

  SurveyAnswers _surveyAnswers = SurveyAnswers();
  SurveyAnswers get surveyAnswers => _surveyAnswers;

  int _currentSurveyStep = 0;
  int get currentSurveyStep => _currentSurveyStep;

  List<DiscoveryMovie> _results = [];
  List<DiscoveryMovie> get results => _results;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void startSurvey() {
    _state = DiscoveryState.Survey;
    _currentSurveyStep = 0;
    _surveyAnswers = SurveyAnswers();
    notifyListeners();
  }

  void updateSurvey(String value) {
    switch (_currentSurveyStep) {
      case 0:
        _surveyAnswers = SurveyAnswers(
          mood: value,
          genre: _surveyAnswers.genre,
          duration: _surveyAnswers.duration,
          companion: _surveyAnswers.companion,
          period: _surveyAnswers.period,
        );
        break;
      case 1:
        _surveyAnswers = SurveyAnswers(
          mood: _surveyAnswers.mood,
          genre: value,
          duration: _surveyAnswers.duration,
          companion: _surveyAnswers.companion,
          period: _surveyAnswers.period,
        );
        break;
      case 2:
        _surveyAnswers = SurveyAnswers(
          mood: _surveyAnswers.mood,
          genre: _surveyAnswers.genre,
          duration: value,
          companion: _surveyAnswers.companion,
          period: _surveyAnswers.period,
        );
        break;
      case 3:
        _surveyAnswers = SurveyAnswers(
          mood: _surveyAnswers.mood,
          genre: _surveyAnswers.genre,
          duration: _surveyAnswers.duration,
          companion: value,
          period: _surveyAnswers.period,
        );
        break;
      case 4:
        _surveyAnswers = SurveyAnswers(
          mood: _surveyAnswers.mood,
          genre: _surveyAnswers.genre,
          duration: _surveyAnswers.duration,
          companion: _surveyAnswers.companion,
          period: value,
        );
        break;
    }

    if (_currentSurveyStep < 4) {
      _currentSurveyStep++;
    } else {
      _state = DiscoveryState.Loading;
      _getAiRecommendations();
    }
    notifyListeners();
  }

  Future<void> _getAiRecommendations() async {
    try {
      final aiCandidates = await _grokAiService.getRecommendations(_surveyAnswers);
      await _processCandidates(aiCandidates);
    } catch (e) {
      _handleError('Öneriler getirilirken bir hata oluştu.');
    }
  }

  Future<void> findByCategory(String category) async {
    _state = DiscoveryState.Loading;
    notifyListeners();

    try {
      final aiCandidates = await _grokAiService.getRecommendationsByCategory(category);
      await _processCandidates(aiCandidates);
    } catch (e) {
      _handleError('Kategori önerileri getirilirken bir hata oluştu.');
    }
  }

  Future<void> _processCandidates(List<Map<String, String>> candidates) async {
    _results = [];
    
    for (var candidate in candidates) {
      final title = candidate['title']!;
      final reason = candidate['reason']!;
      
      final movie = await _omdbDetailService.getMovieByTitle(title);
      if (movie != null) {
        _results.add(DiscoveryMovie(movie: movie, recommendationReason: reason));
      }
    }

    if (_results.isEmpty) {
      _handleError('Üzgünüz, kriterlerinize uygun doğrulanmış film bulunamadı.');
    } else {
      _state = DiscoveryState.Results;
    }
    notifyListeners();
  }

  void _handleError(String message) {
    _errorMessage = message;
    _state = DiscoveryState.Error;
  }

  void reset() {
    _state = DiscoveryState.Initial;
    _currentSurveyStep = 0;
    _surveyAnswers = SurveyAnswers();
    _results = [];
    _errorMessage = null;
    notifyListeners();
  }
}
