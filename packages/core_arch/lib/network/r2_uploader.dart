import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../mvvm/result.dart';
import 'dio_client.dart';

/// Cloudflare R2 / S3 兼容对象存储预签名直传工具
class R2Uploader {
  R2Uploader._();

  /// 通过预签名 PUT URL 直传二进制字节流到 Cloudflare R2
  ///
  /// - [presignedPutUrl]: 服务端签发的预签名 PUT 地址
  /// - [bytes]: 待上传的文件二进制字节数组
  /// - [contentType]: 文件的 MIME 类型（如 'image/jpeg', 'application/pdf'）
  /// - [onSendProgress]: 上传进度监听回调 `(int sent, int total)`
  /// - [timeout]: 上传超时时间（默认 120 秒，适应大文件及弱网）
  static Future<Result<void>> uploadBytes({
    required String presignedPutUrl,
    required Uint8List bytes,
    required String contentType,
    void Function(int sent, int total)? onSendProgress,
    Duration timeout = const Duration(seconds: 120),
  }) async {
    return await DioClient.guard<void>(() async {
      final uploadDio = Dio(
        BaseOptions(
          connectTimeout: timeout,
          sendTimeout: timeout,
          receiveTimeout: timeout,
        ),
      );

      final stream = Stream.fromIterable([bytes]);

      final options = Options(
        headers: <String, dynamic>{
          'Content-Type': contentType,
          'Content-Length': bytes.length,
        },
      );

      await uploadDio.put<void>(
        presignedPutUrl,
        data: stream,
        options: options,
        onSendProgress: onSendProgress,
      );
    });
  }
}
