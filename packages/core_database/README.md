# core_database

High-performance NoSQL object database package based on [Isar](https://isar.dev), tailored for Flutter applications with zero-schema boilerplate and atomic snapshot backup capabilities.

---

## 🌟 特性 (Features)

1. **Zero-Schema 声明式代码优先 (Code-First)**:
   - 直接存储纯 Dart Class（通过 `@collection` 注解），编译期强类型校验，零手写 SQL DDL。
2. **极低模块耦合 (Decoupled & Pure)**:
   - 数据库存储路径显式由调用方传入，完全解耦上层路径模块（不依赖 `PathUtil`）。
3. **单库快照与原子备份 (Snapshot Support)**:
   - 提供 `IsarSnapshotUtil.createSnapshot()` 导出单库快照，支持无缝接入全局复合备份机制（如 `BackupUtil`）。
   - 提供 `IsarSnapshotUtil.restoreFromSnapshot()` 安全还原覆盖旧数据库并即时初始化。
4. **强类型通用 DAO 抽象 (BaseIsarDao)**:
   - 预封装完整的 CRUD、分页 (`getPaged`)、统计 (`count`) 与轻量级响应式监听 (`watchLazy` / `watchObject`)。

---

## 📦 模块架构设计

```
packages/core_database/
├── lib/
│   ├── core_database.dart         # 统一 Barrel 导出文件
│   ├── engine/
│   │   └── isar_database.dart     # Isar 数据库引擎生命周期管理（单例/打开/关闭/清空/压缩）
│   ├── dao/
│   │   └── base_isar_dao.dart     # 强类型通用 DAO 基类（CRUD/分页/流监听）
│   └── snapshot/
│       └── isar_snapshot_util.dart# 单库原子快照创建与恢复工具（对接 BackupUtil）
```

---

## 🚀 快速上手 (Quick Start)

### 1. 声明数据实体模型 (Model)

```dart
import 'package:core_database/core_database.dart';

part 'user_profile.g.dart';

@collection
class UserProfile {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String userId;

  late String nickname;

  int age = 0;

  DateTime? updatedAt;
}
```

执行生成代码：
```bash
dart run build_runner build
```

---

### 2. 初始化数据库引擎 (Initialization)

> **注意**：存储目录 `directory` 必须由外部显式传入（例如在主工程中通过 `PathUtil.getDatabaseDir()` 获取后传递），保持底座极简无侵入。

```dart
import 'package:core_database/core_database.dart';

Future<void> setupDatabase(String storageDirectory) async {
  await IsarDatabase.instance.init(
    directory: storageDirectory,
    schemas: [
      UserProfileSchema,
    ],
    // 可选参数：
    // name: 'my_app_db',
    // encryptionKey: 'my-aes-key',
    // inspector: kDebugMode,
  );
}
```

---

### 3. 创建专属 DAO 并操作数据 (DAO Usage)

```dart
class UserDao extends BaseIsarDao<UserProfile> {
  // 继承 BaseIsarDao 后，即可直接使用 put, putAll, getById, getAll, getPaged, delete 等通用方法。

  // 支持扩展特定业务查询逻辑
  Future<UserProfile?> findByUserId(String userId) async {
    return await collection.filter().userIdEqualTo(userId).findFirst();
  }
}
```

---

### 4. 配合 `BackupUtil` 进行备份与还原

#### 导出快照供全量打包
```dart
// 1. 生成单库快照文件
final snapshotFile = await IsarSnapshotUtil.createSnapshot(
  targetSnapshotFilePath: '/path/to/cache/db_snapshot.isar',
);

// 2. 传入 core_arch 的 BackupUtil 打包成 .bak 文件
final backupResult = await BackupUtil.createBackup(
  databaseSnapshotFile: snapshotFile,
  attachmentsDir: Directory('/path/to/attachments'),
  targetBackupPath: '/path/to/backups/app_backup.bak',
  manifest: BackupManifest(
    appVersion: '1.0.0',
    createdAt: DateTime.now(),
    schemaVersion: 1,
  ),
);
```

#### 从备份文件还原
```dart
// 1. 解压备份文件包
final extractResult = await BackupUtil.extractBackup(
  backupFile: File('/path/to/backups/app_backup.bak'),
  targetExtractDir: Directory('/path/to/cache/extracted'),
);

if (extractResult.isSuccess) {
  final extracted = extractResult.data!;

  // 2. 从解压得到的 snapshot 文件还原数据库
  await IsarSnapshotUtil.restoreFromSnapshot(
    sourceSnapshotFile: extracted.databaseFile!,
    directory: storageDirectory,
    schemas: [UserProfileSchema],
  );
}
```
