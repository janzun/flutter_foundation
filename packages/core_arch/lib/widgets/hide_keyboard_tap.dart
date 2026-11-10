import 'package:flutter/widgets.dart';

/// 点击空白区域自动收起键盘组件
class HideKeyboardTap extends StatelessWidget {
  final Widget child;

  const HideKeyboardTap({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: child,
    );
  }
}
