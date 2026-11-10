import 'package:flutter/widgets.dart';

/// 宽屏内容最大宽度限制器
///
/// 防止在桌面 4K 显示器或超宽 Web 页面中，文本、列表或表单被无限拉长导致阅读体验劣化
class ContentMaxWidth extends StatelessWidget {
  final Widget child;

  /// 最大限制宽度，默认 1200dp
  final double maxWidth;

  const ContentMaxWidth({
    super.key,
    required this.child,
    this.maxWidth = 1200,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
