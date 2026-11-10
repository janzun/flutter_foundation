import 'package:flutter/widgets.dart';

/// 响应式内容布局组件
///
/// 基于父级约束宽度自适应渲染不同形态（如手机单列流 vs 桌面左右双栏）
class ResponsiveLayout extends StatelessWidget {
  /// 紧凑型手机尺寸展示组件 (< 600dp)
  final WidgetBuilder compact;

  /// 中等尺寸平板组件 (600dp <= width < 840dp，可选，若不传则回退到 compact)
  final WidgetBuilder? medium;

  /// 宽屏桌面端展示组件 (>= 840dp，可选，若不传则回退到 medium 或 compact)
  final WidgetBuilder? expanded;

  const ResponsiveLayout({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width >= 840 && expanded != null) {
          return expanded!(context);
        }
        if (width >= 600 && medium != null) {
          return medium!(context);
        }
        return compact(context);
      },
    );
  }
}
