import 'dart:io';
import 'package:dio/dio.dart';
import '../mvvm/result.dart';
import 'dio_client.dart';

/// 工业级大文件安全下载工具
class FileDownloader {
  FileDownloader._();

  /// 下载远程文件到本地指定路径
  ///
  /// - [urlPath]: 远程下载链接
  /// - [savePath]: 本地最终目标保存路径（支持跨平台全路径）
  /// - [onReceiveProgress]: 下载进度回调 `(int receivedBytes, int totalBytes)`
  /// - [cancelToken]: 支持外部随时取消下载
  /// - [deleteOnError]: 下载失败或取消时是否清理临时文件（默认 true）
  /// - [timeout]: 下载超时时间（默认 120 秒）
  static Future<Result<File>> downloadFile({
    required String urlPath,
    required String savePath,
    void Function(int received, int total)? onReceiveProgress,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    Duration timeout = const Duration(seconds: 120),
  }) async {
    return await DioClient.guard<File>(() async {
      final targetFile = File(savePath);
      final parentDir = targetFile.parent;
      if (!parentDir.existsSync()) {
        await parentDir.create(recursive: true);
      }

      // 临时文件隔离防损坏
      final tempFilePath = '$savePath.download_tmp';
      final tempFile = File(tempFilePath);
      if (tempFile.existsSync()) {
        await tempFile.delete();
      }

      final downloadDio = Dio(
        BaseOptions(
          connectTimeout: timeout,
          receiveTimeout: timeout,
          sendTimeout: timeout,
        ),
      );

      try {
        await downloadDio.download(
          urlPath,
          tempFilePath,
          onReceiveProgress: onReceiveProgress,
          cancelToken: cancelToken,
          deleteOnError: deleteOnError,
        );

        // 下载完整完成后原子重命名
        if (targetFile.existsSync()) {
          await targetFile.delete();
        }
        final renamedFile = await tempFile.rename(savePath);
        return renamedFile;
      } catch (e) {
        if (deleteOnError && tempFile.existsSync()) {
          try {
            await tempFile.delete();
          } catch (_) {}
        }
        rethrow;
      }
    });
  }
}
