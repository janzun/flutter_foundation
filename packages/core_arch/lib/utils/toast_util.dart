import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 全局免 Context 轻提示与加载遮罩工具类
class ToastUtil {
  ToastUtil._();

  /// 供 MaterialApp.router 挂载的 ScaffoldMessengerKey
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// 供 MaterialApp.router 挂载的 NavigatorKey（用于弹窗与阻塞式 Loading）
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static bool _isLoadingShowing = false;

  /// 展示悬浮 SnackBar 轻提示
  ///
  /// - [message]: 提示文案
  /// - [isError]: 是否为错误提醒（控制背景主色）
  /// - [duration]: 停留时长，默认 2 秒
  static void show(
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 2),
  }) {
    final state = messengerKey.currentState;
    if (state == null) return;

    // 轻微触觉反馈
    HapticFeedback.lightImpact();

    // 移除已有 SnackBar 防重叠堆积
    state.removeCurrentSnackBar();

    state.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.redAccent.shade700 : Colors.black87,
        duration: duration,
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// 成功轻提示
  static void success(String message) {
    show(message, isError: false);
  }

  /// 错误轻提示
  static void error(String message) {
    show(message, isError: true);
  }

  /// 显示全屏阻塞式 Loading
  static void showLoading({String message = '加载中...'}) {
    final context = navigatorKey.currentContext;
    if (context == null || _isLoadingShowing) return;

    _isLoadingShowing = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (ctx) {
        return PopScope(
          canPop: false,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    if (message.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 关闭全屏阻塞式 Loading
  static void hideLoading() {
    if (!_isLoadingShowing) return;
    _isLoadingShowing = false;
    final context = navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}
