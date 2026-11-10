import 'package:intl/intl.dart';

/// 出海与国际化时间格式化扩展
extension DateExtension on DateTime {
  /// 格式化为国际标准日期字符串（默认形如 "Nov 10, 2026"）
  String toFormattedDate({String pattern = 'MMM d, yyyy', String? locale}) {
    return DateFormat(pattern, locale).format(this);
  }

  /// 格式化为包含时间的完整字符串（形如 "Nov 10, 2026 20:30"）
  String toFormattedDateTime({
    String pattern = 'MMM d, yyyy HH:mm',
    String? locale,
  }) {
    return DateFormat(pattern, locale).format(this);
  }

  /// 转换为 UTC ISO-8601 标准字符串（适合向云端/服务端传输）
  String toUtcIso8601String() {
    return toUtc().toIso8601String();
  }

  /// 西方习惯友好时间差（例如 "Just now", "5m ago", "2h ago", "Yesterday", "Oct 24"）
  String timeAgo({String? locale}) {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.isNegative) {
      return toFormattedDate(locale: locale);
    }

    if (difference.inSeconds < 45) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1 || isYesterday) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (year == now.year) {
      return DateFormat('MMM d', locale).format(this);
    } else {
      return DateFormat('MMM d, yyyy', locale).format(this);
    }
  }

  /// 是否为今天
  bool get isToday {
    final now = DateTime.now();
    return isSameDay(now);
  }

  /// 是否为昨天
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(yesterday);
  }

  /// 是否为同一天
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
