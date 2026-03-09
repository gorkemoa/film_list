import 'package:hive_flutter/hive_flutter.dart';
import 'db_tables.dart';
import '../utils/logger.dart';

class LocalDb {
  static Future<void> init() async {
    try {
      await Hive.initFlutter();
      await Hive.openBox<String>(DbTables.moviesTable);
      await Hive.openBox<String>(DbTables.reviewsTable);
      await Hive.openBox<String>(DbTables.searchCacheTable);
      Logger.info('Local DB initialized successfully');
    } catch (e, stacktrace) {
      Logger.error('Error initializing Local DB', e, stacktrace);
    }
  }

  static Box<String> get movieBox => Hive.box<String>(DbTables.moviesTable);
  static Box<String> get reviewBox => Hive.box<String>(DbTables.reviewsTable);
  static Box<String> get searchCacheBox =>
      Hive.box<String>(DbTables.searchCacheTable);
}
