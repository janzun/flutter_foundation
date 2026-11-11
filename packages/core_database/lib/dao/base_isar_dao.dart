import 'package:isar/isar.dart';
import '../engine/isar_database.dart';

/// 通用实体持久化基类 DAO。
///
/// 封装针对具体集合实体类型 [T] 的常用 CRUD、批量操作、分页与响应式监听。
/// 业务模块可通过继承该类并配合 Isar 生成的 Query 扩展轻松扩展自定义查询。
abstract class BaseIsarDao<T> {
  const BaseIsarDao();

  /// 获取对应的 Isar 数据库实例，默认复用 [IsarDatabase.instance.isar]。
  /// 子类可按需覆盖以指向特定命名实例。
  Isar get isar => IsarDatabase.instance.isar;

  /// 获取对应的 [IsarCollection<T>]。
  IsarCollection<T> get collection => isar.collection<T>();

  /// 保存单个实体（插入或全量更新）。
  /// 返回写入后的自增或分配的主键 ID。
  Future<Id> put(T entity) async {
    return await isar.writeTxn(() async {
      return await collection.put(entity);
    });
  }

  /// 批量保存实体（插入或全量更新）。
  /// 返回写入后实体的主键 ID 列表。
  Future<List<Id>> putAll(List<T> entities) async {
    return await isar.writeTxn(() async {
      return await collection.putAll(entities);
    });
  }

  /// 根据主键 ID 获取单个实体。找不到返回 null。
  Future<T?> getById(Id id) async {
    return await collection.get(id);
  }

  /// 根据一组主键 ID 批量获取实体。
  Future<List<T?>> getAllByIds(List<Id> ids) async {
    return await collection.getAll(ids);
  }

  /// 查询集合中的所有实体。
  Future<List<T>> getAll() async {
    return await collection.where().findAll();
  }

  /// 分页查询集合实体。
  ///
  /// - [offset]: 偏移量，从 0 开始。
  /// - [limit]: 每页记录数限制。
  Future<List<T>> getPaged({required int offset, required int limit}) async {
    return await collection.where().offset(offset).limit(limit).findAll();
  }

  /// 获取当前集合中的总实体数。
  Future<int> count() async {
    return await collection.count();
  }

  /// 根据主键 ID 删除单个实体。
  /// 若删除成功返回 true，实体不存在返回 false。
  Future<bool> delete(Id id) async {
    return await isar.writeTxn(() async {
      return await collection.delete(id);
    });
  }

  /// 根据一组主键 ID 批量删除实体。
  /// 返回实际成功删除的记录数。
  Future<int> deleteAll(List<Id> ids) async {
    return await isar.writeTxn(() async {
      return await collection.deleteAll(ids);
    });
  }

  /// 清空当前实体集合的所有数据。
  Future<void> clear() async {
    await isar.writeTxn(() async {
      await collection.clear();
    });
  }

  /// 响应式监听当前集合中任意对象增删改的通知流（不含具体数据负载，轻量防抖）。
  Stream<void> watchLazy({bool fireImmediately = false}) {
    return collection.watchLazy(fireImmediately: fireImmediately);
  }

  /// 响应式监听特定主键 ID 实体的变化。
  Stream<T?> watchObject(Id id, {bool fireImmediately = false}) {
    return collection.watchObject(id, fireImmediately: fireImmediately);
  }
}
