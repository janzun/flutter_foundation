import 'package:flutter/foundation.dart';

/// 生产级彩色环境隔离日志系统
class Logger {
  Logger._();

  static const String _reset = '\x1B[0m';
  static const String _blue = '\x1B[34m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _red = '\x1B[31m';

  /// Debug 级别调试日志（仅在 kDebugMode 下输出）
  static void d(
    dynamic message, {
    String tag = 'DEBUG',
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log('DEBUG', _blue, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Info 级别信息日志
  static void i(
    dynamic message, {
    String tag = 'INFO',
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log('INFO', _green, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Warning 级别警告日志
  static void w(
    dynamic message, {
    String tag = 'WARN',
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log('WARN', _yellow, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Error 级别错误日志
  static void e(
    dynamic message, {
    String tag = 'ERROR',
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log('ERROR', _red, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void _log(
    String level,
    String color,
    dynamic message, {
    required String tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;

    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}.${now.millisecond.toString().padLeft(3, '0')}';

    final buffer = StringBuffer()
      ..write('$color[$level][$timeStr][$tag] $message$_reset');

    if (error != null) {
      buffer.write('\n$color  Error: $error$_reset');
    }
    if (stackTrace != null) {
      buffer.write('\n$color  StackTrace:\n$stackTrace$_reset');
    }

    debugPrint(buffer.toString());
  }
}
