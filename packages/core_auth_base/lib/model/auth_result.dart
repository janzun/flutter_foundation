import 'package:flutter/foundation.dart';
import 'auth_error_code.dart';

/// 统一业务响应结果封装类 (Functional Result Pattern)
@immutable
class AuthResult<T> {
  /// 业务状态码 (0: 成功, 200xx: 业务错误)
  final int code;

  /// 错误提示信息或状态说明
  final String message;

  /// 具体的业务数据负载 (成功时非空，失败时为 null)
  final T? data;

  const AuthResult({
    required this.code,
    required this.message,
    this.data,
  });

  /// 是否操作成功 (状态码为 success 且非失败状态)
  bool get isSuccess => code == AuthErrorCode.success;

  /// 是否操作失败
  bool get isFailure => !isSuccess;

  /// 错误提示信息别名 (与 message 等价)
  String get errorMessage => message;

  /// 快捷成功构造
  factory AuthResult.success(T data, {String message = 'success'}) => AuthResult(
        code: AuthErrorCode.success,
        message: message,
        data: data,
      );

  /// 快捷失败构造
  factory AuthResult.failure(int code, String message) => AuthResult(
        code: code,
        message: message,
        data: null,
      );

  /// 从服务端标准 JSON 结构反序列化
  factory AuthResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> dataJson) fromDataJson,
  ) {
    final code = json['code'] as int? ?? AuthErrorCode.internalError;
    final message = json['message'] as String? ?? '未知服务端响应';
    final rawData = json['data'] as Map<String, dynamic>?;

    return AuthResult(
      code: code,
      message: message,
      data: rawData != null ? fromDataJson(rawData) : null,
    );
  }

  @override
  String toString() => 'AuthResult(code: $code, message: $message, data: $data)';
}
