import 'dart:developer' as developer;

enum LogLevel { info, debug, error }

class Logger {
  static void info(String message) {
    _log(LogLevel.info, message);
  }

  static void debug(String message) {
    _log(LogLevel.debug, message);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, error, stackTrace);
  }

  static void _log(
    LogLevel level,
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    final time = DateTime.now().toIso8601String();
    developer.log(
      '[$time] ${level.name.toUpperCase()}: $message',
      name: 'APP_LOGGER',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
