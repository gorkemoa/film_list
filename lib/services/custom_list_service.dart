import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/custom_list.dart';
import '../core/database/local_db.dart';
import '../core/utils/logger.dart';

class CustomListService {
  Future<List<CustomList>> getAllLists() async {
    try {
      final box = LocalDb.customListBox;
      final List<CustomList> lists = [];
      for (final value in box.values) {
        final Map<String, dynamic> jsonMap = jsonDecode(value);
        lists.add(CustomList.fromJson(jsonMap));
      }
      lists.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return lists;
    } catch (e, st) {
      Logger.error('Failed to get custom lists', e, st);
      return [];
    }
  }

  Future<CustomList?> getListById(String id) async {
    try {
      final box = LocalDb.customListBox;
      final value = box.get(id);
      if (value == null) return null;
      return CustomList.fromJson(jsonDecode(value));
    } catch (e, st) {
      Logger.error('Failed to get custom list: $id', e, st);
      return null;
    }
  }

  Future<CustomList> createList(String name) async {
    try {
      final list = CustomList(
        id: const Uuid().v4(),
        name: name,
        movieIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final box = LocalDb.customListBox;
      await box.put(list.id, jsonEncode(list.toJson()));
      Logger.info('Custom list created: $name');
      return list;
    } catch (e, st) {
      Logger.error('Failed to create custom list', e, st);
      throw Exception('Failed to create list');
    }
  }

  Future<void> addMovieToList(String listId, String movieId) async {
    try {
      final list = await getListById(listId);
      if (list == null) throw Exception('List not found');
      if (list.movieIds.contains(movieId)) return;
      final updated = list.copyWith(
        movieIds: [...list.movieIds, movieId],
        updatedAt: DateTime.now(),
      );
      final box = LocalDb.customListBox;
      await box.put(listId, jsonEncode(updated.toJson()));
      Logger.info('Movie $movieId added to list $listId');
    } catch (e, st) {
      Logger.error('Failed to add movie to list', e, st);
      throw Exception('Failed to add movie');
    }
  }

  Future<void> removeMovieFromList(String listId, String movieId) async {
    try {
      final list = await getListById(listId);
      if (list == null) return;
      final updated = list.copyWith(
        movieIds: list.movieIds.where((id) => id != movieId).toList(),
        updatedAt: DateTime.now(),
      );
      final box = LocalDb.customListBox;
      await box.put(listId, jsonEncode(updated.toJson()));
      Logger.info('Movie $movieId removed from list $listId');
    } catch (e, st) {
      Logger.error('Failed to remove movie from list', e, st);
      throw Exception('Failed to remove movie');
    }
  }

  Future<void> deleteList(String listId) async {
    try {
      final box = LocalDb.customListBox;
      await box.delete(listId);
      Logger.info('Custom list deleted: $listId');
    } catch (e, st) {
      Logger.error('Failed to delete custom list', e, st);
      throw Exception('Failed to delete list');
    }
  }

  Future<void> renameList(String listId, String newName) async {
    try {
      final list = await getListById(listId);
      if (list == null) throw Exception('List not found');
      final updated = list.copyWith(name: newName, updatedAt: DateTime.now());
      final box = LocalDb.customListBox;
      await box.put(listId, jsonEncode(updated.toJson()));
      Logger.info('Custom list renamed: $listId → $newName');
    } catch (e, st) {
      Logger.error('Failed to rename custom list', e, st);
      throw Exception('Failed to rename list');
    }
  }
}
