import 'dart:io';
import 'package:flutter/material.dart';
import 'camera_controller.dart';
import 'model/camera_types.dart';

/// 原生高性能相机纹理预览组件
///
/// 自动适配：
/// - Android SurfaceTexture 与 Impeller ImageReader 两种渲染后端的旋转与前置镜像补偿
/// - iOS AVFoundation 纹理预览
/// - 竖屏原生画幅比例（如 3:4 满画幅对齐）
class CameraPreview extends StatelessWidget {
  final CameraController controller;
  final Widget? child;

  const CameraPreview(
    this.controller, {
    super.key,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CameraValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        if (!value.isInitialized || value.textureId < 0) {
          return const SizedBox.shrink();
        }

        return AspectRatio(
          aspectRatio: value.portraitAspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildOrientedTexture(value),
              if (child != null) child!,
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrientedTexture(CameraValue value) {
    Widget texture = Texture(textureId: value.textureId);

    if (Platform.isAndroid && !value.handlesCropAndRotation) {
      // Impeller ImageReader 后端不会自动应用 Surface 的 transform matrix，需在 Widget 层补偿旋转与前置镜像
      final bool isFront = value.description.lensDirection == CameraLensDirection.front;
      if (isFront) {
        texture = Transform.scale(scaleY: -1.0, child: texture);
      }
      final int quarterTurns = (value.description.sensorOrientation ~/ 90) % 4;
      if (quarterTurns != 0) {
        texture = RotatedBox(quarterTurns: quarterTurns, child: texture);
      }
    }

    return texture;
  }
}
