import 'package:flutter/foundation.dart';
import '../mvvm/result.dart';
import 'api_response.dart';
import 'dio_client.dart';

/// 统一业务仓储基类 (Repository)
///
/// 配合 Retrofit Service 消费，提供异常抹平与通用返回封装
abstract class BaseRepository {
  const BaseRepository();

  /// 推荐方式：执行标准 RESTful API 调用（HTTP 状态码驱动）
  ///
  /// Retrofit 内部自动完成 JSON -> 实体类的反序列化，若发生网络异常、
  /// 401/404/500 或解析异常，直接被转换为 [Result.err(AppException)]
  @protected
  Future<Result<T>> safeCall<T>(Future<T> Function() call) async {
    return await DioClient.guard<T>(call);
  }

  /// 适配常见包裹结构：针对返回 `ApiResponse<T>` (`{code, message, data}`) 的业务接口
  ///
  /// 自动判断 code 是否成功，若成功则返回 data，若失败则抛出包含服务端业务错误码与信息的 AppException
  @protected
  Future<Result<T>> safeCallApi<T>(Future<ApiResponse<T>> Function() call) async {
    return await DioClient.guard<T>(() async {
      final response = await call();
      if (!response.isSuccess) {
        throw AppException(
          code: response.code.toString(),
          message: response.message ?? '业务处理失败',
        );
      }
      return response.data as T;
    });
  }
}
