import 'package:flutter/foundation.dart';
import '../models/custom_list.dart';
import '../models/movie.dart';
import '../services/custom_list_service.dart';
import '../services/movie_cache_service.dart';
import '../core/utils/logger.dart';

class CustomListViewModel extends ChangeNotifier {
  final CustomListService _customListService;
  final MovieCacheService _movieCacheService;

  CustomListViewModel({
    CustomListService? customListService,
    MovieCacheService? movieCacheService,
  })  : _customListService = customListService ?? CustomListService(),
        _movieCacheService = movieCacheService ?? MovieCacheService();

  bool isLoading = false;
  String? errorMessage;
  List<CustomList> lists = [];
  List<Movie> _allMovies = [];

  Future<void> init() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      lists = await _customListService.getAllLists();
      _allMovies = await _movieCacheService.getAllMovies();
    } catch (e) {
      errorMessage = e.toString();
      Logger.error('CustomListViewModel init error', e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<Movie> moviesForList(CustomList list) {
    return _allMovies
        .where((m) => list.movieIds.contains(m.id))
        .toList();
  }

  Future<void> createList(String name) async {
    if (name.trim().isEmpty) return;
    try {
      final created = await _customListService.createList(name.trim());
      lists = [created, ...lists];
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteList(String listId) async {
    try {
      await _customListService.deleteList(listId);
      lists = lists.where((l) => l.id != listId).toList();
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> renameList(String listId, String newName) async {
    if (newName.trim().isEmpty) return;
    try {
      await _customListService.renameList(listId, newName.trim());
      lists = lists.map((l) => l.id == listId ? l.copyWith(name: newName.trim()) : l).toList();
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> addMovieToList(String listId, String movieId) async {
    try {
      await _customListService.addMovieToList(listId, movieId);
      lists = lists.map((l) {
        if (l.id == listId && !l.movieIds.contains(movieId)) {
          return l.copyWith(movieIds: [...l.movieIds, movieId]);
        }
        return l;
      }).toList();
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeMovieFromList(String listId, String movieId) async {
    try {
      await _customListService.removeMovieFromList(listId, movieId);
      lists = lists.map((l) {
        if (l.id == listId) {
          return l.copyWith(movieIds: l.movieIds.where((id) => id != movieId).toList());
        }
        return l;
      }).toList();
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  bool isMovieInList(String listId, String movieId) {
    final list = lists.firstWhere((l) => l.id == listId, orElse: () =>
        CustomList(id: '', name: '', movieIds: [], createdAt: DateTime.now(), updatedAt: DateTime.now()));
    return list.movieIds.contains(movieId);
  }

  List<CustomList> listsContainingMovie(String movieId) {
    return lists.where((l) => l.movieIds.contains(movieId)).toList();
  }
}
