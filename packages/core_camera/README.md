# core_camera

高性能原生相机插件，专为视觉 AI 和极致抓拍体验打造。支持 **Zero-Shutter-Lag (ZSL) 极速零快门延迟秒拍**、原生 4:3 传感器比例对齐、原子级硬件 AF/AE，并内置零拷贝的原生视觉与人脸检测分析管道（Android ML Kit / iOS Vision）。

---

## 模块定位

- **角色**：高性能底层相机与视觉分析底座。
- **平台支持**：Android (Camera2 + ML Kit), iOS (AVFoundation + Vision Framework)。
- **核心特性**：
  - **ZSL 极速秒拍**：不重新触发拍前重新对焦对流，直接提取已对焦最高清帧，拍照零延迟。
  - **原子硬件 AF/AE**：支持单点同时联动测光与对焦。
  - **原生人脸/视觉流**：原生后台实时处理人脸坐标，通过事件流分发，不阻塞 Flutter UI。
  - **离线图片检测**：支持对本地文件路径或内存字节数组进行快速人脸检测与大小排序。

---

## 依赖配置

在宿主 App 的 `pubspec.yaml` 中引入：

```yaml
dependencies:
  core_camera:
    path: packages/core_camera
```

---

## 快速使用

### 1. 初始化相机与预览

```dart
import 'package:core_camera/core_camera.dart';
import 'package:flutter/material.dart';

// 1. 获取设备可用摄像头
final cameras = await availableCameras();
final frontCamera = cameras.firstWhere(
  (c) => c.lensFacing == CameraLensFacing.front,
  orElse: () => cameras.first,
);

// 2. 创建并初始化 Controller
final controller = CameraController(
  frontCamera,
  ResolutionPreset.high,
  enableAudio: false,
  analyzerMode: AnalyzerMode.faceDetection, // 开启原生人脸分析
);

await controller.initialize();

// 3. 在 Widget 中渲染预览组件
Widget buildPreview() {
  return CoreCameraPreview(controller: controller);
}
```

### 2. 监听实时人脸检测事件

```dart
controller.faceAnalysisStream.listen((FaceAnalysisEvent event) {
  if (event.faces.isNotEmpty) {
    final primaryFace = event.primaryFace; // 已按面积排序，首位为最大人脸
    print('检测到人脸: 边界框=${primaryFace?.boundingBox}, 俯仰角=${primaryFace?.headEulerAngleX}');
  }
});
```

### 3. 极速拍照

```dart
// ZSL 极速秒拍，返回 XFile 文件引用
final XFile file = await controller.takePicture();
print('照片已保存到: ${file.path}');
```

### 4. 离线图片人脸检测 (静态文件/字节)

```dart
// 离线检测本地相册或文件中的人脸
final List<DetectedFace> faces = await CoreCamera.detectFacesFromFile('/path/to/image.jpg');

// 或直接从内存数据中检测
final List<DetectedFace> memFaces = await CoreCamera.detectFacesFromBytes(uint8Bytes);
```

---

## 核心 API

### `CoreCamera` (静态类)
- `CoreCamera.availableCameras()`: 获取当前可用物理摄像头列表。
- `CoreCamera.detectFacesFromFile(String filePath)`: 离线分析本地文件中的人脸并排序。
- `CoreCamera.detectFacesFromBytes(Uint8List bytes)`: 离线分析内存二进制图片中的人脸。

### `CameraController`
- `initialize()`: 初始化原生相机管线与纹理绑定。
- `takePicture()`: 零延迟 ZSL 原生拍照，返回 `XFile`。
- `setFocusAndExposurePoint(Offset point)`: 原子级硬件 AF+AE 测光对焦（归一化坐标 `[0.0, 1.0]`）。
- `setFlashMode(FlashMode mode)`: 设置闪光灯模式（`off`, `auto`, `always`, `torch`）。
- `setZoomLevel(double zoom)`: 调整焦距。
- `faceAnalysisStream`: 人脸实时流通知。
- `pauseAnalysis()` / `resumeAnalysis()`: 动态暂停/恢复视觉分析。
- `dispose()`: 释放相机与原生句柄。

### `CoreCameraPreview`
- 自适应 4:3 比例或全屏铺满的原生纹理预览组件，内部已处理平台级旋转与镜像。
