import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 跨端页面级转场动画构建器（完全适配 go_router 的 CustomTransitionPage）
class AppTransitions {
  AppTransitions._();

  /// 1. 经典水平滑入（从右向左，移动端标准导航转场）
  static CustomTransitionPage<T> slideHorizontal<T>({
    required Widget child,
    LocalKey? key,
    Duration duration = const Duration(milliseconds: 300),
    Duration reverseDuration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: reverseDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// 2. 底部全屏向上滑入（适合登录页、表单页、发布弹窗等 Modal 风格全屏页面）
  static CustomTransitionPage<T> slideUp<T>({
    required Widget child,
    LocalKey? key,
    Duration duration = const Duration(milliseconds: 300),
    Duration reverseDuration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: reverseDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// 3. 淡入淡出转场（Fade，适合 Tab 切换、Web 页面或桌面大屏）
  static CustomTransitionPage<T> fade<T>({
    required Widget child,
    LocalKey? key,
    Duration duration = const Duration(milliseconds: 200),
    Duration reverseDuration = const Duration(milliseconds: 200),
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: reverseDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: child,
        );
      },
    );
  }

  /// 4. 跨端自适应转场（Adaptive）
  ///
  /// - Web / 桌面端 (macOS/Windows/Linux) 或宽屏设备：自动采用 150ms 极速淡入淡出，防止大屏晃眼
  /// - 移动端 (Android/iOS)：自动采用丝滑从右向左水平滑入
  static CustomTransitionPage<T> adaptive<T>({
    required BuildContext context,
    required Widget child,
    LocalKey? key,
  }) {
    final bool isDesktopOrWeb = kIsWeb ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux;

    if (isDesktopOrWeb) {
      return fade<T>(
        key: key,
        child: child,
        duration: const Duration(milliseconds: 150),
        reverseDuration: const Duration(milliseconds: 150),
      );
    }

    return slideHorizontal<T>(
      key: key,
      child: child,
    );
  }
}
