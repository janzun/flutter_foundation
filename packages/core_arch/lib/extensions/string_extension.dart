/// 字符串合规脱敏与常用校验扩展
extension StringExtension on String {
  /// 是否为合法电子邮箱
  bool get isEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(trim());
  }

  /// 是否为合法 URL 链接
  bool get isUrl {
    final uri = Uri.tryParse(trim());
    return uri != null && (uri.isScheme('http') || uri.isScheme('https'));
  }

  /// 是否全为纯数字
  bool get isNumeric {
    return num.tryParse(trim()) != null;
  }

  /// 邮箱出海隐私合规脱敏（例如 "alex.smith@gmail.com" -> "al***h@gmail.com"）
  String maskEmail() {
    final trimmed = trim();
    if (!trimmed.contains('@')) return trimmed;
    final parts = trimmed.split('@');
    final name = parts[0];
    final domain = parts[1];

    if (name.length <= 2) {
      return '$name***@$domain';
    }
    return '${name.substring(0, 2)}***${name.substring(name.length - 1)}@$domain';
  }

  /// 手机号码隐私合规脱敏（例如 "+16501234567" -> "+1650***4567"）
  String maskPhone() {
    final trimmed = trim();
    if (trimmed.length < 7) return trimmed;
    final start = trimmed.substring(0, 4);
    final end = trimmed.substring(trimmed.length - 4);
    return '$start***$end';
  }
}

/// 可空字符串安全扩展
extension NullableStringExtension on String? {
  /// 是否不为 null 且不为空白字符
  bool get isNotNullOrBlank {
    return this != null && this!.trim().isNotEmpty;
  }

  /// 为空时的安全回退值
  String orDefault([String defaultValue = '']) {
    return (this != null && this!.isNotEmpty) ? this! : defaultValue;
  }
}
