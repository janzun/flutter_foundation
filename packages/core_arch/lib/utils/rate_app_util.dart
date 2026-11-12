import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../storage/sp_util.dart';

/// 应用评分引导工具（合规版：无情绪分流，直接走系统原生评分）
///
/// 依赖 [SpUtil]，使用前需先 `await SpUtil.init()`。
class RateAppUtil {
  RateAppUtil._();

  static const String _kFirstSeen = 'core_rate_first_seen_ms';
  static const String _kLastPrompt = 'core_rate_last_prompt_ms';
  static const String _kPromptedVersion = 'core_rate_prompted_version';
  static const String _kCountPrefix = 'core_rate_count_';

  static bool _busy = false;

  /// 业务高光点调用：事件计数 +1，达到全部门槛后唤起系统原生评分。
  ///
  /// 门槛：事件累计 >= [minEvents]、首次记录起 >= [minDays] 天、
  /// 距上次唤起 >= [coolDownDays] 天、当前 App 版本未唤起过。
  /// 返回是否实际发起了评分请求（系统最终是否展示由系统配额决定）。
  static Future<bool> trigger({
    required String eventKey,
    int minEvents = 3,
    int minDays = 2,
    int coolDownDays = 60,
  }) async {
    if (_busy) return false;
    _busy = true;
    try {
      final now = _now();
      final firstSeen = _ensureFirstSeen(now);

      final countKey = '$_kCountPrefix$eventKey';
      final count = SpUtil.getInt(countKey) + 1;
      await SpUtil.setInt(countKey, count);

      if (count < minEvents) return false;
      if (now.difference(firstSeen).inDays < minDays) return false;

      final lastMs = SpUtil.getInt(_kLastPrompt);
      if (lastMs > 0 &&
          now.difference(DateTime.fromMillisecondsSinceEpoch(lastMs)).inDays <
              coolDownDays) {
        return false;
      }

      final version = await _appVersion();
      if (SpUtil.getString(_kPromptedVersion) == version) return false;

      final client = _client();
      if (!await client.isAvailable()) return false;

      await SpUtil.setInt(_kLastPrompt, now.millisecondsSinceEpoch);
      await SpUtil.setString(_kPromptedVersion, version);
      await client.requestReview();
      return true;
    } catch (e) {
      debugPrint('RateAppUtil.trigger failed: $e');
      return false;
    } finally {
      _busy = false;
    }
  }

  /// 用户主动评分（设置页“去评分”）：无门槛，优先系统原生评分，不可用时跳转商店详情页。
  ///
  /// iOS / macOS 跳转商店需传入 [appStoreId]（App Store 纯数字 ID）。
  static Future<void> requestReview({String? appStoreId}) async {
    try {
      final client = _client();
      if (await client.isAvailable()) {
        await client.requestReview();
      } else {
        await client.openStoreListing(appStoreId: appStoreId);
      }
    } catch (e) {
      debugPrint('RateAppUtil.requestReview failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // 内部实现
  // ---------------------------------------------------------------------------

  static DateTime _ensureFirstSeen(DateTime now) {
    final ms = SpUtil.getInt(_kFirstSeen);
    if (ms > 0) return DateTime.fromMillisecondsSinceEpoch(ms);
    SpUtil.setInt(_kFirstSeen, now.millisecondsSinceEpoch);
    return now;
  }

  static Future<String> _appVersion() async {
    if (debugVersion != null) return debugVersion!;
    final info = await PackageInfo.fromPlatform();
    return '${info.version}+${info.buildNumber}';
  }

  static DateTime _now() => debugNow?.call() ?? DateTime.now();

  static InAppReview _client() => debugClient ?? InAppReview.instance;

  // ---------------------------------------------------------------------------
  // 测试注入点（仅供单元测试）
  // ---------------------------------------------------------------------------

  @visibleForTesting
  static DateTime Function()? debugNow;

  @visibleForTesting
  static String? debugVersion;

  @visibleForTesting
  static InAppReview? debugClient;
}
