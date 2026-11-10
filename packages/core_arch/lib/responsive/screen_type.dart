/// 标准屏幕宽度尺寸形态
enum ScreenType {
  /// 紧凑型屏幕（手机竖屏，width < 600dp）
  compact,

  /// 中等尺寸屏幕（折叠屏展开、平板竖屏、桌面小窗口，600dp <= width < 840dp）
  medium,

  /// 展开型屏幕（平板横屏、桌面端、Web全屏，width >= 840dp）
  expanded;

  bool get isMobile => this == ScreenType.compact;
  bool get isTablet => this == ScreenType.medium;
  bool get isDesktop => this == ScreenType.expanded;
}
