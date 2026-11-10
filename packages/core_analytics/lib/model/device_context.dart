import 'package:flutter/foundation.dart';

/// 设备与环境不可变上下文实体
///
/// 封装当前设备只读的硬件指纹与运行环境信息。
/// 全生命周期内由 [DeviceCollector] 仅采集一次并驻留内存。
@immutable
class DeviceContext {
  /// 设备/匿名唯一标识符
  final String deviceId;

  /// 硬件品牌 (如 'Apple', 'Xiaomi', 'Huawei')
  final String deviceBrand;

  /// 设备具体型号 (如 'iPhone 16 Pro', '23049RAD8C')
  final String deviceModel;

  /// 操作系统平台 ('ios', 'android', 'web', 'macos', 等)
  final String platform;

  /// 操作系统版本 (如 'iOS 18.2', 'Android 15')
  final String osVersion;

  /// 应用版本号 (如 '1.0.0')
  final String appVersion;

  /// 应用构建号 (如 '1')
  final String buildNumber;

  /// 应用分发渠道 (如 'appstore', 'google_play', 'xiaomi')
  final String? channel;

  /// 屏幕宽度 (像素)
  final int? screenWidth;

  /// 屏幕高度 (像素)
  final int? screenHeight;

  /// 国家地区代码 (如 'CN', 'US')
  final String? countryCode;

  /// 语言代码 (如 'zh-CN', 'en-US')
  final String? language;

  const DeviceContext({
    required this.deviceId,
    required this.deviceBrand,
    required this.deviceModel,
    required this.platform,
    required this.osVersion,
    required this.appVersion,
    required this.buildNumber,
    this.channel,
    this.screenWidth,
    this.screenHeight,
    this.countryCode,
    this.language,
  });

  /// 序列化为 Map
  Map<String, dynamic> toMap() {
    return {
      'device_id': deviceId,
      'device_brand': deviceBrand,
      'device_model': deviceModel,
      'platform': platform,
      'os_version': osVersion,
      'app_version': appVersion,
      'channel': channel,
      'screen_width': screenWidth,
      'screen_height': screenHeight,
      'country_code': countryCode,
      'language': language,
    };
  }
}
