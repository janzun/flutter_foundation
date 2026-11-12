import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model/analytics_event.dart';
import 'model/device_context.dart';
import 'model/event_names.dart';
import 'model/event_type.dart';
import 'service/device_collector.dart';
import 'service/event_queue.dart';
import 'service/session_manager.dart';

/// 埋点模块核心单例调度实现
class AnalyticsImpl with WidgetsBindingObserver {
  AnalyticsImpl._();

  static final AnalyticsImpl instance = AnalyticsImpl._();

  String? _appId;
  String? _userId;
  final Map<String, dynamic> _superProperties = {};

  DeviceContext? _deviceContext;
  EventQueue? _queue;

  static const String _prefKeyHasInstalled = 'core_analytics_has_installed';
  bool _errorHandlersRegistered = false;

  /// 初始化埋点核心服务（支持直接配置公共属性与全局异常托管）
  Future<void> initialize({
    required String appId,
    bool prod = true,
    String? channel,
    Map<String, dynamic>? superProperties,
    bool autoCaptureErrors = true,
    int batchSize = 20,
    Duration flushInterval = const Duration(seconds: 15),
  }) async {
    _appId = appId;
    final resolvedEndpoint = prod
        ? 'https://api.janzun.com/v1/events'
        : 'https://test.janzun.com/v1/events';

    // 0. 预置公共属性（如已包含 user_id 会自动解析绑定）
    if (superProperties != null && superProperties.isNotEmpty) {
      setSuperProperties(superProperties);
    }

    // 1. 单例异步采集硬件并缓存
    _deviceContext = await DeviceCollector.collectOnce(channel: channel);

    // 2. 初始化 Session 会话管理器
    SessionManager.instance.init();

    // 3. 初始化并启动批量上报队列
    _queue = EventQueue(
      endpoint: resolvedEndpoint,
      batchSize: batchSize,
      flushInterval: flushInterval,
    )..start();

    // 4. 自动注册全局未捕获异常捕获（零 PII 隐私数据）
    if (autoCaptureErrors && !_errorHandlersRegistered) {
      _registerGlobalErrorHandlers();
    }

    // 5. 监听系统生命周期，自动触发 4 大生命周期打点
    WidgetsBinding.instance.addObserver(this);
    await _handleLifecycleAutoTracking();
  }

  /// 注册全局未捕获异常捕获（FlutterError + PlatformDispatcher）
  void _registerGlobalErrorHandlers() {
    _errorHandlersRegistered = true;

    // 拦截 Flutter UI / Widget 渲染错误
    final originalFlutterOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      originalFlutterOnError?.call(details);

      // 仅截取前 10 行堆栈，杜绝超大 payload 且绝对不含用户个人隐私
      final stackLines = details.stack?.toString().split('\n').take(10).join('\n');
      trackError(
        EventNames.crash,
        message: details.exceptionAsString(),
        stackTrace: stackLines,
        properties: {
          if (details.context != null) 'error_context': details.context.toString(),
          if (details.library != null) 'library': details.library,
        },
      );
    };

    // 拦截 Dart 异步微任务与引擎层未捕获异常
    final originalPlatformOnError = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      originalPlatformOnError?.call(error, stack);

      final stackLines = stack.toString().split('\n').take(10).join('\n');
      trackError(
        EventNames.crash,
        message: error.toString(),
        stackTrace: stackLines,
      );
      return true;
    };
  }

  /// 设置全局公共属性（包含登录用户 ID）
  void setSuperProperties(Map<String, dynamic> props) {
    if (props.containsKey('user_id')) {
      _userId = props['user_id']?.toString();
    }
    _superProperties.addAll(props);
  }

  /// 清空全局公共属性与用户绑定状态
  void clearSuperProperties() {
    _userId = null;
    _superProperties.clear();
  }

  /// 仅清除当前登录用户 ID（退出登录时使用，保留 channel 等设备公共属性）
  void clearUserId() {
    _userId = null;
    _superProperties.remove('user_id');
  }

  /// 自动生命周期处理 (app_install, app_launch)
  Future<void> _handleLifecycleAutoTracking() async {
    final prefs = await SharedPreferences.getInstance();
    final hasInstalled = prefs.getBool(_prefKeyHasInstalled) ?? false;

    if (!hasInstalled) {
      await prefs.setBool(_prefKeyHasInstalled, true);
      // 首次安装激活事件
      trackCustom(
        EventNames.appInstall,
        type: EventType.lifecycle,
        properties: {'is_first_time': true},
        isImmediate: true,
      );
    }

    // 冷启动事件
    trackCustom(
      EventNames.appLaunch,
      type: EventType.lifecycle,
      properties: {'launch_type': 'cold'},
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 切回前台
      trackCustom(EventNames.appShow, type: EventType.lifecycle);
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      // 退至后台
      trackCustom(EventNames.appHide, type: EventType.lifecycle);
      _queue?.flush();
    }
  }

  /// 手动交互点击打点
  void trackAction(
    String actionName, {
    String? pageName,
    Map<String, dynamic>? properties,
    bool isImmediate = false,
  }) {
    trackCustom(
      actionName,
      type: EventType.action,
      pageName: pageName,
      properties: properties,
      isImmediate: isImmediate,
    );
  }

  /// 手动曝光打点
  void trackImpression(
    String moduleName, {
    String? pageName,
    Map<String, dynamic>? properties,
    bool isImmediate = false,
  }) {
    trackCustom(
      moduleName,
      type: EventType.impression,
      pageName: pageName,
      properties: properties,
      isImmediate: isImmediate,
    );
  }

  /// 手动商业核心转化打点（默认立即直发）
  void trackConversion(
    String conversionName, {
    String? pageName,
    Map<String, dynamic>? properties,
  }) {
    trackCustom(
      conversionName,
      type: EventType.conversion,
      pageName: pageName,
      properties: properties,
      isImmediate: true,
    );
  }

  /// 手动错误监控打点（默认立即直发）
  void trackError(
    String errorName, {
    required String message,
    String? stackTrace,
    String? pageName,
    Map<String, dynamic>? properties,
  }) {
    trackCustom(
      errorName,
      type: EventType.error,
      pageName: pageName,
      properties: {
        'error_message': message,
        if (stackTrace != null) 'stack_trace': stackTrace,
        ...?properties,
      },
      isImmediate: true,
    );
  }

  /// 自定义长尾业务打点
  void trackCustom(
    String eventName, {
    EventType type = EventType.action,
    String? pageName,
    Map<String, dynamic>? properties,
    bool isImmediate = false,
  }) {
    if (_appId == null || _queue == null) return;

    // 清洗 properties，去除 user_id 键，由顶层字段接收
    final mergedProps = Map<String, dynamic>.from(_superProperties);
    mergedProps.remove('user_id');
    if (properties != null) {
      mergedProps.addAll(properties);
      mergedProps.remove('user_id');
    }

    final event = AnalyticsEvent(
      appId: _appId!,
      userId: _userId,
      deviceId: _deviceContext?.deviceId,
      sessionId: SessionManager.instance.sessionId,
      eventType: type.value,
      eventName: eventName.trim(),
      pageName: pageName,
      properties: mergedProps,
      platform: _deviceContext?.platform,
      deviceBrand: _deviceContext?.deviceBrand,
      deviceModel: _deviceContext?.deviceModel,
      osVersion: _deviceContext?.osVersion,
      appVersion: _deviceContext?.appVersion,
      channel: _deviceContext?.channel,
      screenWidth: _deviceContext?.screenWidth,
      screenHeight: _deviceContext?.screenHeight,
      language: _deviceContext?.language,
      occurredTime: DateTime.now().toUtc(),
    );

    _queue!.enqueue(event, isImmediate: isImmediate);
  }

  /// 立即强制上报
  Future<void> flush() async {
    await _queue?.flush();
  }
}
