import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/utils/logger.dart';
import '../models/discovery_preference.dart';

/// Calls the xAI Grok API to suggest movie titles based on user preferences.
/// Returns only IMDb-searchable English titles (or original titles).
class GrokAiService {
  static const String _baseUrl = 'https://api.x.ai/v1/chat/completions';
  // Replace with your actual xAI API key — store in env/secrets in production
  static const String _apiKey = 'YOUR_XAI_API_KEY_HERE';
  static const String _model = 'grok-3-latest';

  /// Generate movie candidates from quiz preferences.
  Future<List<GrokMovieCandidate>> suggestFromPreference(
    DiscoveryPreference pref,
  ) async {
    final prompt = _buildQuizPrompt(pref);
    return _callGrok(prompt);
  }

  /// Generate movie candidates from a quick category.
  Future<List<GrokMovieCandidate>> suggestFromCategory(String categoryKey) async {
    final prompt = _buildCategoryPrompt(categoryKey);
    return _callGrok(prompt);
  }

  String _buildQuizPrompt(DiscoveryPreference pref) {
    return '''
You are a world-class film curator. Based on the user's current preferences, suggest exactly 10 real movies.

User preferences:
- Mood: ${pref.mood}
- Genre: ${pref.genre}
- Duration: ${pref.duration}
- Viewing context: ${pref.viewingContext}
- Era preference: ${pref.era}

Rules:
- Only suggest real, widely-known movies that exist on IMDb.
- Focus on quality: IMDb rating >= 7.0 preferred.
- Mix well-known and hidden gems.
- Respond ONLY with a valid JSON array. No explanation, no markdown.
- Each element: {"title": "...", "year": "...", "reason": "..."}
- "reason" must be 1 short sentence in English (why this movie fits the user).
- If you cannot suggest 10, suggest as many as you can (minimum 5).

Example format:
[{"title":"Inception","year":"2010","reason":"Mind-bending visuals perfect for a thoughtful solo evening."}]
''';
  }

  String _buildCategoryPrompt(String categoryKey) {
    final categoryDescriptions = {
      'action': 'high-octane action movies with great stunts and excitement',
      'sciFi': 'science fiction movies with imaginative worlds and ideas',
      'thriller': 'suspenseful psychological thrillers that keep you on edge',
      'comedy': 'genuinely funny, feel-good comedy movies',
      'romance': 'heartfelt romantic movies with compelling love stories',
      'family': 'wholesome family-friendly movies for all ages',
      'shortRuntime': 'excellent movies under 100 minutes runtime',
      'highRated': 'the highest-rated movies of all time on IMDb (>= 8.0)',
    };

    final desc = categoryDescriptions[categoryKey] ??
        'diverse, well-rated movies across genres';

    return '''
You are a world-class film curator. Suggest exactly 10 real movies that match: $desc

Rules:
- Only suggest real, widely-known movies that exist on IMDb.
- Focus on quality: IMDb rating >= 7.5 preferred.
- For "highRated": only suggest IMDb Top 250 caliber films.
- For "shortRuntime": all suggestions must be under 100 minutes.
- Respond ONLY with a valid JSON array. No explanation, no markdown.
- Each element: {"title": "...", "year": "...", "reason": "..."}
- "reason" must be 1 short sentence in English (why this movie fits the category).
- If you cannot suggest 10, suggest as many as you can (minimum 5).

Example format:
[{"title":"Mad Max: Fury Road","year":"2015","reason":"An adrenaline-fueled masterpiece of pure kinetic action."}]
''';
  }

  Future<List<GrokMovieCandidate>> _callGrok(String prompt) async {
    try {
      Logger.info('GrokAiService: Calling Grok API...');
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {'role': 'user', 'content': prompt},
              ],
              'temperature': 0.7,
              'max_tokens': 1500,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final content =
            data['choices']?[0]?['message']?['content'] as String? ?? '';
        return _parseGrokResponse(content);
      } else {
        Logger.error(
          'GrokAiService: API error ${response.statusCode}: ${response.body}',
        );
        return [];
      }
    } catch (e, st) {
      Logger.error('GrokAiService: Failed to call Grok API', e, st);
      return [];
    }
  }

  List<GrokMovieCandidate> _parseGrokResponse(String content) {
    try {
      // Strip markdown code fences if present
      String cleaned = content.trim();
      if (cleaned.startsWith('```')) {
        cleaned = cleaned
            .replaceFirst(RegExp(r'^```[a-zA-Z]*\n?'), '')
            .replaceFirst(RegExp(r'```$'), '')
            .trim();
      }

      final jsonList = jsonDecode(cleaned) as List<dynamic>;
      return jsonList
          .map((e) => GrokMovieCandidate.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      Logger.error('GrokAiService: Failed to parse Grok response', e, st);
      return [];
    }
  }
}

/// Lightweight model for Grok's suggested movie candidates.
class GrokMovieCandidate {
  final String title;
  final String year;
  final String reason;

  const GrokMovieCandidate({
    required this.title,
    required this.year,
    required this.reason,
  });

  factory GrokMovieCandidate.fromJson(Map<String, dynamic> json) {
    return GrokMovieCandidate(
      title: json['title'] as String? ?? '',
      year: json['year'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
    );
  }
}
