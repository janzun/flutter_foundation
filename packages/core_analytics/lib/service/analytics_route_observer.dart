import 'package:flutter/widgets.dart';
import '../analytics.dart';

/// 自动页面停留时长与路由观察器
///
/// 挂载在 MaterialApp.navigatorObservers 中，自动感知页面流转：
/// - 进入页面时记录进入时间戳；
/// - 离开页面时自动结算并上报该页面的 `page_view` 事件，带精确时长属性。
class AnalyticsRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  String? _currentPage;
  DateTime? _pageEnterTime;

  void _emitPageViewWithDuration() {
    if (_currentPage == null || _pageEnterTime == null) return;

    final durationMs = DateTime.now().difference(_pageEnterTime!).inMilliseconds;
    // 过滤小于 150ms 的手误抖动或重定向
    if (durationMs >= 150) {
      Analytics.trackCustom(
        EventNames.pageView,
        type: EventType.pageView,
        pageName: _currentPage,
        properties: {
          'duration_sec': (durationMs / 1000).round(),
        },
      );
    }
  }

  void _onEnter(Route<dynamic> route) {
    final pageName = route.settings.name ?? route.runtimeType.toString();
    _currentPage = pageName;
    _pageEnterTime = DateTime.now();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      _emitPageViewWithDuration();
      _onEnter(route);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (route is PageRoute) {
      _emitPageViewWithDuration();
      if (previousRoute != null && previousRoute is PageRoute) {
        _onEnter(previousRoute);
      } else {
        _currentPage = null;
        _pageEnterTime = null;
      }
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is PageRoute) {
      _emitPageViewWithDuration();
      _onEnter(newRoute);
    }
  }
}
