import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 防连点 / 防抖动包装组件
class DebounceTap extends StatefulWidget {
  /// 子组件（如按钮、列表项、图标等）
  final Widget child;

  /// 点击回调
  final VoidCallback? onTap;

  /// 防抖间隔时间，默认 500ms
  final Duration duration;

  /// 是否在触发点击时执行轻量触觉反馈，默认 true
  final bool enableFeedback;

  /// 命中检测模式
  final HitTestBehavior behavior;

  const DebounceTap({
    super.key,
    required this.child,
    required this.onTap,
    this.duration = const Duration(milliseconds: 500),
    this.enableFeedback = true,
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  State<DebounceTap> createState() => _DebounceTapState();
}

class _DebounceTapState extends State<DebounceTap> {
  DateTime? _lastTapTime;

  void _handleTap() {
    if (widget.onTap == null) return;

    final now = DateTime.now();
    if (_lastTapTime == null ||
        now.difference(_lastTapTime!) > widget.duration) {
      _lastTapTime = now;
      if (widget.enableFeedback) {
        HapticFeedback.lightImpact();
      }
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTap: widget.onTap != null ? _handleTap : null,
      child: widget.child,
    );
  }
}

/// 预设样式的通用防抖按钮组件
class DebounceButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Duration debounceDuration;
  final ButtonStyle? style;

  const DebounceButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return DebounceTap(
      duration: debounceDuration,
      onTap: onPressed,
      child: ElevatedButton(
        style: style,
        onPressed: null, // 由外层 DebounceTap 统一处理防抖与反馈，避免重复触发
        child: child,
      ),
    );
  }
}
