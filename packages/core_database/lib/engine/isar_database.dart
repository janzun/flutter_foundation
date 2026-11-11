import 'package:isar/isar.dart';

/// Isar 数据库引擎生命周期管理类。
///
/// 遵循低耦合设计：
/// 1. 不依赖外部路径工具（不调用 PathUtil），由调用方显式传入持久化路径 [directory]。
/// 2. 支持单例实例获取与命名实例支持。
/// 3. 提供初始化、关闭、清空数据等核心生命周期方法。
class IsarDatabase {
  IsarDatabase._();

  static final IsarDatabase instance = IsarDatabase._();

  Isar? _isar;

  /// 获取当前已初始化的默认 [Isar] 实例。
  ///
  /// 若未初始化则抛出 [StateError]。
  Isar get isar {
    final current = _isar;
    if (current == null || !current.isOpen) {
      throw StateError(
        'IsarDatabase is not initialized or has been closed. '
        'Call IsarDatabase.instance.init() first.',
      );
    }
    return current;
  }

  /// 检查数据库是否已就绪且处于打开状态。
  bool get isOpen => _isar?.isOpen ?? false;

  /// 初始化并打开 Isar 数据库。
  ///
  /// - [directory]: 必填。数据库文件存储所在绝对路径（降低与路径模块的耦合，必须显式传入）。
  /// - [schemas]: 必填。注册的数据集合模型 Schema 列表。
  /// - [name]: 数据库实例名称，默认为 [Isar.defaultName]。
  /// - [maxSizeMiB]: 数据库最大分配内存大小 (MiB)，默认 [Isar.defaultMaxSizeMiB]。
  /// - [relaxedDurability]: 是否开启宽松持久化以换取写性能，默认 true。
  /// - [inspector]: 是否启用开发期 Inspector，默认 false。
  /// - [compactOnLaunch]: 打开时自动压缩数据库条件配置。
  Future<Isar> init({
    required String directory,
    required List<CollectionSchema<dynamic>> schemas,
    String name = Isar.defaultName,
    int maxSizeMiB = Isar.defaultMaxSizeMiB,
    bool relaxedDurability = true,
    bool inspector = false,
    CompactCondition? compactOnLaunch,
  }) async {
    // 若同名实例已打开，直接复用
    final existingInstance = Isar.getInstance(name);
    if (existingInstance != null && existingInstance.isOpen) {
      _isar = existingInstance;
      return existingInstance;
    }

    final openedIsar = await Isar.open(
      schemas,
      directory: directory,
      name: name,
      maxSizeMiB: maxSizeMiB,
      relaxedDurability: relaxedDurability,
      inspector: inspector,
      compactOnLaunch: compactOnLaunch,
    );

    _isar = openedIsar;
    return openedIsar;
  }

  /// 关闭当前数据库。
  ///
  /// [deleteFromDisk]: 若为 true，关闭同时删除磁盘上的所有数据文件，默认 false。
  Future<bool> close({bool deleteFromDisk = false}) async {
    final current = _isar;
    if (current == null || !current.isOpen) {
      _isar = null;
      return true;
    }

    final success = await current.close(deleteFromDisk: deleteFromDisk);
    _isar = null;
    return success;
  }

  /// 清空当前数据库中的所有集合数据（不删除数据库文件结构）。
  Future<void> clearAll() async {
    final current = isar;
    await current.writeTxn(() async {
      await current.clear();
    });
  }

  /// 获取当前数据库集合数据占用的总磁盘字节大小。
  Future<int> getSize({bool includeIndexes = false, bool includeLinks = false}) async {
    final current = isar;
    return await current.getSize(
      includeIndexes: includeIndexes,
      includeLinks: includeLinks,
    );
  }
}
