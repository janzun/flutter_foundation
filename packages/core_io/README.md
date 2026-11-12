# core_io

跨平台文件与媒体 I/O 桥接底座，抹平 Mobile (iOS/Android)、Desktop、Web 输入（选取）与输出（保存导出）差异。

## 🏷️ 最新版本 Tag

`core_io-v1.0.0`

## 📦 接入方式 (Installation)

```yaml
dependencies:
  core_io:
    git:
      url: https://github.com/janzun/flutter_foundation.git
      path: packages/core_io
      ref: core_io-v1.0.0
```

## ⚙️ 必要配置 (Configuration)

### iOS (`ios/Runner/Info.plist`)
按需声明（若不使用相机拍摄或不存入系统相册可不填）：
```xml
<!-- 仅当使用 pickImageByCamera / pickVideoByCamera 时需要 -->
<key>NSCameraUsageDescription</key>
<string>需要使用相机进行拍摄</string>
<!-- 仅当使用 pickVideoByCamera 录制视频声音时需要 -->
<key>NSMicrophoneUsageDescription</key>
<string>需要使用麦克风录制视频声音</string>
<!-- 仅当保存图片/视频到系统相册时需要 (仅添加权限) -->
<key>NSPhotoLibraryAddUsageDescription</key>
<string>需要将图片/视频保存到您的系统相册</string>
```

### Android (`android/app/src/main/AndroidManifest.xml`)
- **Android 10+ (API 29+)**: 存相册 (MediaStore) 与文件另存为 (SAF) **100% 零权限**，无需任何声明。
- **Android 9 及以下 (API <= 28)** (可选兼容):
```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28" />
```

---

## 📚 完整 API 列表 (API Reference)

### 1. 结果模型与文件实体

```dart
/// 三态结果对象
enum IOStatus { success, cancelled, failure }
enum IOErrorType { none, permissionDenied, fileNotFound, unsupported, unknown }

class IOResult<T> {
  final IOStatus status;
  final T? data;
  final String? errorMessage;
  final IOErrorType errorType;
  final Object? rawError;

  bool get isSuccess => status == IOStatus.success;
  bool get isCancelled => status == IOStatus.cancelled;
  bool get isFailure => status == IOStatus.failure;
  bool get isPermissionDenied => errorType == IOErrorType.permissionDenied;
}

/// 跨平台统一文件实体
class PickedFile {
  final String name;          // 文件名 (含扩展名)
  final int size;             // 字节大小
  final String extension;     // 小写无点扩展名
  final String? path;         // 本地物理路径 (Web 为 null)
  final String? mimeType;     // MIME 类型
  bool get isWeb;             // 是否运行在 Web 平台
  String get readableSize;    // 人类可读大小 (如 "2.4 MB")

  /// 读取全量字节 (Web 返回内存字节，Native 惰性读磁盘)
  Future<Uint8List> readBytes();

  /// 流式分块读取 (适合大视频/大音频，防 OOM)
  Stream<Uint8List> openRead([int? start, int? end]);

  /// 拷贝至沙盒指定路径 (返回沙盒绝对路径)
  Future<String> copyToPath(String targetFilePath);
}
```

### 2. 系统选取门面 (`PickUtil`)

```dart
class PickUtil {
  /// 从相册选取单张图片 (iOS/Android/Web 硬件缩放预处理，Desktop 返原图)
  static Future<IOResult<PickedFile>> pickImage({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  });

  /// 从相册选取多张图片
  static Future<IOResult<List<PickedFile>>> pickMultipleImages({
    int? limit,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  });

  /// 从相册选取单个视频
  static Future<IOResult<PickedFile>> pickVideo();

  /// 从相册选取多个视频
  static Future<IOResult<List<PickedFile>>> pickMultipleVideos({int? limit});

  /// 调用系统相机拍照
  static Future<IOResult<PickedFile>> pickImageByCamera({
    bool preferFrontCamera = false,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  });

  /// 调用系统相机录制视频
  static Future<IOResult<PickedFile>> pickVideoByCamera({
    bool preferFrontCamera = false,
    Duration? maxDuration,
  });

  /// 选取单个音频文件
  static Future<IOResult<PickedFile>> pickAudio({List<String>? allowedExtensions});

  /// 选取多个音频文件
  static Future<IOResult<List<PickedFile>>> pickMultipleAudios({List<String>? allowedExtensions});

  /// 选取单个通用文件 (如 .pdf, .xlsx, .bak)
  static Future<IOResult<PickedFile>> pickFile({List<String>? allowedExtensions});

  /// 选取多个通用文件
  static Future<IOResult<List<PickedFile>>> pickMultipleFiles({List<String>? allowedExtensions});

  /// 选取本地目录路径 (仅 Desktop / Android 支持，Web/iOS 返 cancelled)
  static Future<IOResult<String>> pickDirectory();
}
```

### 3. 系统保存门面 (`SaveUtil`)

```dart
class SaveUtil {
  /// 将内存图片字节存入相册 (移动端进相册，桌面进 Pictures，Web 触发下载)
  static Future<IOResult<void>> saveImageBytesToGallery({
    required Uint8List bytes,
    String? name,
    String? albumName,
  });

  /// 将本地图片文件存入相册
  static Future<IOResult<void>> saveImageFileToGallery({
    required String filePath,
    String? albumName,
  });

  /// 将本地视频文件存入相册
  static Future<IOResult<void>> saveVideoFileToGallery({
    required String filePath,
    String? albumName,
  });

  /// 内存字节另存为外部文件 (桌面弹窗，移动端呼起存储面板，Web 触发下载)
  static Future<IOResult<String>> saveBytesAsFile({
    required Uint8List bytes,
    required String fileName,
  });

  /// 沙盒文件另存为外部文件 (默认提取源文件名)
  static Future<IOResult<String>> saveFile({
    required String sourceFilePath,
    String? fileName,
  });
}
```
