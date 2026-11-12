import 'dart:convert';
import 'dart:io';
import '../mvvm/result.dart';
import 'file_util.dart';

/// 备份清单元数据
class BackupManifest {
  /// 备份格式版本号
  final int schemaVersion;

  /// 应用版本标识（可选）
  final String? appVersion;

  /// 备份创建时间戳
  final DateTime createdAt;

  /// 额外业务元数据
  final Map<String, dynamic> extraMeta;

  const BackupManifest({
    required this.schemaVersion,
    this.appVersion,
    required this.createdAt,
    this.extraMeta = const {},
  });

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'appVersion': appVersion,
        'createdAt': createdAt.toIso8601String(),
        'extraMeta': extraMeta,
      };

  factory BackupManifest.fromJson(Map<String, dynamic> json) {
    return BackupManifest(
      schemaVersion: json['schemaVersion'] as int? ?? 1,
      appVersion: json['appVersion'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      extraMeta: (json['extraMeta'] as Map<String, dynamic>?) ?? {},
    );
  }
}

/// 解压提炼出的备份数据结果载体
class BackupExtractedData {
  /// 解析出的备份清单元数据
  final BackupManifest manifest;

  /// 解压出的数据库快照文件（若备份包中存在）
  final File? databaseFile;

  /// 解压出的附件/资源目录（若备份包中存在）
  final Directory? attachmentsDir;

  /// 解压恢复出的键值配置字典（若备份包中存在）
  final Map<String, dynamic>? kvData;

  const BackupExtractedData({
    required this.manifest,
    this.databaseFile,
    this.attachmentsDir,
    this.kvData,
  });
}

/// 全局多源数据全量备份与解包总指挥工具
///
/// 专注纯文件装配与还原，不内置调用系统分享，将后续控制权交还给业务层
class BackupUtil {
  BackupUtil._();

  static const String _kManifestFileName = 'backup_manifest.json';
  static const String _kKvDataFileName = 'backup_kv_data.json';
  static const String _kDatabaseSnapshotName = 'database_snapshot.bin';
  static const String _kAttachmentsDirName = 'attachments';

  /// 创建全量聚合备份文件 (.bak)
  ///
  /// - [targetBackupFilePath]: 目标保存全路径（如 /tmp/app_backup_20261111.bak）
  /// - [databaseFile]: 业务数据库物理快照文件（由 core_database 或 SQLite 提供，可选）
  /// - [attachmentDirs]: 附件与用户文件目录列表（由业务或 FileUtil 提供，可选）
  /// - [kvData]: 简单键值配置（由 SpUtil 或业务 Map 提供，可选）
  /// - [schemaVersion]: 数据结构版本号（用于导入时做版本兼容性检查）
  /// - [appVersion]: 当前 App 版本号
  /// - [extraMeta]: 额外业务元数据
  static Future<Result<File>> createBackup({
    required String targetBackupFilePath,
    File? databaseFile,
    List<Directory>? attachmentDirs,
    Map<String, dynamic>? kvData,
    int schemaVersion = 1,
    String? appVersion,
    Map<String, dynamic>? extraMeta,
  }) async {
    final tempWorkspace =
        Directory.systemTemp.createTempSync('backup_meta_workspace_');

    try {
      final manifest = BackupManifest(
        schemaVersion: schemaVersion,
        appVersion: appVersion,
        createdAt: DateTime.now(),
        extraMeta: extraMeta ?? {},
      );

      final filesToPack = <File>[];
      final pathInZipMap = <String, String>{};

      // 1. 写入 manifest.json 进元数据临时工作区
      final manifestFile = File('${tempWorkspace.path}/$_kManifestFileName');
      await manifestFile.writeAsString(jsonEncode(manifest.toJson()));
      filesToPack.add(manifestFile);
      pathInZipMap[manifestFile.path] = _kManifestFileName;

      // 2. 写入 kvData.json (若存在)
      if (kvData != null && kvData.isNotEmpty) {
        final kvFile = File('${tempWorkspace.path}/$_kKvDataFileName');
        await kvFile.writeAsString(jsonEncode(kvData));
        filesToPack.add(kvFile);
        pathInZipMap[kvFile.path] = _kKvDataFileName;
      }

      // 3. 收集数据库快照 (直接指向源文件，零冗余磁盘拷贝)
      if (databaseFile != null && databaseFile.existsSync()) {
        filesToPack.add(databaseFile);
        pathInZipMap[databaseFile.path] = _kDatabaseSnapshotName;
      }

      // 4. 收集附件目录 (隔离各目录名称空间，解决同名覆盖 Bug，且零二次磁盘拷贝)
      if (attachmentDirs != null && attachmentDirs.isNotEmpty) {
        for (final dir in attachmentDirs) {
          if (!dir.existsSync()) continue;
          final dirName = dir.uri.pathSegments
              .where((s) => s.isNotEmpty)
              .lastOrNull ??
              'default';

          final entities =
              await dir.list(recursive: true, followLinks: false).toList();
          final rootLen = dir.path.length;

          for (final entity in entities) {
            if (entity is File) {
              final relativePath = entity.path.substring(rootLen + 1);
              // 以 attachments/<dirName>/<relativePath> 格式隔离命名空间
              final inZipPath =
                  '$_kAttachmentsDirName/$dirName/$relativePath';
              filesToPack.add(entity);
              pathInZipMap[entity.path] = inZipPath;
            }
          }
        }
      }

      // 5. 整体流式打包为目标 .bak (本质为 Zip)
      final finalBakFile = await FileUtil.zipFiles(
        files: filesToPack,
        targetZipPath: targetBackupFilePath,
        pathInZipMap: pathInZipMap,
      );

      return Result.ok(finalBakFile);
    } catch (e) {
      return Result.err(
        AppException(
          code: 'BACKUP_CREATE_FAILED',
          message: '创建备份文件失败: $e',
          originalError: e,
        ),
      );
    } finally {
      // 清理临时元数据工作区
      try {
        await tempWorkspace.delete(recursive: true);
      } catch (_) {}
    }
  }

  /// 从备份文件中提取并解包数据
  ///
  /// - [backupFile]: 待解包的 .bak 备份文件
  /// - [targetExtractDir]: 解压工作区目录
  /// - [expectedMaxSchemaVersion]: 当前 App 能够兼容的最大备份版本（防低版本 App 强行还原高版本数据导致崩溃）
  static Future<Result<BackupExtractedData>> extractBackup({
    required File backupFile,
    required String targetExtractDir,
    int? expectedMaxSchemaVersion,
  }) async {
    if (!backupFile.existsSync()) {
      return const Result.err(
        AppException(
          code: 'BACKUP_FILE_NOT_FOUND',
          message: '备份文件不存在',
        ),
      );
    }

    try {
      // 1. 解压备份包
      final extractedDir = await FileUtil.unzipFile(
        zipFile: backupFile,
        targetDirPath: targetExtractDir,
      );

      // 2. 读取并校验 manifest.json
      final manifestFile = File('${extractedDir.path}/$_kManifestFileName');
      if (!manifestFile.existsSync()) {
        return const Result.err(
          AppException(
            code: 'INVALID_BACKUP_PACKAGE',
            message: '备份包格式非法，未找到清单配置文件',
          ),
        );
      }

      final manifestJson =
          jsonDecode(await manifestFile.readAsString()) as Map<String, dynamic>;
      final manifest = BackupManifest.fromJson(manifestJson);

      // 版本兼容性检查
      if (expectedMaxSchemaVersion != null &&
          manifest.schemaVersion > expectedMaxSchemaVersion) {
        return Result.err(
          AppException(
            code: 'BACKUP_VERSION_INCOMPATIBLE',
            message:
                '该备份由更高版本应用创建 (Schema v${manifest.schemaVersion})，当前应用最高仅支持 v$expectedMaxSchemaVersion，请先升级应用后再恢复！',
          ),
        );
      }

      // 3. 提取数据库快照文件 (若存在)
      File? dbFile;
      final rawDbFile = File('${extractedDir.path}/$_kDatabaseSnapshotName');
      if (rawDbFile.existsSync()) {
        dbFile = rawDbFile;
      }

      // 4. 提取附件目录 (若存在)
      Directory? attachmentsDir;
      final rawAttachmentsDir =
          Directory('${extractedDir.path}/$_kAttachmentsDirName');
      if (rawAttachmentsDir.existsSync()) {
        attachmentsDir = rawAttachmentsDir;
      }

      // 5. 提取 KV 数据 (若存在)
      Map<String, dynamic>? kvData;
      final kvFile = File('${extractedDir.path}/$_kKvDataFileName');
      if (kvFile.existsSync()) {
        kvData = jsonDecode(await kvFile.readAsString()) as Map<String, dynamic>?;
      }

      return Result.ok(
        BackupExtractedData(
          manifest: manifest,
          databaseFile: dbFile,
          attachmentsDir: attachmentsDir,
          kvData: kvData,
        ),
      );
    } catch (e) {
      return Result.err(
        AppException(
          code: 'BACKUP_EXTRACT_FAILED',
          message: '解压备份文件失败: $e',
          originalError: e,
        ),
      );
    }
  }
}
