import 'dart:ui';

/// 单个人脸检测结果（坐标已对齐为正向竖屏坐标系）
class DetectedFace {
  /// 正向竖屏画面中的像素边界框
  final Rect boundingBox;

  /// 归一化边界框 (0.0 ~ 1.0，相对于正向竖屏宽高)
  final Rect normalizedBox;

  /// 俯仰角 Pitch (抬头/低头，单位：度)
  final double headEulerAngleX;

  /// 偏航角 Yaw (左右转头，单位：度)
  final double headEulerAngleY;

  /// 翻滚角 Roll (左右歪头，单位：度)
  final double headEulerAngleZ;

  /// 左眼睁开置信度 (0.0 ~ 1.0)
  final double? leftEyeOpenProbability;

  /// 右眼睁开置信度 (0.0 ~ 1.0)
  final double? rightEyeOpenProbability;

  /// 微笑置信度 (0.0 ~ 1.0)
  final double? smilingProbability;

  /// 追踪 ID
  final int? trackingId;

  /// 精准眼睛视平线物理 Y 坐标（像素），如果硬件未检测到则为空
  final double? eyeY;

  /// 精准下巴尖端 (Chin Tip) 物理 Y 坐标（像素），如果硬件未检测到则为空
  final double? chinY;

  /// 左眼中心物理坐标（像素）
  final double? leftEyeX;
  final double? leftEyeY;

  /// 右眼中心物理坐标（像素）
  final double? rightEyeX;
  final double? rightEyeY;

  const DetectedFace({
    required this.boundingBox,
    required this.normalizedBox,
    required this.headEulerAngleX,
    required this.headEulerAngleY,
    required this.headEulerAngleZ,
    this.leftEyeOpenProbability,
    this.rightEyeOpenProbability,
    this.smilingProbability,
    this.trackingId,
    this.eyeY,
    this.chinY,
    this.leftEyeX,
    this.leftEyeY,
    this.rightEyeX,
    this.rightEyeY,
  });

  factory DetectedFace.fromMap(Map<dynamic, dynamic> map, double frameWidth, double frameHeight) {
    final double left = (map['left'] as num?)?.toDouble() ?? 0.0;
    final double top = (map['top'] as num?)?.toDouble() ?? 0.0;
    final double right = (map['right'] as num?)?.toDouble() ?? 0.0;
    final double bottom = (map['bottom'] as num?)?.toDouble() ?? 0.0;
    final rect = Rect.fromLTRB(left, top, right, bottom);

    final normRect = (frameWidth > 0 && frameHeight > 0)
        ? Rect.fromLTWH(
            (left / frameWidth).clamp(0.0, 1.0),
            (top / frameHeight).clamp(0.0, 1.0),
            (rect.width / frameWidth).clamp(0.0, 1.0),
            (rect.height / frameHeight).clamp(0.0, 1.0),
          )
        : Rect.zero;

    return DetectedFace(
      boundingBox: rect,
      normalizedBox: normRect,
      headEulerAngleX: (map['headEulerAngleX'] as num?)?.toDouble() ?? 0.0,
      headEulerAngleY: (map['headEulerAngleY'] as num?)?.toDouble() ?? 0.0,
      headEulerAngleZ: (map['headEulerAngleZ'] as num?)?.toDouble() ?? 0.0,
      leftEyeOpenProbability: (map['leftEyeOpenProbability'] as num?)?.toDouble(),
      rightEyeOpenProbability: (map['rightEyeOpenProbability'] as num?)?.toDouble(),
      smilingProbability: (map['smilingProbability'] as num?)?.toDouble(),
      trackingId: (map['trackingId'] as num?)?.toInt(),
      eyeY: (map['eyeY'] as num?)?.toDouble(),
      chinY: (map['chinY'] as num?)?.toDouble(),
      leftEyeX: (map['leftEyeX'] as num?)?.toDouble(),
      leftEyeY: (map['leftEyeY'] as num?)?.toDouble(),
      rightEyeX: (map['rightEyeX'] as num?)?.toDouble(),
      rightEyeY: (map['rightEyeY'] as num?)?.toDouble(),
    );
  }
}

/// 原生零拷贝分析帧事件
class FaceAnalysisEvent {
  /// 当前帧是否检测到人脸
  final bool hasFace;

  /// 检测到的人脸列表（已按面积从大到小排序）
  final List<DetectedFace> faces;

  /// 正向竖屏画面的有效宽度（像素）
  final double frameWidth;

  /// 正向竖屏画面的有效高度（像素）
  final double frameHeight;

  /// 环境光线是否过暗
  final bool isAmbientDark;

  /// 环境平均亮度值 (0.0 ~ 255.0)
  final double ambientLuminance;

  const FaceAnalysisEvent({
    required this.hasFace,
    required this.faces,
    required this.frameWidth,
    required this.frameHeight,
    required this.isAmbientDark,
    this.ambientLuminance = 128.0,
  });

  /// 获取面积最大的主画面人脸
  DetectedFace? get primaryFace => faces.isNotEmpty ? faces.first : null;

  factory FaceAnalysisEvent.fromMap(Map<dynamic, dynamic> map) {
    final double frameWidth = (map['frameWidth'] as num?)?.toDouble() ?? 480.0;
    final double frameHeight = (map['frameHeight'] as num?)?.toDouble() ?? 640.0;
    final bool isAmbientDark = map['isAmbientDark'] as bool? ?? false;
    final double ambientLuminance = (map['ambientLuminance'] as num?)?.toDouble() ?? 128.0;

    final rawFaces = map['faces'] as List<dynamic>? ?? const [];
    final List<DetectedFace> parsedFaces = rawFaces
        .whereType<Map<dynamic, dynamic>>()
        .map((f) => DetectedFace.fromMap(f, frameWidth, frameHeight))
        .toList();

    // 按人脸面积从大到小排序
    parsedFaces.sort((a, b) =>
        (b.boundingBox.width * b.boundingBox.height)
            .compareTo(a.boundingBox.width * a.boundingBox.height));

    return FaceAnalysisEvent(
      hasFace: parsedFaces.isNotEmpty,
      faces: parsedFaces,
      frameWidth: frameWidth,
      frameHeight: frameHeight,
      isAmbientDark: isAmbientDark,
      ambientLuminance: ambientLuminance,
    );
  }
}
