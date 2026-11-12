# core_arch

工业级 Flutter 基础架构核心底座，涵盖单向数据流 MVVM 架构、网络防御客户端、0 敏感权限安全沙盒文件管理、流式防 OOM 聚合备份、合规评分引导、响应式布局及通用扩展。

## 🏷️ 最新版本 Tag

`arch@1.1.0`

## 📦 接入方式 (Installation)

```yaml
dependencies:
  core_arch:
    git:
      url: git@github.com:janzun/flutter_foundation.git
      path: packages/core_arch
      ref: arch@1.1.0
```

## ⚙️ 必要配置 (Configuration)

纯 Dart 与应用沙盒内部读写，**零敏感系统权限**。

---

## 📚 完整 API 列表 (API Reference)

### 1. MVVM 与架构核心

```dart
/// 单向数据流 (UDF) 状态基类与瞬时事件基类
abstract class BaseUiState { const BaseUiState(); }
abstract class BaseUiEvent { const BaseUiEvent(); }

/// 视图模型基类 (内部自动托管事件订阅生命周期，防内存泄漏)
abstract class BaseViewModel<S extends BaseUiState, E extends BaseUiEvent> extends ChangeNotifier {
  BaseViewModel(S initialState);
  S get uiState;
  void listenEvent(void Function(E event) onEvent);
  void updateUiState(S Function(S state) transform); // 原子函数式更新并通知 UI
  void sendUiEvent(E event);                         // 下发单次副作用事件 (Toast/跳转)
}

/// 工业级无异常逃逸结果对象
class Result<T> {
  const Result.ok(T value);
  const Result.err(AppException error);
  bool get isOk;
  bool get isErr;
  T? get valueOrNull;
  AppException? get errorOrNull;
  R fold<R>(R Function(T value) onOk, R Function(AppException error) onErr);
}

/// 统一业务与网络异常包装
class AppException implements Exception {
  final String code;
  final String message;
  final int? statusCode;
  final Object? originalError;
}

/// 标准视图状态枚举
enum ViewState { idle, loading, empty, error, success }
```

### 2. 存储与多资产聚合备份

```dart
/// 安全沙盒文件管理 (全量支持流式 Zip，防 OOM 峰值)
class FileUtil {
  static Future<Directory> createDirIfNotExists(String dirPath);
  static Future<Directory> getDocSubDir(String subDirName);
  static Future<Directory> getCacheSubDir(String subDirName);
  static Future<File> writeBytes(String filePath, Uint8List bytes, {bool atomic = true});
  static Future<File> writeString(String filePath, String content, {bool atomic = true});
  static Future<File> copyFile(String sourcePath, String targetPath);
  static Future<String?> readString(String filePath);
  static Future<Uint8List?> readBytes(String filePath);
  static bool exists(String path);
  static Future<bool> deleteFile(String filePath);
  static Future<bool> deleteDir(String dirPath, {bool recursive = true});
  static int getFileSize(String filePath);
  static Future<int> getDirSizeBytes(Directory dir);
  static Future<String> getAppCacheSizeString();
  static Future<bool> clearAppCache();

  /// 磁盘流式打 Zip 包 (支持多目录与相对路径映射)
  static Future<File> zipFiles({required List<File> files, required String targetZipPath, Map<String, String>? pathInZipMap});
  static Future<File> zipDirectory({required Directory sourceDir, required String targetZipPath});
  static Future<Directory> unzipFile({required File zipFile, required String targetDirPath});
}

/// 全局多资产复合备份工具 (.bak 打包与提取)
class BackupUtil {
  /// 创建聚合备份 (汇集 manifest.json, 数据库快照, 命名空间隔离的多附件目录, KV 配置字典)
  static Future<Result<File>> createBackup({
    required String targetBackupFilePath,
    File? databaseFile,
    List<Directory>? attachmentDirs,
    Map<String, dynamic>? kvData,
    int schemaVersion = 1,
    String? appVersion,
    Map<String, dynamic>? extraMeta,
  });

  /// 解压并提取备份资产 (内置清单校验与版本兼容性检查)
  static Future<Result<BackupExtractedData>> extractBackup({
    required File backupFile,
    required String targetExtractDir,
    int? expectedMaxSchemaVersion,
  });
}

/// 轻量级键值存储工具 (支持全量导出/导入闭环)
class SpUtil {
  static Future<void> init();
  static String getString(String key, {String defaultValue = ''});
  static bool getBool(String key, {bool defaultValue = false});
  static int getInt(String key, {int defaultValue = 0});
  static double getDouble(String key, {double defaultValue = 0.0});
  static List<String> getStringList(String key, {List<String> defaultValue = const []});
  static bool containsKey(String key);
  static Future<bool> setString(String key, String value);
  static Future<bool> setBool(String key, bool value);
  static Future<bool> setInt(String key, int value);
  static Future<bool> setDouble(String key, double value);
  static Future<bool> setStringList(String key, List<String> value);
  static Future<bool> remove(String key);
  static Future<bool> clear();

  /// 导出全部配置 (直接对接 BackupUtil.createBackup kvData)
  static Map<String, dynamic> exportAll({Set<String>? excludeKeys});

  /// 从字典一键导入恢复配置 (自动处理 JSON List<dynamic> 类型擦除)
  static Future<bool> importAll(Map<String, dynamic> data, {bool clearBefore = false});
}

/// 沙盒目录定位工具
class PathUtil {
  static Future<Directory> get appDocumentsDirectory;
  static Future<Directory> get appCacheDirectory;
  static Future<Directory> get temporaryDirectory;
  static Future<Directory> get appSupportDirectory;
}
```

### 3. 网络与传输

```dart
/// 工业级 Dio 客户端 (内置 401 节流防重入锁与标准异常转换)
class DioClient {
  factory DioClient({
    required String baseUrl,
    Duration connectTimeout,
    Duration receiveTimeout,
    Duration sendTimeout,
    FutureOr<String?> Function()? tokenProvider,
    Map<String, dynamic> Function()? headerProvider,
    void Function()? onUnauthorized,
    List<Interceptor>? interceptors,
  });

  /// 异步请求卫士 (自动捕获 Dio/业务异常并转换为 Result<T>)
  static Future<Result<T>> guard<T>(Future<T> Function() request);

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken});
  Future<Response<T>> post<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken});
  Future<Response<T>> put<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken});
  Future<Response<T>> delete<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken});
}

/// 大文件分块下载工具
class FileDownloader {
  static Future<Result<File>> downloadFile({
    required String urlPath,
    required String savePath,
    void Function(int received, int total)? onReceiveProgress,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    Duration timeout,
  });
}

/// S3 / Cloudflare R2 预签名直传工具
class R2Uploader {
  static Future<Result<void>> uploadBytes({
    required String presignedPutUrl,
    required Uint8List bytes,
    required String contentType,
    void Function(int sent, int total)? onSendProgress,
    Duration timeout,
  });
}
```

### 4. UI 辅助与事件驱动

```dart
/// 全局 Toast 与精准 Loading (精准 context 销毁，杜绝误关业务页面)
class ToastUtil {
  static final GlobalKey<ScaffoldMessengerState> messengerKey;
  static final GlobalKey<NavigatorState> navigatorKey;
  static void show(String message, {bool isError = false, Duration duration});
  static void success(String message);
  static void error(String message);
  static void showLoading({String message = '加载中...'});
  static void hideLoading();
}

/// 类型安全全局事件总线 (支持销毁后自动重建)
class EventBus {
  static void emit<T>(T event);
  static Stream<T> on<T>();
  static Future<void> destroy();
}
```

### 5. 应用评分引导 (`RateAppUtil`)

合规设计：无情绪分流（Google Play / Apple 禁止按态度筛选评分），门槛达标后直接唤起系统原生评分。依赖 `SpUtil.init()`。

```dart
class RateAppUtil {
  /// 业务高光点调用：计数 +1，满足 [事件次数/首次记录天数/冷却期/当前版本未唤起] 后唤起系统评分；返回是否发起请求
  static Future<bool> trigger({required String eventKey, int minEvents = 3, int minDays = 2, int coolDownDays = 60});

  /// 设置页主动评分：无门槛，系统评分不可用时跳转商店（iOS 需 appStoreId）
  static Future<void> requestReview({String? appStoreId});
}
```
