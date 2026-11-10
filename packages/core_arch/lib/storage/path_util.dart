import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// 跨平台私有安全沙盒目录解析工具
///
/// 封装各平台（Android / iOS / macOS / Windows / Linux）安全可读写目录，无需任何危险系统存储权限
class PathUtil {
  PathUtil._();

  /// 应用文档目录（适合存放用户生成的文件、持久化数据库、下载的重要文件）
  static Future<Directory> get appDocumentsDirectory async {
    return await getApplicationDocumentsDirectory();
  }

  /// 应用临时缓存目录（系统在存储紧张时可能会自动清理）
  static Future<Directory> get appCacheDirectory async {
    return await getApplicationCacheDirectory();
  }

  /// 临时目录
  static Future<Directory> get temporaryDirectory async {
    return await getTemporaryDirectory();
  }

  /// 应用内部数据支持目录
  static Future<Directory> get appSupportDirectory async {
    return await getApplicationSupportDirectory();
  }
}
