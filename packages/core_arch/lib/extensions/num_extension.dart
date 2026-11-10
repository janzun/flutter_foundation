import 'package:intl/intl.dart';

/// 货币与文件体积数值扩展
extension NumExtension on num {
  /// 格式化为国际标准货币格式（默认形如 "$1,299.99"）
  String toCurrency({
    String symbol = '\$',
    int decimalDigits = 2,
    String? locale,
  }) {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
    return formatter.format(this);
  }

  /// 转换为带逗号的千分位数字字符串（形如 "12,345.67"）
  String toDecimalString({int decimalDigits = 2, String? locale}) {
    final formatter = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: decimalDigits,
    );
    return formatter.format(this);
  }

  /// 文件大小友好换算（例如 "512 B", "24.5 KB", "1.8 MB", "3.2 GB"）
  String toByteSizeString({int decimals = 1}) {
    if (this <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var bytes = toDouble();
    var i = 0;
    while (bytes >= 1024 && i < suffixes.length - 1) {
      bytes /= 1024;
      i++;
    }
    return '${bytes.toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}
