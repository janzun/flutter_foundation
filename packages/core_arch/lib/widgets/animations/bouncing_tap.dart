import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// 弹性微缩放交互组件（提供类似 iOS 负一屏与精品质感 App 的按压缩放回弹）
class BouncingTap extends StatefulWidget {
  final Widget child;

  /// 点击回调
  final VoidCallback? onTap;

  /// 按下时的最小缩放比，默认 0.96（4% 微缩放，高级不夸张）
  final double scaleLowerLimit;

  /// 缩放动画时长，默认 100ms
  final Duration duration;

  /// 是否启用系统轻量触觉反馈，默认 true
  final bool enableFeedback;

  /// 命中测试行为
  final HitTestBehavior behavior;

  const BouncingTap({
    super.key,
    required this.child,
    required this.onTap,
    this.scaleLowerLimit = 0.96,
    this.duration = const Duration(milliseconds: 100),
    this.enableFeedback = true,
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  State<BouncingTap> createState() => _BouncingTapState();
}

class _BouncingTapState extends State<BouncingTap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      lowerBound: widget.scaleLowerLimit,
      upperBound: 1.0,
      value: 1.0,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    if (widget.enableFeedback) {
      HapticFeedback.lightImpact();
    }
    _controller.reverse();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap == null) return;
    _controller.forward();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    if (widget.onTap == null) return;
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: widget.onTap != null ? _onTapDown : null,
      onTapUp: widget.onTap != null ? _onTapUp : null,
      onTapCancel: widget.onTap != null ? _onTapCancel : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
