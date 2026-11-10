/// 全局通用应用异常标准定义
class AppException implements Exception {
  /// 业务或系统错误码（如 'NETWORK_TIMEOUT', 'AUTH_401', 'PARSE_ERROR'）
  final String code;

  /// 用户可读的友好提示文案
  final String message;

  /// HTTP 状态码（如 400, 401, 403, 500 等）
  final int? statusCode;

  /// 底层原始异常对象（如 DioException, FormatException 等）
  final Object? originalError;

  const AppException({
    required this.code,
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() =>
      'AppException(code: $code, message: $message, statusCode: $statusCode)';
}

/// Dart 3 密封代数数据类型：表示异步操作结果（成功 Ok 或失败 Err）
sealed class Result<T> {
  const Result();

  /// 构造成功结果
  const factory Result.ok(T value) = Ok<T>;

  /// 构造失败结果
  const factory Result.err(AppException error) = Err<T>;

  /// 是否成功
  bool get isOk => this is Ok<T>;

  /// 是否失败
  bool get isErr => this is Err<T>;

  /// 若成功则返回值，失败则返回 null
  T? get valueOrNull => switch (this) {
        Ok(value: final v) => v,
        Err() => null,
      };

  /// 若失败则返回异常，成功则返回 null
  AppException? get errorOrNull => switch (this) {
        Ok() => null,
        Err(error: final e) => e,
      };

  /// 模式匹配解析
  R when<R>({
    required R Function(T value) ok,
    required R Function(AppException error) err,
  }) {
    return switch (this) {
      Ok(value: final v) => ok(v),
      Err(error: final e) => err(e),
    };
  }

  /// 数据转换映射
  Result<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      Ok(value: final v) => Result.ok(transform(v)),
      Err(error: final e) => Result.err(e),
    };
  }
}

/// 成功状态类
final class Ok<T> extends Result<T> {
  final T value;

  const Ok(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Ok<T> && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Result.ok($value)';
}

/// 失败状态类
final class Err<T> extends Result<T> {
  final AppException error;

  const Err(this.error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Err<T> && other.error == error);

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Result.err($error)';
}
