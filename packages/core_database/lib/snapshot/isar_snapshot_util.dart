import 'dart:io';
import 'package:isar/isar.dart';
import '../engine/isar_database.dart';

/// Isar 数据库快照与单库导入/导出工具。
///
/// 遵循单一职责与低耦合原则：
/// 1. 仅负责 Isar 数据库自身的快照导出（基于底层原子 copyToFile）与快照恢复。
/// 2. 不依赖任何 UI、路径服务或分享逻辑。
/// 3. 与外部复合备份工具（如 `BackupUtil`）解耦对接。
class IsarSnapshotUtil {
  IsarSnapshotUtil._();

  /// 为当前打开的 Isar 数据库创建原子快照文件。
  ///
  /// - [targetSnapshotFilePath]: 快照目标文件的绝对路径（如 `/path/to/snapshot.isar`）。
  /// - [isar]: 可选。若不提供则使用默认单例 [IsarDatabase.instance.isar]。
  ///
  /// 注意：如果目标文件已存在，将被原子覆盖。
  static Future<File> createSnapshot({
    required String targetSnapshotFilePath,
    Isar? isar,
  }) async {
    final activeIsar = isar ?? IsarDatabase.instance.isar;
    final targetFile = File(targetSnapshotFilePath);

    // 确保父级目录存在
    final parentDir = targetFile.parent;
    if (!await parentDir.exists()) {
      await parentDir.create(recursive: true);
    }

    // 若已存在旧快照文件，先行清理
    if (await targetFile.exists()) {
      await targetFile.delete();
    }

    // 利用 Isar 引擎内置的原子快照导出能力
    await activeIsar.copyToFile(targetSnapshotFilePath);
    return targetFile;
  }

  /// 从外部快照文件还原 Isar 数据库，并重新打开数据库就绪。
  ///
  /// 还原流程：
  /// 1. 安全关闭当前可能正在运行的同名数据库实例。
  /// 2. 清理目标持久化目录中的旧 Isar 文件（`[dbName].isar` 及其锁文件/WAL文件）。
  /// 3. 将 [sourceSnapshotFile] 复制并重命名到目标目录下的 `[dbName].isar`。
  /// 4. 重新调用 [IsarDatabase.instance.init] 打开并校验加载 Schema。
  ///
  /// 参数：
  /// - [sourceSnapshotFile]: 来源快照文件。
  /// - [directory]: 目标数据库持久化绝对路径目录。
  /// - [schemas]: 必须传入需要加载的集合 Schema 列表。
  /// - [dbName]: 数据库名称，默认为 [Isar.defaultName]。
  static Future<Isar> restoreFromSnapshot({
    required File sourceSnapshotFile,
    required String directory,
    required List<CollectionSchema<dynamic>> schemas,
    String dbName = Isar.defaultName,
  }) async {
    if (!await sourceSnapshotFile.exists()) {
      throw ArgumentError('Source snapshot file does not exist: ${sourceSnapshotFile.path}');
    }

    // 1. 若当前实例开启，则先关闭
    final existingInstance = Isar.getInstance(dbName);
    if (existingInstance != null && existingInstance.isOpen) {
      await existingInstance.close();
    }
    if (IsarDatabase.instance.isOpen) {
      await IsarDatabase.instance.close();
    }

    // 2. 目标数据库目录准备
    final targetDir = Directory(directory);
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    // 3. 清理已有的同名数据库数据文件及锁文件
    final baseIsarFile = File('${targetDir.path}/$dbName.isar');
    final lockFile = File('${targetDir.path}/$dbName.isar.lock');
    if (await baseIsarFile.exists()) {
      await baseIsarFile.delete();
    }
    if (await lockFile.exists()) {
      await lockFile.delete();
    }

    // 4. 将快照文件复制为目标的数据库文件
    await sourceSnapshotFile.copy(baseIsarFile.path);

    // 5. 重新打开数据库
    return await IsarDatabase.instance.init(
      directory: directory,
      schemas: schemas,
      name: dbName,
    );
  }
}
