import 'package:flutter/material.dart';
import 'toast_util.dart';

/// 弹窗展示方位
enum DialogPosition {
  /// 屏幕居中（默认，带轻量弹性微缩放与淡入淡出动画）
  center,

  /// 底部向上滑出（适合底部选择器、ActionSheet、分享面板）
  bottom,

  /// 顶部向下滑出（适合应用内顶部通知 Banner、离线警报）
  top,

  /// 右侧向左滑出（适合桌面端/平板抽屉式筛选面板、侧边详情）
  right,

  /// 左侧向右滑出（适合侧边菜单）
  left,
}

/// 工业级多方位通用弹窗工具
class DialogUtil {
  DialogUtil._();

  /// 通用展示弹窗
  ///
  /// - [context]: 可选，若为 null 自动使用 ToastUtil.navigatorKey.currentContext 实现免 Context 弹窗
  /// - [builder]: 弹窗主体内容构建器
  /// - [position]: 弹窗方位（自动匹配物理弹性转场动效）
  /// - [barrierDismissible]: 点击背景遮罩是否关闭（默认 true）
  /// - [barrierColor]: 遮罩背景色
  /// - [duration]: 转场动画时长，默认 250ms
  static Future<T?> show<T>({
    BuildContext? context,
    required WidgetBuilder builder,
    DialogPosition position = DialogPosition.center,
    bool barrierDismissible = true,
    Color barrierColor = const Color(0x80000000),
    Duration duration = const Duration(milliseconds: 250),
  }) async {
    final effectiveContext = context ?? ToastUtil.navigatorKey.currentContext;
    if (effectiveContext == null) {
      throw StateError(
        'DialogUtil.show 无法获取有效 Context！请确保在 MaterialApp 中挂载了 ToastUtil.navigatorKey。',
      );
    }

    return await showGeneralDialog<T>(
      context: effectiveContext,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Dialog',
      barrierColor: barrierColor,
      transitionDuration: duration,
      pageBuilder: (ctx, anim, secondaryAnim) {
        final content = builder(ctx);
        return switch (position) {
          DialogPosition.center => Center(child: content),
          DialogPosition.bottom => Align(
              alignment: Alignment.bottomCenter,
              child: content,
            ),
          DialogPosition.top => Align(
              alignment: Alignment.topCenter,
              child: content,
            ),
          DialogPosition.right => Align(
              alignment: Alignment.centerRight,
              child: content,
            ),
          DialogPosition.left => Align(
              alignment: Alignment.centerLeft,
              child: content,
            ),
        };
      },
      transitionBuilder: (ctx, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return switch (position) {
          DialogPosition.center => ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(curvedAnimation),
              child: FadeTransition(
                opacity: curvedAnimation,
                child: child,
              ),
            ),
          DialogPosition.bottom => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            ),
          DialogPosition.top => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, -1.0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            ),
          DialogPosition.right => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            ),
          DialogPosition.left => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1.0, 0.0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            ),
        };
      },
    );
  }

  /// 通用确认弹窗（内置标题、内容、取消、确认按钮，支持危险操作样式）
  static Future<bool> confirm({
    BuildContext? context,
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await show<bool>(
      context: context,
      position: DialogPosition.center,
      builder: (ctx) {
        return Material(
          color: Colors.transparent,
          child: Container(
            width: 320,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: Theme.of(ctx).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  content,
                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(ctx)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.8),
                      ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: Text(cancelText),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      style: isDestructive
                          ? FilledButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                            )
                          : null,
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: Text(confirmText),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    return result ?? false;
  }
}
