/// 常见后端标准业务返回包裹实体
class ApiResponse<T> {
  /// 业务状态码（通常 200 或 0 表示业务成功）
  final int code;

  /// 业务提示消息
  final String? message;

  /// 业务数据负载
  final T? data;

  const ApiResponse({
    required this.code,
    this.message,
    this.data,
  });

  /// 是否为成功的业务响应（默认 200 或 0 为成功）
  bool get isSuccess => code == 200 || code == 0;

  /// 工厂解析方法（需配合 Retrofit 泛型反序列化使用）
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiResponse<T>(
      code: json['code'] as int? ?? (json['status'] as int? ?? 200),
      message: json['message'] as String? ?? json['msg'] as String?,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) {
    return <String, dynamic>{
      'code': code,
      'message': message,
      if (data != null) 'data': toJsonT(data as T),
    };
  }
}
