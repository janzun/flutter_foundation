import 'package:flutter/material.dart';

/// 跨端自适应导航目标项定义
class AdaptiveDestination {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;

  const AdaptiveDestination({
    required this.icon,
    this.selectedIcon,
    required this.label,
  });
}

/// 跨端自适应脚手架
///
/// - 手机端 (width < 600dp)：自动渲染为底部导航 `NavigationBar`
/// - 平板/桌面端 (width >= 600dp)：自动切换为左侧侧边栏导航 `NavigationRail`
class AdaptiveScaffold extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<AdaptiveDestination> destinations;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? drawer;

  const AdaptiveScaffold({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.drawer,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // 手机尺寸：底部导航栏
        if (width < 600) {
          return Scaffold(
            appBar: appBar,
            drawer: drawer,
            floatingActionButton: floatingActionButton,
            body: body,
            bottomNavigationBar: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: destinations
                  .map(
                    (d) => NavigationDestination(
                      icon: Icon(d.icon),
                      selectedIcon:
                          d.selectedIcon != null ? Icon(d.selectedIcon) : null,
                      label: d.label,
                    ),
                  )
                  .toList(),
            ),
          );
        }

        // 平板 / 桌面 / Web 宽屏：左侧 NavigationRail + 右侧主体内容
        final bool isExpanded = width >= 840;

        return Scaffold(
          appBar: appBar,
          drawer: drawer,
          floatingActionButton: floatingActionButton,
          body: Row(
            children: [
              NavigationRail(
                extended: isExpanded,
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                destinations: destinations
                    .map(
                      (d) => NavigationRailDestination(
                        icon: Icon(d.icon),
                        selectedIcon: d.selectedIcon != null
                            ? Icon(d.selectedIcon)
                            : null,
                        label: Text(d.label),
                      ),
                    )
                    .toList(),
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: body),
            ],
          ),
        );
      },
    );
  }
}
