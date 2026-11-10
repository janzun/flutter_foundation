export 'package:cross_file/cross_file.dart' show XFile;

/// 摄像头朝向
enum CameraLensDirection {
  front,
  back,
  external;

  static CameraLensDirection fromString(String? value) {
    switch (value) {
      case 'front':
        return CameraLensDirection.front;
      case 'back':
        return CameraLensDirection.back;
      default:
        return CameraLensDirection.external;
    }
  }
}

/// 闪光灯模式
enum FlashMode {
  off,
  auto,
  always,
  torch,
}

/// 对焦模式
enum FocusMode {
  auto,
  locked,
}

/// 曝光模式
enum ExposureMode {
  auto,
  locked,
}

/// 分辨率预设
enum ResolutionPreset {
  low,
  medium,
  high,
  veryHigh,
  ultraHigh,
  max,
}

/// 传感器画幅比例预设
enum CameraAspectRatio {
  /// 4:3 画幅（竖屏 3:4），匹配手机 CMOS 传感器原生物理比例，100% 像素利用率
  ratio4_3,

  /// 16:9 宽屏画幅（竖屏 9:16）
  ratio16_9,
}

/// 原生零拷贝视觉分析器模式（可插拔扩展）
enum AnalyzerMode {
  /// 纯净拍摄模式（不绑定 ImageAnalysis 通道，0 额外算力开销）
  none,

  /// 原生零拷贝人脸检测模式（ML Kit 硬件指针直读 + 环境暗光采样 + 智能人脸追焦）
  faceDetection,
}

/// 物理摄像头硬件描述信息
class CameraDescription {
  /// 摄像头系统唯一标识（如 "0", "1"）
  final String name;

  /// 镜头朝向（前置 / 后置 / 外接）
  final CameraLensDirection lensDirection;

  /// 传感器物理安装旋转角度（0, 90, 180, 270）
  final int sensorOrientation;

  const CameraDescription({
    required this.name,
    required this.lensDirection,
    required this.sensorOrientation,
  });

  factory CameraDescription.fromMap(Map<dynamic, dynamic> map) {
    return CameraDescription(
      name: map['name']?.toString() ?? '0',
      lensDirection: CameraLensDirection.fromString(map['lensDirection']?.toString()),
      sensorOrientation: (map['sensorOrientation'] as num?)?.toInt() ?? 90,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CameraDescription &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          lensDirection == other.lensDirection &&
          sensorOrientation == other.sensorOrientation;

  @override
  int get hashCode => Object.hash(name, lensDirection, sensorOrientation);

  @override
  String toString() =>
      'CameraDescription(name: $name, lensDirection: $lensDirection, sensorOrientation: $sensorOrientation)';
}

/// 相机异常封装
class CameraException implements Exception {
  final String code;
  final String? description;

  const CameraException(this.code, [this.description]);

  @override
  String toString() => 'CameraException($code, $description)';
}
