import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/movie.dart';
import '../core/database/local_db.dart';
import '../core/utils/logger.dart';

class MovieCacheService {
  MovieCacheService();

  Future<Movie?> getMovieByImdbId(String imdbId) async {
    try {
      final box = LocalDb.movieBox;
      for (final value in box.values) {
        final Map<String, dynamic> jsonMap = jsonDecode(value);
        if (jsonMap['imdb_id'] == imdbId) {
          return Movie.fromJson(jsonMap);
        }
      }
      return null;
    } catch (e, st) {
      Logger.error('Failed to get movie from cache by imdbId', e, st);
      return null;
    }
  }

  Future<List<Movie>> getAllMovies() async {
    try {
      final box = LocalDb.movieBox;
      final List<Movie> movies = [];
      for (final value in box.values) {
        final Map<String, dynamic> jsonMap = jsonDecode(value);
        movies.add(Movie.fromJson(jsonMap));
      }
      movies.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return movies;
    } catch (e, st) {
      Logger.error('Failed to get all movies from cache', e, st);
      return [];
    }
  }

  Future<void> saveMovie(Movie movie) async {
    try {
      final box = LocalDb.movieBox;
      final idToUse = movie.id.isEmpty ? const Uuid().v4() : movie.id;
      final movieToSave = movie.copyWith(id: idToUse);

      await box.put(idToUse, jsonEncode(movieToSave.toJson()));
      Logger.info('Movie saved to cache: ${movieToSave.title}');
    } catch (e, st) {
      Logger.error('Failed to save movie to cache', e, st);
      throw Exception('Failed to save movie');
    }
  }

  Future<void> updateMovie(Movie movie) async {
    try {
      final box = LocalDb.movieBox;
      final movieToUpdate = movie.copyWith(updatedAt: DateTime.now());
      await box.put(movie.id, jsonEncode(movieToUpdate.toJson()));
      Logger.info('Movie updated in cache: ${movie.title}');
    } catch (e, st) {
      Logger.error('Failed to update movie in cache', e, st);
      throw Exception('Failed to update movie');
    }
  }

  Future<void> deleteMovie(String id) async {
    try {
      final box = LocalDb.movieBox;
      await box.delete(id);
      Logger.info('Movie deleted from cache: $id');
    } catch (e, st) {
      Logger.error('Failed to delete movie from cache', e, st);
      throw Exception('Failed to delete movie');
    }
  }

  Future<void> clearAllMovies() async {
    try {
      final box = LocalDb.movieBox;
      await box.clear();
      Logger.info('All movies cleared from cache');
    } catch (e, st) {
      Logger.error('Failed to clear all movies from cache', e, st);
      throw Exception('Failed to clear all movies');
    }
  }
}
