import 'analytics_impl.dart';
import 'model/event_names.dart';
import 'model/event_type.dart';

export 'model/analytics_event.dart';
export 'model/device_context.dart';
export 'model/event_names.dart';
export 'model/event_type.dart';
export 'service/analytics_route_observer.dart';

/// 埋点对外纯静态门面类 (Analytics)
///
/// 遵循单向数据流与极简调用设计，直接通过 `Analytics.xxx` 静态方法调用。
///
/// ### 核心设计原则：
/// 1. **全自动底层托管**：
///    - 应用生命周期 (`app_install`, `app_launch`, `app_show`, `app_hide`) 全自动上报；
///    - 页面流转与停留时长 (`page_view`) 依托 [AnalyticsRouteObserver] 离开时全自动结算并发射；
/// 2. **手动精准业务控制**：
///    - 用户交互点击必须显式调用 [trackAction]；
///    - 曝光、转化、错误分别通过专有方法调用，绝无杂乱无意义的垃圾点击数据；
/// 3. **全局上下文合二为一**：
///    - 用户 ID 与业务全局变量统一通过 [setSuperProperties] 管理，一次设置全量自动带上；
/// 4. **完全基于 HTTP API 统一网关**：
///    - 零 Supabase SDK 依赖，直接对接 `POST /v1/events`。
class Analytics {
  Analytics._();

  /// 初始化埋点模块（单方法搞定初始化、公共属性预置与全局异常拦截）
  ///
  /// 参数说明：
  /// - [appId]: 应用在 `common.apps` 数据表中的唯一 UUID；
  /// - [prod]: 是否为正式服（默认 true 正式服: `https://api.janzun.com/v1/events`；false 测试服: `https://test.janzun.com/v1/events`）；
  /// - [channel]: 应用分发渠道标识 (如 'appstore', 'google_play')；
  /// - [superProperties]: 初始化时预设的公共字典（若含 `user_id` 会自动绑定当前用户）；
  /// - [autoCaptureErrors]: 是否开启全局未捕获异常自动捕获（默认 true，自动挂载 FlutterError 和 PlatformDispatcher）；
  /// - [batchSize]: 触发自动批量上报的内存队列阈值 (默认 20 条，单次最大 30 条)；
  /// - [flushInterval]: 定时批量上报周期 (默认 15 秒)。
  static Future<void> initialize({
    required String appId,
    bool prod = true,
    String? channel,
    Map<String, dynamic>? superProperties,
    bool autoCaptureErrors = true,
    int batchSize = 20,
    Duration flushInterval = const Duration(seconds: 15),
  }) =>
      AnalyticsImpl.instance.initialize(
        appId: appId,
        prod: prod,
        channel: channel,
        superProperties: superProperties,
        autoCaptureErrors: autoCaptureErrors,
        batchSize: batchSize,
        flushInterval: flushInterval,
      );

  /// 设置全局公共属性（包含登录用户 ID）
  ///
  /// - 登录成功时传入：`Analytics.setSuperProperties({'user_id': 'uuid_xxx', 'is_vip': true})`；
  /// - 退出登录时调用：[clearSuperProperties]。
  static void setSuperProperties(Map<String, dynamic> properties) =>
      AnalyticsImpl.instance.setSuperProperties(properties);

  /// 清空全局公共属性并解绑登录用户状态
  static void clearSuperProperties() =>
      AnalyticsImpl.instance.clearSuperProperties();

  /// 仅清除当前登录用户标识（退出登录时使用，保留设备环境与渠道等公共属性）
  static void clearUserId() => AnalyticsImpl.instance.clearUserId();

  /// 手动用户交互点击打点 (Action)
  ///
  /// 参数说明：
  /// - [actionName]: 交互动作名称（建议优先使用 [EventNames] 中常量，如 [EventNames.clickPay]）；
  /// - [pageName]: 发生交互的页面容器/路由名称（选填，不传自动取当前活跃页面）；
  /// - [properties]: 交互附带的专属上下文参数字典。
  static void trackAction(
    String actionName, {
    String? pageName,
    Map<String, dynamic>? properties,
    bool isImmediate = false,
  }) =>
      AnalyticsImpl.instance.trackAction(
        actionName,
        pageName: pageName,
        properties: properties,
        isImmediate: isImmediate,
      );

  /// 手动曝光展示打点 (Impression)
  ///
  /// 参数说明：
  /// - [moduleName]: 曝光模块标识（建议优先使用 [EventNames]，如 [EventNames.paywallShow]）；
  /// - [pageName]: 发生曝光的页面容器名称；
  /// - [properties]: 曝光附带的专属参数字典。
  static void trackImpression(
    String moduleName, {
    String? pageName,
    Map<String, dynamic>? properties,
    bool isImmediate = false,
  }) =>
      AnalyticsImpl.instance.trackImpression(
        moduleName,
        pageName: pageName,
        properties: properties,
        isImmediate: isImmediate,
      );

  /// 手动核心商业转化打点 (Conversion)
  ///
  /// 转化类关键事件默认绕过内存缓冲，立即上报。
  ///
  /// 参数说明：
  /// - [conversionName]: 转化目标标识（如 [EventNames.paymentSuccess]）；
  /// - [pageName]: 转化发生页面；
  /// - [properties]: 转化关键财务或业务参数（如 `{'amount': 29.9, 'currency': 'USD'}`）。
  static void trackConversion(
    String conversionName, {
    String? pageName,
    Map<String, dynamic>? properties,
  }) =>
      AnalyticsImpl.instance.trackConversion(
        conversionName,
        pageName: pageName,
        properties: properties,
      );

  /// 手动业务异常与错误监控打点 (Error)
  ///
  /// 故障错误类事件默认立即上报。
  ///
  /// 参数说明：
  /// - [errorName]: 错误标识（如 [EventNames.apiError]）；
  /// - [message]: 错误描述信息；
  /// - [stackTrace]: 异常堆栈前缀；
  /// - [pageName]: 发生异常的页面；
  /// - [properties]: 错误上下文。
  static void trackError(
    String errorName, {
    required String message,
    String? stackTrace,
    String? pageName,
    Map<String, dynamic>? properties,
  }) =>
      AnalyticsImpl.instance.trackError(
        errorName,
        message: message,
        stackTrace: stackTrace,
        pageName: pageName,
        properties: properties,
      );

  /// 自定义长尾业务打点 (Custom)
  ///
  /// 当预设常量无法满足某些极特殊的长尾需求时调用。
  static void trackCustom(
    String eventName, {
    EventType type = EventType.action,
    String? pageName,
    Map<String, dynamic>? properties,
    bool isImmediate = false,
  }) =>
      AnalyticsImpl.instance.trackCustom(
        eventName,
        type: type,
        pageName: pageName,
        properties: properties,
        isImmediate: isImmediate,
      );

  /// 立即强制清空并上报当前队列中的全部积压事件
  static Future<void> flush() => AnalyticsImpl.instance.flush();
}
