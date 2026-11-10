import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../model/device_context.dart';

/// 设备硬件与环境上下文采集服务
///
/// ⚠️【合规注意】：
/// 1. 本服务采集设备硬件特征（如 Android Build、iOS utsname、IDFV/UUID），
///    **严禁在用户明示同意《隐私政策》与《用户协议》之前调用**。
/// 2. 本服务内部实现**单例强缓存（Fetch Once & Cache Forever）**机制，
///    在 App 运行全生命周期内仅在首次调用时读取一次平台硬件接口，后续永久驻留内存复用，
///    严禁且杜绝高频重复调用底层系统硬件 API，规避隐私检测告警并提升打点性能。
class DeviceCollector {
  DeviceCollector._();

  static DeviceContext? _cachedContext;
  static const String _prefKeyDeviceId = 'core_analytics_device_id';

  /// 获取或采集设备上下文信息（全生命周期单例只采集一次）
  ///
  /// - [channel]: 应用分发渠道 (如 'appstore', 'google_play', 'xiaomi')
  /// - [customDeviceId]: 外部指定的设备 ID (可选，若不传则由本地持久化 UUID 维护)
  static Future<DeviceContext> collectOnce({
    String? channel,
    String? customDeviceId,
  }) async {
    // 若已缓存，直接返回内存快照，绝不触发平台插件调用
    if (_cachedContext != null) {
      return _cachedContext!;
    }

    try {
      // 1. 读取应用信息 (package_info_plus)
      final packageInfo = await PackageInfo.fromPlatform();
      final appVersion = packageInfo.version;
      final buildNumber = packageInfo.buildNumber;

      // 2. 读取或生成稳定的本地持久化 deviceId
      final deviceId = customDeviceId ?? await _getOrCreateDeviceId();

      // 3. 读取硬件与操作系统平台信息 (device_info_plus)
      final deviceInfoPlugin = DeviceInfoPlugin();
      String platformName = 'unknown';
      String deviceBrand = 'unknown';
      String deviceModel = 'unknown';
      String osVersion = 'unknown';

      if (kIsWeb) {
        platformName = 'web';
        final webInfo = await deviceInfoPlugin.webBrowserInfo;
        deviceBrand = webInfo.browserName.name;
        deviceModel = webInfo.userAgent ?? 'browser';
        osVersion = webInfo.platform ?? 'web';
      } else if (Platform.isAndroid) {
        platformName = 'android';
        final androidInfo = await deviceInfoPlugin.androidInfo;
        deviceBrand = androidInfo.brand.isNotEmpty ? androidInfo.brand : 'Android';
        deviceModel = androidInfo.model.isNotEmpty ? androidInfo.model : 'Unknown';
        osVersion = 'Android ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt})';
      } else if (Platform.isIOS) {
        platformName = 'ios';
        final iosInfo = await deviceInfoPlugin.iosInfo;
        deviceBrand = 'Apple';
        deviceModel = iosInfo.utsname.machine.isNotEmpty ? iosInfo.utsname.machine : iosInfo.model;
        osVersion = '${iosInfo.systemName} ${iosInfo.systemVersion}';
      } else if (Platform.isMacOS) {
        platformName = 'macos';
        final macInfo = await deviceInfoPlugin.macOsInfo;
        deviceBrand = 'Apple';
        deviceModel = macInfo.model;
        osVersion = 'macOS ${macInfo.osRelease}';
      } else if (Platform.isWindows) {
        platformName = 'windows';
        final winInfo = await deviceInfoPlugin.windowsInfo;
        deviceBrand = 'PC';
        deviceModel = winInfo.computerName;
        osVersion = 'Windows ${winInfo.displayVersion}';
      }

      // 4. 读取屏幕分辨率与语言环境 (PlatformDispatcher)
      final dispatcher = WidgetsBinding.instance.platformDispatcher;
      int? screenWidth;
      int? screenHeight;
      if (dispatcher.views.isNotEmpty) {
        final physicalSize = dispatcher.views.first.physicalSize;
        screenWidth = physicalSize.width.toInt();
        screenHeight = physicalSize.height.toInt();
      }

      final locale = dispatcher.locale;
      final countryCode = locale.countryCode;
      final language = locale.languageCode;

      _cachedContext = DeviceContext(
        deviceId: deviceId,
        deviceBrand: deviceBrand,
        deviceModel: deviceModel,
        platform: platformName,
        osVersion: osVersion,
        appVersion: appVersion,
        buildNumber: buildNumber,
        channel: channel,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        countryCode: countryCode,
        language: language,
      );
    } catch (e, stack) {
      debugPrint('DeviceCollector.collectOnce failed: $e\n$stack');
      // 兜底极简上下文
      _cachedContext = DeviceContext(
        deviceId: customDeviceId ?? const Uuid().v4(),
        deviceBrand: 'unknown',
        deviceModel: 'unknown',
        platform: kIsWeb ? 'web' : Platform.operatingSystem,
        osVersion: 'unknown',
        appVersion: '1.0.0',
        buildNumber: '1',
        channel: channel,
      );
    }

    return _cachedContext!;
  }

  /// 获取或持久化生成设备 ID
  static Future<String> _getOrCreateDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var id = prefs.getString(_prefKeyDeviceId);
      if (id == null || id.isEmpty) {
        id = const Uuid().v4();
        await prefs.setString(_prefKeyDeviceId, id);
      }
      return id;
    } catch (_) {
      return const Uuid().v4();
    }
  }

  /// 仅用于单元测试清理缓存
  @visibleForTesting
  static void resetCacheForTesting() {
    _cachedContext = null;
  }
}
