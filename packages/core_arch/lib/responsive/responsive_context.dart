import 'package:flutter/widgets.dart';
import 'screen_type.dart';

/// 挂载在 BuildContext 上的响应式断点与自适应扩展
extension ResponsiveContext on BuildContext {
  /// 屏幕宽度
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// 屏幕高度
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// 屏幕方向
  Orientation get orientation => MediaQuery.orientationOf(this);

  /// 当前屏幕形态断点
  ScreenType get screenType {
    final width = screenWidth;
    if (width < 600) return ScreenType.compact;
    if (width < 840) return ScreenType.medium;
    return ScreenType.expanded;
  }

  /// 是否为手机竖屏尺寸 (< 600dp)
  bool get isMobile => screenType.isMobile;

  /// 是否为平板竖屏/小窗尺寸 (600dp <= width < 840dp)
  bool get isTablet => screenType.isTablet;

  /// 是否为桌面/Web宽屏尺寸 (>= 840dp)
  bool get isDesktop => screenType.isDesktop;

  /// 是否为横屏
  bool get isLandscape => orientation == Orientation.landscape;

  /// 自适应值获取器：根据屏幕宽度自动选择最合适的值
  T responsiveValue<T>({
    required T compact,
    T? medium,
    T? expanded,
  }) {
    return switch (screenType) {
      ScreenType.compact => compact,
      ScreenType.medium => medium ?? compact,
      ScreenType.expanded => expanded ?? medium ?? compact,
    };
  }
}
