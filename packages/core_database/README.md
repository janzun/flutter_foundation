# core_database

基于 Isar 的高性能 NoSQL 实体数据库底座，提供代码优先（Code-First）、零手写 SQL、跨表原子事务与原子防毁库快照导入导出支持。

## 🏷️ 最新版本 Tag

`core_database-v1.0.0`

## 📦 接入方式 (Installation)

```yaml
dependencies:
  core_database:
    git:
      url: https://github.com/janzun/flutter_foundation.git
      path: packages/core_database
      ref: core_database-v1.0.0

dev_dependencies:
  build_runner: ^2.4.11
  isar_generator: 3.1.0+1
```

## ⚙️ 必要配置 (Configuration)

纯 Dart + Isar 引擎，无需任何敏感系统权限。

---

## 📚 完整 API 列表 (API Reference)

### 1. 数据库引擎生命周期 (`IsarDatabase`)

```dart
class IsarDatabase {
  static final IsarDatabase instance;

  /// 获取当前已初始化的默认 Isar 实例 (未初始化抛出 StateError)
  Isar get isar;

  /// 检查数据库是否打开就绪
  bool get isOpen;

  /// 初始化并打开数据库 (存储路径由外部显式传入，彻底解耦 PathUtil)
  Future<Isar> init({
    required String directory,
    required List<CollectionSchema<dynamic>> schemas,
    String name = Isar.defaultName,
    int maxSizeMiB = Isar.defaultMaxSizeMiB,
    bool relaxedDurability = true,
    bool inspector = false,
    CompactCondition? compactOnLaunch,
  });

  /// 关闭数据库 (可配置是否同时删除磁盘数据)
  Future<bool> close({bool deleteFromDisk = false});

  /// 清空当前数据库中的所有集合数据
  Future<void> clearAll();

  /// 执行跨表原子写事务 (支持跨多个 DAO 编排写操作)
  Future<T> writeTxn<T>(Future<T> Function() callback, {bool silent = false});

  /// 执行只读事务
  Future<T> txn<T>(Future<T> Function() callback);

  /// 获取数据库总占用字节大小
  Future<int> getSize({bool includeIndexes = false, bool includeLinks = false});
}
```

### 2. 强类型通用实体 DAO 基类 (`BaseIsarDao<T>`)

业务 DAO 继承该类，即可获得完整 CRUD、独立事务方法及响应式监听：

```dart
abstract class BaseIsarDao<T> {
  const BaseIsarDao();

  Isar get isar;
  IsarCollection<T> get collection;

  // --- 单独调用 (内置 writeTxn) ---
  Future<Id> put(T entity);
  Future<List<Id>> putAll(List<T> entities);
  Future<bool> delete(Id id);
  Future<int> deleteAll(List<Id> ids);
  Future<void> clear();

  // --- 在外部事务中组合使用 (供 IsarDatabase.instance.writeTxn 内部调用，防嵌套崩溃) ---
  Future<Id> putInTxn(T entity);
  Future<List<Id>> putAllInTxn(List<T> entities);
  Future<bool> deleteInTxn(Id id);
  Future<int> deleteAllInTxn(List<Id> ids);
  Future<void> clearInTxn();

  // --- 查询与监听 ---
  Future<T?> getById(Id id);
  Future<List<T?>> getAllByIds(List<Id> ids);
  Future<List<T>> getAll();
  Future<List<T>> getPaged({required int offset, required int limit});
  Future<int> count();

  /// 响应式监听当前集合全量列表流 (极速绑定 UI)
  Stream<List<T>> watchAll({bool fireImmediately = true});

  /// 响应式监听任意增删改通知流 (轻量防抖)
  Stream<void> watchLazy({bool fireImmediately = false});

  /// 响应式监听特定对象变化
  Stream<T?> watchObject(Id id, {bool fireImmediately = false});
}
```

### 3. 单库快照与安全还原 (`IsarSnapshotUtil`)

```dart
class IsarSnapshotUtil {
  /// 创建当前数据库的原子快照文件 (直接供 BackupUtil 聚合打包)
  static Future<File> createSnapshot({
    required String targetSnapshotFilePath,
    Isar? isar,
  });

  /// 从外部快照文件还原数据库 (带 .rollback_tmp 自动回滚防毁库机制)
  static Future<Isar> restoreFromSnapshot({
    required File sourceSnapshotFile,
    required String directory,
    required List<CollectionSchema<dynamic>> schemas,
    String dbName = Isar.defaultName,
  });
}
```
