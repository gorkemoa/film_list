import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';
import '../core/utils/logger.dart';

class OmdbSearchService {
  static const String _baseUrl = 'https://www.omdbapi.com/';
  // Note: Using a public test key for demonstration
  // In production, this should be in an environment variable
  static const String _apiKey = 'trilogy';

  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl?s=${Uri.encodeComponent(query)}&page=$page&apikey=$_apiKey',
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['Response'] == 'True') {
          final List searchList = data['Search'];
          return searchList
              .map(
                (item) => Movie(
                  id: item['imdbID'] ?? '', // Temporary id
                  imdbId: item['imdbID'],
                  title: item['Title'] ?? '',
                  year: item['Year'] ?? '',
                  genre: '',
                  posterUrl: item['Poster'] != 'N/A' ? item['Poster'] : null,
                  isWatched: false,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  type: item['Type'],
                ),
              )
              .toList();
        } else if (data['Error'] != null) {
          Logger.info('OMDb search API returned error: ${data['Error']}');
          return []; // E.g. "Movie not found!"
        }
      }
      return [];
    } catch (e, st) {
      Logger.error('Failed to search movies from OMDb', e, st);
      return [];
    }
  }
}
