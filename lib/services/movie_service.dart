import 'dart:convert';
import '../models/movie.dart';
import '../core/database/local_db.dart';
import '../core/utils/logger.dart';

class MovieService {
  Future<List<Movie>> getMovies() async {
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
      Logger.error('Failed to get movies', e, st);
      return [];
    }
  }

  Future<void> addMovie(Movie movie) async {
    try {
      final box = LocalDb.movieBox;
      await box.put(movie.id, jsonEncode(movie.toJson()));
      Logger.info('Movie added: ${movie.title}');
    } catch (e, st) {
      Logger.error('Failed to add movie', e, st);
      throw Exception('Failed to add movie');
    }
  }

  Future<void> toggleWatched(Movie movie) async {
    try {
      final updatedMovie = movie.copyWith(isWatched: !movie.isWatched);
      await addMovie(updatedMovie);
      Logger.info('Movie watched status toggled: ${updatedMovie.title}');
    } catch (e, st) {
      Logger.error('Failed to toggle watched status', e, st);
      throw Exception('Failed to toggle watched status');
    }
  }

  Future<void> deleteMovie(String id) async {
    try {
      final box = LocalDb.movieBox;
      await box.delete(id);
      Logger.info('Movie deleted: $id');
    } catch (e, st) {
      Logger.error('Failed to delete movie', e, st);
      throw Exception('Failed to delete movie');
    }
  }
}
