import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';
import '../models/rating.dart';
import '../core/utils/logger.dart';

class OmdbDetailService {
  static const String _baseUrl = 'https://www.omdbapi.com/';
  // Note: Using a public test key for demonstration
  // In production, this should be in an environment variable
  static const String _apiKey = 'trilogy';

  Future<Movie?> getMovieDetail(String imdbId) async {
    try {
      final uri = Uri.parse('$_baseUrl?i=$imdbId&plot=full&apikey=$_apiKey');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['Response'] == 'True') {
          return Movie(
            id: data['imdbID'] ?? '',
            imdbId: data['imdbID'],
            title: data['Title'] ?? '',
            year: data['Year'] ?? '',
            runtime: data['Runtime'],
            genre: data['Genre'] ?? '',
            awards: data['Awards'],
            posterUrl: data['Poster'] != 'N/A' ? data['Poster'] : null,
            imdbRating: data['imdbRating'],
            imdbVotes: data['imdbVotes'],
            metascore: data['Metascore'],
            ratings:
                (data['Ratings'] as List<dynamic>?)
                    ?.map((e) => Rating.fromJson(e as Map<String, dynamic>))
                    .toList() ??
                [],
            isWatched: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            type: data['Type'],
            plot: data['Plot'],
            director: data['Director'],
            writer: data['Writer'],
            actors: data['Actors'],
            language: data['Language'],
            country: data['Country'],
            boxOffice: data['BoxOffice'],
            rated: data['Rated'],
            released: data['Released'],
          );
        } else if (data['Error'] != null) {
          Logger.info('OMDb detail API returned error: ${data['Error']}');
          return null;
        }
      }
      return null;
    } catch (e, st) {
      Logger.error('Failed to get movie detail from OMDb by id', e, st);
      return null;
    }
  }
}
