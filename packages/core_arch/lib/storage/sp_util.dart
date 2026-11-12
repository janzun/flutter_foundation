import 'package:shared_preferences/shared_preferences.dart';

/// 基于 SharedPreferences 的轻量级本地键值存储工具类
///
/// 采用应用启动时预初始化单例，支持完全同步的内存读取与可靠的异步后台落盘
class SpUtil {
  SpUtil._();

  static SharedPreferences? _prefs;

  /// 在应用启动（如 SplashViewModel 或 main 入口）初始化预加载缓存
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get _instance {
    if (_prefs == null) {
      throw StateError(
        'SpUtil 尚未初始化！请在应用启动阶段先调用 await SpUtil.init();',
      );
    }
    return _prefs!;
  }

  // === 同步读取方法 (无需 await，直接从内存缓存获取) ===

  /// 读取字符串
  static String getString(String key, {String defaultValue = ''}) {
    return _instance.getString(key) ?? defaultValue;
  }

  /// 读取布尔值
  static bool getBool(String key, {bool defaultValue = false}) {
    return _instance.getBool(key) ?? defaultValue;
  }

  /// 读取整型
  static int getInt(String key, {int defaultValue = 0}) {
    return _instance.getInt(key) ?? defaultValue;
  }

  /// 读取浮点型
  static double getDouble(String key, {double defaultValue = 0.0}) {
    return _instance.getDouble(key) ?? defaultValue;
  }

  /// 读取字符串列表
  static List<String> getStringList(
    String key, {
    List<String> defaultValue = const [],
  }) {
    return _instance.getStringList(key) ?? defaultValue;
  }

  /// 判断键是否存在
  static bool containsKey(String key) {
    return _instance.containsKey(key);
  }

  // === 异步写入与持久化方法 (使用 await) ===

  /// 写入字符串
  static Future<bool> setString(String key, String value) async {
    return await _instance.setString(key, value);
  }

  /// 写入布尔值
  static Future<bool> setBool(String key, bool value) async {
    return await _instance.setBool(key, value);
  }

  /// 写入整型
  static Future<bool> setInt(String key, int value) async {
    return await _instance.setInt(key, value);
  }

  /// 写入浮点型
  static Future<bool> setDouble(String key, double value) async {
    return await _instance.setDouble(key, value);
  }

  /// 写入字符串列表
  static Future<bool> setStringList(String key, List<String> value) async {
    return await _instance.setStringList(key, value);
  }

  /// 移除指定键
  static Future<bool> remove(String key) async {
    return await _instance.remove(key);
  }

  /// 清空所有键值
  static Future<bool> clear() async {
    return await _instance.clear();
  }

  // === 全量导出与导入恢复 (备份与还原闭环) ===

  /// 导出当前 SharedPreferences 中的所有键值数据为字典
  ///
  /// - [excludeKeys]: 可选排除的键名集合（如隐私协议状态、临时时间戳等无需跨设备迁移的键）
  static Map<String, dynamic> exportAll({Set<String>? excludeKeys}) {
    final allKeys = _instance.getKeys();
    final result = <String, dynamic>{};

    for (final key in allKeys) {
      if (excludeKeys != null && excludeKeys.contains(key)) continue;
      final val = _instance.get(key);
      if (val != null) {
        if (val is List<String>) {
          result[key] = List<String>.from(val);
        } else {
          result[key] = val;
        }
      }
    }

    return result;
  }

  /// 从字典全量导入/恢复键值数据
  ///
  /// - [data]: 导入的数据字典（如由 BackupExtractedData.kvData 解包得到）
  /// - [clearBefore]: 导入前是否先清空当前现有的所有数据，默认 false
  ///
  /// 自动防御 JSON 反序列化导致的 `List<dynamic>` 强转类型丢失陷阱。
  static Future<bool> importAll(
    Map<String, dynamic> data, {
    bool clearBefore = false,
  }) async {
    if (clearBefore) {
      await clear();
    }

    var allSuccess = true;

    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value == null) continue;

      bool success = false;
      if (value is bool) {
        success = await setBool(key, value);
      } else if (value is int) {
        success = await setInt(key, value);
      } else if (value is double) {
        success = await setDouble(key, value);
      } else if (value is String) {
        success = await setString(key, value);
      } else if (value is List) {
        // 关键防御：JSON 解码出来的类型为 List<dynamic>，必须安全转换为 List<String>
        final stringList = value.map((e) => e.toString()).toList();
        success = await setStringList(key, stringList);
      }

      if (!success) {
        allSuccess = false;
      }
    }

    return allSuccess;
  }

  // === 常用业务预置属性 ===

  static const String _kKeyPrivacyAgreed = 'core_arch_sp_privacy_agreed';

  /// 用户是否已同意隐私协议政策
  static bool get isPrivacyAgreed => getBool(_kKeyPrivacyAgreed);

  /// 设置隐私政策同意状态
  static Future<bool> setPrivacyAgreed(bool agreed) async {
    return await setBool(_kKeyPrivacyAgreed, agreed);
  }
}
