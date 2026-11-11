import 'package:flutter/widgets.dart';

/// 滑动进入方向
enum SlideDirection {
  /// 从下往上滑入（默认）
  bottomToTop,

  /// 从上往下滑入
  topToBottom,

  /// 从右往左滑入
  rightToLeft,

  /// 从左往右滑入
  leftToRight,
}

/// 声明式局域组件淡入滑入动效（非常适合列表卡片瀑布流交错入场、页面内容初次呈现）
class FadeSlideTransition extends StatefulWidget {
  final Widget child;

  /// 滑动进入方向
  final SlideDirection direction;

  /// 动画时长，默认 350ms
  final Duration duration;

  /// 延时执行时长（适合用于列表项 `index * 50ms` 产生流水线瀑布动效）
  final Duration delay;

  /// 滑动偏移距离跨度（默认 0.2，即自身尺寸的 20% 微偏移，自然不突兀）
  final double offsetDistance;

  /// 动画曲线
  final Curve curve;

  const FadeSlideTransition({
    super.key,
    required this.child,
    this.direction = SlideDirection.bottomToTop,
    this.duration = const Duration(milliseconds: 350),
    this.delay = Duration.zero,
    this.offsetDistance = 0.2,
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<FadeSlideTransition> createState() => _FadeSlideTransitionState();
}

class _FadeSlideTransitionState extends State<FadeSlideTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    final curved = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curved);

    final beginOffset = switch (widget.direction) {
      SlideDirection.bottomToTop => Offset(0.0, widget.offsetDistance),
      SlideDirection.topToBottom => Offset(0.0, -widget.offsetDistance),
      SlideDirection.rightToLeft => Offset(widget.offsetDistance, 0.0),
      SlideDirection.leftToRight => Offset(-widget.offsetDistance, 0.0),
    };

    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(curved);

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
