# core_io

Universal file and media I/O bridge for Flutter across **Mobile (iOS/Android)**, **Desktop (macOS/Windows/Linux)**, and **Web**.

---

## 🌟 设计定位与核心价值

1. **绝对零耦合与防腐层 (Anti-Corruption Layer)**:
   - 彻底独立，不依赖 `core_arch`，自闭环轻量 `IOResult<T>`。
   - 抹平底层插件和多端系统 API 差异，避免业务层各处直接调用三方插件引发平台分歧与破坏性变更。
2. **职责分明治理**:
   - **视觉媒体 (图片/视频)**：底层由 `image_picker` 驱动。移动端优先呼起现代原生相册，支持相机前后置独立拍摄，支持平台级硬件加速预处理缩放。
   - **音频与通用文件**：底层由 `file_picker` 驱动，调起系统文件管理器与另存为面板。
3. **彻底抹平 Web 端与 Native 端的物理差异**:
   - `PickedFile` 彻底屏蔽 Web 端 `path == null` 的空安全陷阱。
   - 兼顾小文件快速读取（`readBytes()`）与大视频/大音频分块流式读取（`openRead([start, end])` 防内存 OOM）。
4. **贴合真实业务的三态结果设计**:
   - 明确区分 **成功 (`isSuccess`)**、**用户主动取消 (`isCancelled`)** 与 **真实异常 (`isFailure`)**。用户手滑点取消时不抛出伪异常，避免业务层弹出愚蠢的失败 Toast。
   - 细分权限拒绝（`isPermissionDenied`），方便业务精准引导开启权限。

---

## 📦 架构目录

```
packages/core_io/
├── lib/
│   ├── core_io.dart              # 统一导出入口
│   ├── models/
│   │   ├── io_result.dart        # 三态结果对象 (success / cancelled / failure)
│   │   └── picked_file.dart      # 跨端统一文件实体 (name, size, bytes, openRead, copyToPath)
│   ├── pick_util.dart            # 系统选取门面 (相册选图/选视频/相机拍照/录像/选音频/选文件/选目录)
│   └── save_util.dart            # 系统保存门面 (存相册/另存为导出/Web下载)
├── test/
│   └── core_io_test.dart         # 单元测试
└── pubspec.yaml
```

---

## 🚀 快速上手 (Quick Start)

### 1. 媒体选取与相机拍摄 (`PickUtil`)

#### 从相册选图（支持硬件加速等比缩放预处理）
> 注：`maxWidth`/`maxHeight`/`imageQuality` 在 iOS、Android 和 Web 端通过底层硬件加速自动缩放；桌面端（macOS/Win/Linux）直接返回原图。

```dart
// 选单张图片
final result = await PickUtil.pickImage(
  maxWidth: 1920,
  maxHeight: 1080,
  imageQuality: 85,
);

if (result.isSuccess) {
  final PickedFile file = result.data!;
  print('文件名: ${file.name}, 大小: ${file.readableSize}');
  
  // 复制到沙盒保存
  await file.copyToPath('/path/to/sandbox/avatar.png');
} else if (result.isCancelled) {
  // 用户主动取消，静默忽略
} else if (result.isPermissionDenied) {
  // 提示用户去系统设置开启权限
}
```

#### 调用系统相机拍照/录视频
```dart
// 拍照（优先前置摄像头）
final photoResult = await PickUtil.pickImageByCamera(
  preferFrontCamera: true,
  maxWidth: 1280,
);

// 录视频
final videoResult = await PickUtil.pickVideoByCamera(
  maxDuration: const Duration(seconds: 60),
);
```

#### 选取音频与通用文档（如 .pdf, .xlsx, .bak 备份文件）
```dart
// 选音频
final audioResult = await PickUtil.pickAudio(allowedExtensions: ['mp3', 'm4a']);

// 选备份包
final backupResult = await PickUtil.pickFile(allowedExtensions: ['bak']);
if (backupResult.isSuccess) {
  final file = backupResult.data!;
  // 大文件流式读取分块（防 OOM）
  final Stream<Uint8List> stream = file.openRead();
}
```

---

### 2. 保存与导出文件 (`SaveUtil`)

#### 保存海报/图片/视频到系统相册
- 移动端（iOS / Android）：写入系统相册（Android 10+ 零权限，iOS 仅需 `NSPhotoLibraryAddUsageDescription`）。
- 桌面端：自动落入操作系统的 Pictures/Videos 目录。
- Web 端：自动触发下载图片/视频。

```dart
// 1. 将内存生成的二维码/海报直接存入相册
await SaveUtil.saveImageBytesToGallery(
  bytes: pngBytes,
  name: 'my_poster',
  albumName: 'MyApp', // 可选子相簿
);

// 2. 将已有沙盒文件存入相册
await SaveUtil.saveVideoFileToGallery(
  filePath: '/sandbox/cache/exported_video.mp4',
);
```

#### 导出文件（另存为 / 存储到文件面板）
- 移动端：呼起系统的 SAF / “存储到文件” 原生面板，由用户自选保存路径，**零系统存储权限**。
- 桌面端：弹出系统原生“另存为”保存对话框。
- Web 端：自动触发浏览器下载该文件。

```dart
// 1. 导出沙盒内的备份文件或报表
final saveResult = await SaveUtil.saveFile(
  sourceFilePath: '/sandbox/cache/my_backup.bak',
  fileName: 'MyApp_Backup_2026.bak', // 可选，默认取源文件名
);

if (saveResult.isSuccess) {
  print('已导出至: ${saveResult.data}');
}
```

---

## 🔒 平台权限说明

`core_io` 作为基础库本身不强制打包敏感权限，各端配置指南如下：

### iOS (`ios/Runner/Info.plist`)
按需声明对应的描述文案（若不用相机或相册可不填）：
```xml
<!-- 仅当使用 pickImageByCamera / pickVideoByCamera 时需要 -->
<key>NSCameraUsageDescription</key>
<string>我们需要使用您的相机进行拍照或扫描</string>

<!-- 仅当使用 pickVideoByCamera 录制视频声音时需要 -->
<key>NSMicrophoneUsageDescription</key>
<string>我们需要使用麦克风录制视频声音</string>

<!-- 仅当调用 SaveUtil 存入系统相册时需要 (仅写入权限，不需要读取权限) -->
<key>NSPhotoLibraryAddUsageDescription</key>
<string>我们需要将生成的图片/视频保存到您的系统相册</string>
```

### Android (`android/app/src/main/AndroidManifest.xml`)
- **Android 10+ (API 29+)**：相册写入（MediaStore）和文件另存为（SAF）**100% 零权限**！
- 若需兼容 Android 9 及以下老旧机型向相册存图，可加上（可选）：
```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28" />
```
