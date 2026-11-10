import 'dart:async';
import 'package:dio/dio.dart';
import '../mvvm/result.dart';

/// 工业级 Dio 封装客户端
class DioClient {
  final Dio dio;

  DioClient._(this.dio);

  /// 创建配置完整的 DioClient 实例
  factory DioClient({
    required String baseUrl,
    Duration connectTimeout = const Duration(seconds: 15),
    Duration receiveTimeout = const Duration(seconds: 15),
    Duration sendTimeout = const Duration(seconds: 15),
    FutureOr<String?> Function()? tokenProvider,
    Map<String, dynamic> Function()? headerProvider,
    void Function()? onUnauthorized,
    List<Interceptor>? interceptors,
  }) {
    final baseOptions = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      responseType: ResponseType.json,
      headers: <String, dynamic>{
        'Accept': 'application/json',
      },
    );

    final dioInstance = Dio(baseOptions);

    // 1. 核心认证与通用请求头拦截器
    dioInstance.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (headerProvider != null) {
            final customHeaders = headerProvider();
            options.headers.addAll(customHeaders);
          }

          if (tokenProvider != null) {
            final token = await tokenProvider();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );

    // 2. 追加外部自定义拦截器
    if (interceptors != null && interceptors.isNotEmpty) {
      dioInstance.interceptors.addAll(interceptors);
    }

    return DioClient._(dioInstance);
  }

  /// 通用异步卫士：执行请求并自动将网络、服务端状态码和解析异常转换为标准 `Result<T>`
  static Future<Result<T>> guard<T>(Future<T> Function() request) async {
    try {
      final result = await request();
      return Result.ok(result);
    } on DioException catch (dioError) {
      return Result.err(_parseDioError(dioError));
    } on AppException catch (appError) {
      return Result.err(appError);
    } catch (e) {
      return Result.err(
        AppException(
          code: 'UNKNOWN_ERROR',
          message: e.toString(),
          originalError: e,
        ),
      );
    }
  }

  static AppException _parseDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    final dynamic responseData = error.response?.data;

    String? serverMessage;
    String? serverCode;

    if (responseData is Map<String, dynamic>) {
      serverMessage = responseData['message'] as String? ??
          responseData['msg'] as String? ??
          responseData['error'] as String?;
      serverCode = responseData['code']?.toString();
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return AppException(
          code: 'TIMEOUT',
          message: '网络连接超时，请检查网络后重试',
          statusCode: statusCode,
          originalError: error,
        );
      case DioExceptionType.badResponse:
        final code = serverCode ?? 'HTTP_$statusCode';
        final message = serverMessage ?? _getHttpErrorMessage(statusCode);
        return AppException(
          code: code,
          message: message,
          statusCode: statusCode,
          originalError: error,
        );
      case DioExceptionType.cancel:
        return AppException(
          code: 'REQUEST_CANCELLED',
          message: '请求已被取消',
          statusCode: statusCode,
          originalError: error,
        );
      case DioExceptionType.connectionError:
        return AppException(
          code: 'CONNECTION_ERROR',
          message: '网络不可用或服务器连接失败',
          statusCode: statusCode,
          originalError: error,
        );
      case DioExceptionType.badCertificate:
        return AppException(
          code: 'BAD_CERTIFICATE',
          message: '证书校验失败，连接不安全',
          statusCode: statusCode,
          originalError: error,
        );
      case DioExceptionType.unknown:
        return AppException(
          code: 'NETWORK_UNKNOWN',
          message: error.message ?? '网络请求出现未知错误',
          statusCode: statusCode,
          originalError: error,
        );
    }
  }

  static String _getHttpErrorMessage(int? statusCode) {
    return switch (statusCode) {
      400 => '请求参数有误 (400)',
      401 => '登录已过期或未授权 (401)',
      403 => '无权限访问该资源 (403)',
      404 => '请求的资源未找到 (404)',
      500 => '服务器内部错误 (500)',
      502 => '网关错误 (502)',
      503 => '服务暂时不可用 (503)',
      504 => '网关超时 (504)',
      _ => '网络请求失败 ($statusCode)',
    };
  }

  // === 基础 HTTP 请求封装 ===

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}
