import 'package:flutter/foundation.dart';

/// 严格映射 POST /v1/events 接口规范的单条事件数据模型
@immutable
class AnalyticsEvent {
  /// 事件可选主键 (若客户端不传，数据库将自动通过 gen_random_uuid() 生成)
  final String? id;

  /// 应用多租户隔离 ID (必填 UUID，对应 common.apps.id)
  final String appId;

  /// 业务用户 ID (未登录时为 null)
  final String? userId;

  /// 设备匿名唯一标识符
  final String? deviceId;

  /// 单次会话生命周期 ID (30 分钟无操作自动滚动)
  final String? sessionId;

  /// 事件分类 (6 大标准类型之一)
  final String eventType;

  /// 具体事件动作名称
  final String eventName;

  /// 触发事件的页面容器/路由名
  final String? pageName;

  /// 动态扩展业务属性 (包含全局公共属性)
  final Map<String, dynamic> properties;

  /// 客户端运行平台 ('ios', 'android', 'macos', 'windows', 'web')
  final String? platform;

  /// 设备品牌 ('Apple', 'Xiaomi', 'Huawei')
  final String? deviceBrand;

  /// 设备型号 ('iPhone 16 Pro', '23049RAD8C')
  final String? deviceModel;

  /// 操作系统版本 ('iOS 18.2', 'Android 15')
  final String? osVersion;

  /// 应用版本号 ('1.0.0')
  final String? appVersion;

  /// 分发推广渠道
  final String? channel;

  /// 屏幕宽度 (像素)
  final int? screenWidth;

  /// 屏幕高度 (像素)
  final int? screenHeight;

  /// 网络连接类型 ('wifi', '5g', '4g', 'ethernet')
  final String? networkType;

  /// 语言区域代码
  final String? language;

  /// 客户端本地真实发生时间 (支持断网补报)
  final DateTime occurredTime;

  const AnalyticsEvent({
    this.id,
    required this.appId,
    this.userId,
    this.deviceId,
    this.sessionId,
    required this.eventType,
    required this.eventName,
    this.pageName,
    this.properties = const {},
    this.platform,
    this.deviceBrand,
    this.deviceModel,
    this.osVersion,
    this.appVersion,
    this.channel,
    this.screenWidth,
    this.screenHeight,
    this.networkType,
    this.language,
    required this.occurredTime,
  });

  /// 序列化为符合 POST /v1/events 接口的 JSON Map
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'app_id': appId,
      if (userId != null) 'user_id': userId,
      if (deviceId != null) 'device_id': deviceId,
      if (sessionId != null) 'session_id': sessionId,
      'event_type': eventType,
      'event_name': eventName,
      if (pageName != null) 'page_name': pageName,
      'properties': properties,
      if (platform != null) 'platform': platform,
      if (deviceBrand != null) 'device_brand': deviceBrand,
      if (deviceModel != null) 'device_model': deviceModel,
      if (osVersion != null) 'os_version': osVersion,
      if (appVersion != null) 'app_version': appVersion,
      if (channel != null) 'channel': channel,
      if (screenWidth != null) 'screen_width': screenWidth,
      if (screenHeight != null) 'screen_height': screenHeight,
      if (networkType != null) 'network_type': networkType,
      if (language != null) 'language': language,
      'occurred_time': occurredTime.toUtc().toIso8601String(),
    };
  }
}
