import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import '../extensions/num_extension.dart';
import 'path_util.dart';

/// 工业级跨平台本地文件安全读写与缓存管理工具
class FileUtil {
  FileUtil._();

  // === 1. 目录创建与安全定位 ===

  /// 检查并递归创建目录（若已存在则直接返回，杜绝抛 PathNotFoundException）
  static Future<Directory> createDirIfNotExists(String dirPath) async {
    final dir = Directory(dirPath);
    if (!dir.existsSync()) {
      return await dir.create(recursive: true);
    }
    return dir;
  }

  /// 便捷获取文档目录下的子文件夹（例如 'images', 'audios', 'pdf'）
  ///
  /// 自动保证该子目录在本地文件系统中物理存在
  static Future<Directory> getDocSubDir(String subDirName) async {
    final docDir = await PathUtil.appDocumentsDirectory;
    final targetPath = '${docDir.path}/$subDirName';
    return await createDirIfNotExists(targetPath);
  }

  /// 便捷获取应用缓存目录下的子文件夹（例如 'temp_crops', 'downloads'）
  ///
  /// 自动保证该子目录在本地文件系统中物理存在
  static Future<Directory> getCacheSubDir(String subDirName) async {
    final cacheDir = await PathUtil.appCacheDirectory;
    final targetPath = '${cacheDir.path}/$subDirName';
    return await createDirIfNotExists(targetPath);
  }

  // === 2. 安全写入操作（支持原子写入防损坏） ===

  /// 安全写入二进制字节流（头像、图片、音频、PDF 等）
  ///
  /// - [filePath]: 目标绝对路径
  /// - [bytes]: 二进制字节数据
  /// - [atomic]: 是否开启原子写入（默认 true）。先写入 .tmp 临时文件，写完后通过原子重命名替换，防止写入中途进程被杀损坏旧文件。
  static Future<File> writeBytes(
    String filePath,
    Uint8List bytes, {
    bool atomic = true,
  }) async {
    final targetFile = File(filePath);
    await createDirIfNotExists(targetFile.parent.path);

    if (!atomic) {
      return await targetFile.writeAsBytes(bytes, flush: true);
    }

    final tempFilePath = '$filePath.file_tmp';
    final tempFile = File(tempFilePath);
    if (tempFile.existsSync()) {
      await tempFile.delete();
    }

    try {
      await tempFile.writeAsBytes(bytes, flush: true);
      if (targetFile.existsSync()) {
        await targetFile.delete();
      }
      return await tempFile.rename(filePath);
    } catch (e) {
      if (tempFile.existsSync()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
      rethrow;
    }
  }

  /// 安全写入文本字符串
  ///
  /// - [filePath]: 目标绝对路径
  /// - [content]: 文本内容
  /// - [atomic]: 是否开启原子写入（默认 true）
  static Future<File> writeString(
    String filePath,
    String content, {
    bool atomic = true,
  }) async {
    final targetFile = File(filePath);
    await createDirIfNotExists(targetFile.parent.path);

    if (!atomic) {
      return await targetFile.writeAsString(content, flush: true);
    }

    final tempFilePath = '$filePath.file_tmp';
    final tempFile = File(tempFilePath);
    if (tempFile.existsSync()) {
      await tempFile.delete();
    }

    try {
      await tempFile.writeAsString(content, flush: true);
      if (targetFile.existsSync()) {
        await targetFile.delete();
      }
      return await tempFile.rename(filePath);
    } catch (e) {
      if (tempFile.existsSync()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
      rethrow;
    }
  }

  /// 安全拷贝文件
  static Future<File> copyFile(String sourcePath, String targetPath) async {
    final source = File(sourcePath);
    if (!source.existsSync()) {
      throw PathNotFoundException(sourcePath, const OSError(), '源文件不存在');
    }
    final target = File(targetPath);
    await createDirIfNotExists(target.parent.path);
    return await source.copy(targetPath);
  }

  // === 3. 极速与安全读取（杜绝因文件不存在而崩溃） ===

  /// 安全读取文本内容（若文件不存在或读取失败返回 null，不抛异常）
  static Future<String?> readString(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) return null;
      return await file.readAsString();
    } catch (_) {
      return null;
    }
  }

  /// 安全读取二进制字节数组（若文件不存在返回 null）
  static Future<Uint8List?> readBytes(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) return null;
      return await file.readAsBytes();
    } catch (_) {
      return null;
    }
  }

  /// 判断文件或目录是否存在
  static bool exists(String path) {
    return File(path).existsSync() || Directory(path).existsSync();
  }

  // === 4. 安全删除与大小统计 ===

  /// 安全删除单个文件（若文件不存在静默返回 true）
  static Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (file.existsSync()) {
        await file.delete();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 安全清空/删除目录
  static Future<bool> deleteDir(String dirPath, {bool recursive = true}) async {
    try {
      final dir = Directory(dirPath);
      if (dir.existsSync()) {
        await dir.delete(recursive: recursive);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 获取单个文件的字节大小（若文件不存在返回 0）
  static int getFileSize(String filePath) {
    try {
      final file = File(filePath);
      if (!file.existsSync()) return 0;
      return file.lengthSync();
    } catch (_) {
      return 0;
    }
  }

  /// 递归统计目录占用的真实物理总字节数
  static Future<int> getDirSizeBytes(Directory dir) async {
    if (!dir.existsSync()) return 0;
    var totalSize = 0;
    try {
      final List<FileSystemEntity> entities =
          await dir.list(recursive: true, followLinks: false).toList();
      for (final entity in entities) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
    } catch (_) {}
    return totalSize;
  }

  // === 5. 存储统计与一键清理缓存 (出海 App 设置页标配) ===

  /// 统计应用缓存目录占用的总大小，直接输出出海国际化格式（例如 "12.4 MB", "520 KB"）
  static Future<String> getAppCacheSizeString() async {
    final cacheDir = await PathUtil.appCacheDirectory;
    final totalBytes = await getDirSizeBytes(cacheDir);
    return totalBytes.toByteSizeString();
  }

  /// 一键清空应用临时缓存目录下的所有文件（设置页【清除缓存】专用）
  static Future<bool> clearAppCache() async {
    try {
      final cacheDir = await PathUtil.appCacheDirectory;
      if (!cacheDir.existsSync()) return true;

      final List<FileSystemEntity> entities =
          await cacheDir.list(recursive: false).toList();
      for (final entity in entities) {
        if (entity is File) {
          await entity.delete();
        } else if (entity is Directory) {
          await entity.delete(recursive: true);
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  // === 6. 通用 Zip 压缩与解压能力 ===

  /// 将离散文件集合打包为单一 .zip 文件
  ///
  /// - [files]: 待打包文件列表
  /// - [targetZipPath]: 生成的目标 .zip 路径
  /// - [pathInZipMap]: 可选的文件在压缩包内部的映射路径（如 `{file.path: 'sub/name.txt'}`）
  static Future<File> zipFiles({
    required List<File> files,
    required String targetZipPath,
    Map<String, String>? pathInZipMap,
  }) async {
    final archive = Archive();

    for (final file in files) {
      if (!file.existsSync()) continue;
      final bytes = await file.readAsBytes();
      final nameInZip = pathInZipMap?[file.path] ?? file.uri.pathSegments.last;
      archive.addFile(ArchiveFile(nameInZip, bytes.length, bytes));
    }

    final zipData = ZipEncoder().encode(archive);
    return await writeBytes(targetZipPath, Uint8List.fromList(zipData));
  }

  /// 将整个文件夹目录递归打包压缩为单一 .zip 文件
  static Future<File> zipDirectory({
    required Directory sourceDir,
    required String targetZipPath,
  }) async {
    if (!sourceDir.existsSync()) {
      throw FileSystemException('待压缩的源目录不存在', sourceDir.path);
    }

    final archive = Archive();
    final entities =
        await sourceDir.list(recursive: true, followLinks: false).toList();
    final rootPath = sourceDir.path;

    for (final entity in entities) {
      if (entity is File) {
        final relativePath = entity.path.substring(rootPath.length + 1);
        final bytes = await entity.readAsBytes();
        archive.addFile(ArchiveFile(relativePath, bytes.length, bytes));
      }
    }

    final zipData = ZipEncoder().encode(archive);
    return await writeBytes(targetZipPath, Uint8List.fromList(zipData));
  }

  /// 解压 .zip 文件到指定目录（内置防 Zip Slip 路径穿越注入攻击安全检查）
  static Future<Directory> unzipFile({
    required File zipFile,
    required String targetDirPath,
  }) async {
    if (!zipFile.existsSync()) {
      throw FileSystemException('待解压的 Zip 文件不存在', zipFile.path);
    }

    final targetDir = await createDirIfNotExists(targetDirPath);
    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive) {
      final filename = file.name;
      // 防御 Zip Slip 路径穿越漏洞
      if (filename.contains('..')) {
        continue;
      }

      final outPath = '${targetDir.path}/$filename';
      if (file.isFile) {
        final outFile = File(outPath);
        await createDirIfNotExists(outFile.parent.path);
        final data = file.content as List<int>;
        await outFile.writeAsBytes(data, flush: true);
      } else {
        await createDirIfNotExists(outPath);
      }
    }

    return targetDir;
  }
}
