import 'dart:developer' as dev;

class AppLogger {
  static void debug(String message) => dev.log(message, name: 'DEBUG');
  static void info(String message) => dev.log(message, name: 'INFO');
  static void warning(String message) => dev.log(message, name: 'WARNING');
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    dev.log(message, name: 'ERROR', error: error, stackTrace: stackTrace);
  }
}
