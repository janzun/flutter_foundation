# core_camera

## 1. 介绍
高性能原生相机插件，专为视觉 AI 和极致抓拍体验打造。支持硬件级 **Zero-Shutter-Lag (ZSL) 零快门延迟秒拍**、原生 4:3 传感器满画幅对齐、原子级硬件 AF/AE 联动测光对焦，并内置零拷贝的原生视觉与人脸实时分析管道（Android ML Kit / iOS Vision），后台异步处理不阻塞 UI 渲染，同时支持离线图片/内存数据的人脸静态检测。

## 2. 最新版本 Tag
`camera@1.0.0`

## 3. 接入方式
在项目 `pubspec.yaml` 中通过 Git 形式引入：
```yaml
dependencies:
  core_camera:
    git:
      url: git@github.com:janzun/flutter_foundation.git
      path: packages/core_camera
      ref: camera@1.0.0
```

## 4. 必要配置

### 4.1 iOS 配置 (`ios/Runner/Info.plist`)
需要添加相机使用权限描述：
```xml
<key>NSCameraUsageDescription</key>
<string>需要访问您的相机以进行拍摄与视觉识别</string>
```

### 4.2 Android 配置 (`android/app/src/main/AndroidManifest.xml`)
声明相机硬件与特性权限：
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" />
<uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />
```

## 5. 完整 API 列表

### 5.1 顶层入口类 `CoreCamera` & 顶层函数
```dart
/// 硬件探测与静态图像人脸检测
abstract final class CoreCamera {
  /// 查询当前设备所有物理摄像头
  static Future<List<CameraDescription>> availableCameras();

  /// 本地文件静态人脸检测（自动按面积从大到小排序）
  static Future<List<DetectedFace>> detectFacesFromFile(String filePath);

  /// 内存图片字节数据静态人脸检测
  static Future<List<DetectedFace>> detectFacesFromBytes(Uint8List bytes);
}

/// 兼容官方接口风格的顶层函数
Future<List<CameraDescription>> availableCameras();
```

### 5.2 相机控制器 `CameraController`
```dart
class CameraController extends ValueNotifier<CameraValue> {
  final CameraDescription description;
  final ResolutionPreset resolutionPreset;
  final CameraAspectRatio aspectRatio;
  final bool enableAudio;
  final AnalyzerMode analyzerMode;
  final bool enableFaceAutoFocus;

  CameraController(
    CameraDescription description, [
    ResolutionPreset resolutionPreset = ResolutionPreset.max,
  ]);

  CameraController.custom(
    CameraDescription description, {
    ResolutionPreset resolutionPreset = ResolutionPreset.max,
    CameraAspectRatio aspectRatio = CameraAspectRatio.ratio4_3,
    bool enableAudio = false,
    AnalyzerMode analyzerMode = AnalyzerMode.faceDetection,
    bool enableFaceAutoFocus = true,
  });

  int get textureId;
  Stream<FaceAnalysisEvent> get faceAnalysisStream;

  Future<void> initialize();
  Future<void> pauseAnalysis();
  Future<void> resumeAnalysis();
  Future<void> setAnalyzerMode(AnalyzerMode mode);
  Future<XFile> takePicture();
  Future<void> setFocusAndExposurePoint(Offset point);
  Future<void> setFocusPoint(Offset? point);
  Future<void> setExposurePoint(Offset? point);
  Future<void> setFlashMode(FlashMode mode);
  Future<void> setFocusMode(FocusMode mode);
  Future<void> setExposureMode(ExposureMode mode);
  Future<void> setZoomLevel(double zoom);
  @override
  Future<void> dispose();
}
```

### 5.3 纹理预览组件 `CameraPreview`
```dart
class CameraPreview extends StatelessWidget {
  final CameraController controller;
  final Widget? child;

  const CameraPreview(
    this.controller, {
    super.key,
    this.child,
  });

  @override
  Widget build(BuildContext context);
}
```

### 5.4 状态快照 `CameraValue`
```dart
class CameraValue {
  final bool isInitialized;
  final bool isTakingPicture;
  final Size? previewSize;
  final FlashMode flashMode;
  final FocusMode focusMode;
  final ExposureMode exposureMode;
  final DeviceOrientation deviceOrientation;
  final CameraDescription description;
  final int textureId;
  final bool handlesCropAndRotation;
  final String? errorDescription;

  double get aspectRatio;
  double get portraitAspectRatio;

  CameraValue copyWith({...});
}
```

### 5.5 类型与枚举
```dart
enum CameraLensDirection { front, back, external }
enum FlashMode { off, auto, always, torch }
enum FocusMode { auto, locked }
enum ExposureMode { auto, locked }
enum ResolutionPreset { low, medium, high, veryHigh, ultraHigh, max }
enum CameraAspectRatio { ratio4_3, ratio16_9 }
enum AnalyzerMode { none, faceDetection }

class CameraDescription {
  final String name;
  final CameraLensDirection lensDirection;
  final int sensorOrientation;
}

class CameraException implements Exception {
  final String code;
  final String? description;
}
```

### 5.6 视觉与人脸事件模型
```dart
class FaceAnalysisEvent {
  final List<DetectedFace> faces;
  final double? ambientLightLux;
  final int sensorWidth;
  final int sensorHeight;
  final int orientation;
  final int timestampMs;

  DetectedFace? get primaryFace;
}

class DetectedFace {
  final Rect boundingBox;
  final Rect normalizedBox;
  final double headEulerAngleX;
  final double headEulerAngleY;
  final double headEulerAngleZ;
  final double? leftEyeOpenProbability;
  final double? rightEyeOpenProbability;
  final double? smilingProbability;
  final int? trackingId;
  final double? eyeY;
  final double? chinY;
  final double? leftEyeX;
  final double? leftEyeY;
  final double? rightEyeX;
  final double? rightEyeY;
}
```
