/// Discovery Preference model — holds user quiz answers.
/// This is a pure in-memory model, not persisted to local DB.
class DiscoveryPreference {
  final String mood;
  final String genre;
  final String duration; // 'short', 'medium', 'any'
  final String viewingContext; // 'solo', 'friends', 'family'
  final String era; // 'new', 'classic', 'any'

  const DiscoveryPreference({
    required this.mood,
    required this.genre,
    required this.duration,
    required this.viewingContext,
    required this.era,
  });

  static const DiscoveryPreference empty = DiscoveryPreference(
    mood: '',
    genre: '',
    duration: 'any',
    viewingContext: 'solo',
    era: 'any',
  );
}

/// A validated movie suggestion — OMDb confirmed, with Grok's reason text.
class DiscoveryResult {
  final String imdbId;
  final String title;
  final String year;
  final String genre;
  final String? posterUrl;
  final String? imdbRating;
  final String? runtime;
  final String reason;

  const DiscoveryResult({
    required this.imdbId,
    required this.title,
    required this.year,
    required this.genre,
    this.posterUrl,
    this.imdbRating,
    this.runtime,
    required this.reason,
  });
}
