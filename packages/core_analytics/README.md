# core_analytics

## 1. 介绍
移动端高性能、隐私合规的埋点模块。采用零第三方云 SDK 方案，直接对接统一网关协议 `POST /v1/events`。内置应用生命周期全自动追踪、路由停留时长自动结算、批量微任务队列上报（内存缓冲+定时刷新+切入后台兜底）、全局公共属性维护与无侵入异常捕获。

## 2. 最新版本 Tag
`analytics@1.0.0`

## 3. 接入方式
在项目 `pubspec.yaml` 中通过 Git 形式引入：
```yaml
dependencies:
  core_analytics:
    git:
      url: git@github.com:janzun/flutter_foundation.git
      path: packages/core_analytics
      ref: analytics@1.0.0
```

## 4. 必要配置
本模块依赖 `device_info_plus` 和 `package_info_plus`，无额外原生插件权限要求。若要自动追踪页面路由访问与停留时长，需在应用的导航器中注册路由监听器：
```dart
MaterialApp(
  navigatorObservers: [
    AnalyticsRouteObserver(),
  ],
  // ...
)
```

## 5. 完整 API 列表

### 5.1 对外门面类 `Analytics`
```dart
class Analytics {
  /// 初始化埋点模块
  static Future<void> initialize({
    required String appId,
    bool prod = true,
    String? channel,
    Map<String, dynamic>? superProperties,
    bool autoCaptureErrors = true,
    int batchSize = 20,
    Duration flushInterval = const Duration(seconds: 15),
  });

  /// 设置全局公共属性（传入包含 user_id 会自动绑定当前用户）
  static void setSuperProperties(Map<String, dynamic> properties);

  /// 清空全局公共属性并解绑登录用户状态
  static void clearSuperProperties();

  /// 仅清除当前登录用户标识（保留设备环境与渠道等公共属性）
  static void clearUserId();

  /// 手动用户交互点击打点 (Action)
  static void trackAction(
    String actionName, {
    String? pageName,
    Map<String, dynamic>? properties,
    bool isImmediate = false,
  });

  /// 手动曝光展示打点 (Impression)
  static void trackImpression(
    String moduleName, {
    String? pageName,
    Map<String, dynamic>? properties,
    bool isImmediate = false,
  });

  /// 手动核心商业转化打点 (Conversion，默认立即上报)
  static void trackConversion(
    String conversionName, {
    String? pageName,
    Map<String, dynamic>? properties,
  });

  /// 手动业务异常与错误监控打点 (Error，默认立即上报)
  static void trackError(
    String errorName, {
    required String message,
    String? stackTrace,
    String? pageName,
    Map<String, dynamic>? properties,
  });

  /// 自定义长尾业务打点 (Custom)
  static void trackCustom(
    String eventName, {
    EventType type = EventType.action,
    String? pageName,
    Map<String, dynamic>? properties,
    bool isImmediate = false,
  });

  /// 立即强制清空并上报当前队列中的全部积压事件
  static Future<void> flush();
}
```

### 5.2 路由观察器 `AnalyticsRouteObserver`
```dart
class AnalyticsRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  AnalyticsRouteObserver({String Function(Route<dynamic>)? nameExtractor});

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute);
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute);
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute});
}
```

### 5.3 数据枚举与模型

#### `EventType`
```dart
enum EventType {
  lifecycle('lifecycle'),
  pageView('page_view'),
  impression('impression'),
  action('action'),
  conversion('conversion'),
  error('error');

  final String value;
  const EventType(this.value);
}
```

#### `EventNames`
```dart
class EventNames {
  // 4 大生命周期
  static const String appInstall = 'app_install';
  static const String appLaunch = 'app_launch';
  static const String appShow = 'app_show';
  static const String appHide = 'app_hide';

  // 页面事件
  static const String pageView = 'page_view';

  // 典型商业转化事件
  static const String paywallShow = 'paywall_show';
  static const String clickPay = 'click_pay';
  static const String paymentSuccess = 'payment_success';
  static const String paymentFailed = 'payment_failed';

  // 异常监控
  static const String crash = 'crash';
  static const String apiError = 'api_error';
}
```

#### `AnalyticsEvent`
```dart
class AnalyticsEvent {
  final String eventId;
  final String appId;
  final String? userId;
  final String deviceId;
  final String sessionId;
  final String eventType;
  final String eventName;
  final String? pageName;
  final Map<String, dynamic> properties;
  final String platform;
  final String? deviceBrand;
  final String? deviceModel;
  final String? osVersion;
  final String? appVersion;
  final String? channel;
  final int? screenWidth;
  final int? screenHeight;
  final String? networkType;
  final String? timezone;
  final String? language;
  final String timestamp;

  Map<String, dynamic> toJson();
}
```

#### `DeviceContext`
```dart
class DeviceContext {
  final String deviceId;
  final String platform;
  final String? deviceBrand;
  final String? deviceModel;
  final String? osVersion;
  final String? appVersion;
  final String? channel;
  final int? screenWidth;
  final int? screenHeight;
  final String? timezone;
  final String? language;

  Map<String, dynamic> toMap();
}
```
