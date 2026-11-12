import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart' hide PickedFile;
import 'package:mime/mime.dart';
import 'models/io_result.dart';
import 'models/picked_file.dart';

/// 系统文件与媒体选取工具门面类。
///
/// 核心特性：
/// 1. 媒体与文件分治：
///    - 视觉媒体（图片/视频）：底层驱动为 [ImagePicker]，在移动端优先调起原生现代相册，支持相机拍摄与原生硬件级等比缩放预处理。
///    - 音频与通用文档：底层驱动为 [FilePicker]，调起系统文件选择器，支持类型过滤。
/// 2. 区分用户主动取消（[IOStatus.cancelled]）与真实异常（[IOStatus.failure]）。
/// 3. 返回统一抹平的 [PickedFile]，屏蔽 Web 端 path 为 null 的空安全陷阱。
class PickUtil {
  PickUtil._();

  static final ImagePicker _imagePicker = ImagePicker();

  // ==========================================================
  // 1. 相册选取视觉媒体 (图片 / 视频)
  // ==========================================================

  /// 从系统相册选取单张图片。
  ///
  /// - [maxWidth] / [maxHeight]: 可选限制最大宽高（等比缩放）。
  ///   注意：Android、iOS、Web 端会利用系统/浏览器底层硬件加速进行等比缩放与压缩；桌面端直接返回原图。
  /// - [imageQuality]: 可选图片压缩质量 (0-100)，不传则保持原图画质。
  static Future<IOResult<PickedFile>> pickImage({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final xFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (xFile == null) {
        return const IOResult.cancelled();
      }

      final picked = await _fromXFile(xFile);
      return IOResult.success(picked);
    } on PlatformException catch (e) {
      return _handlePlatformException(e);
    } catch (e) {
      return IOResult.failure(
        errorMessage: 'Failed to pick image: $e',
        rawError: e,
      );
    }
  }

  /// 从系统相册选取多张图片。
  ///
  /// - [limit]: 可选限制最多允许选取张数（若指定必须 >= 2）。
  /// - [maxWidth] / [maxHeight] / [imageQuality]: 同样支持批量硬件缩放预处理。
  static Future<IOResult<List<PickedFile>>> pickMultipleImages({
    int? limit,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final xFiles = await _imagePicker.pickMultiImage(
        limit: limit,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (xFiles.isEmpty) {
        return const IOResult.cancelled();
      }

      final list = <PickedFile>[];
      for (final xf in xFiles) {
        list.add(await _fromXFile(xf));
      }
      return IOResult.success(list);
    } on PlatformException catch (e) {
      return _handlePlatformException(e);
    } catch (e) {
      return IOResult.failure(
        errorMessage: 'Failed to pick multiple images: $e',
        rawError: e,
      );
    }
  }

  /// 从系统相册选取单个视频。
  static Future<IOResult<PickedFile>> pickVideo() async {
    try {
      final xFile = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
      );

      if (xFile == null) {
        return const IOResult.cancelled();
      }

      final picked = await _fromXFile(xFile);
      return IOResult.success(picked);
    } on PlatformException catch (e) {
      return _handlePlatformException(e);
    } catch (e) {
      return IOResult.failure(
        errorMessage: 'Failed to pick video: $e',
        rawError: e,
      );
    }
  }

  /// 从系统相册选取多个视频（依赖 FilePicker 的视频模式抹平）。
  ///
  /// - [limit]: 可选最多选几个。
  static Future<IOResult<List<PickedFile>>> pickMultipleVideos({
    int? limit,
  }) async {
    return _pickFilesWithFilter(
      type: FileType.video,
      allowMultiple: true,
      limit: limit,
    );
  }

  // ==========================================================
  // 2. 相机现场拍摄 (仅唤起相机硬件)
  // ==========================================================

  /// 调用系统相机拍摄照片。
  ///
  /// - [preferFrontCamera]: 是否优先使用前置摄像头，默认 false（后置）。
  /// - [maxWidth] / [maxHeight] / [imageQuality]: 拍完后自动等比缩放预处理。
  static Future<IOResult<PickedFile>> pickImageByCamera({
    bool preferFrontCamera = false,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final xFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice:
            preferFrontCamera ? CameraDevice.front : CameraDevice.rear,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (xFile == null) {
        return const IOResult.cancelled();
      }

      final picked = await _fromXFile(xFile);
      return IOResult.success(picked);
    } on PlatformException catch (e) {
      return _handlePlatformException(e);
    } catch (e) {
      return IOResult.failure(
        errorMessage: 'Failed to take photo with camera: $e',
        rawError: e,
      );
    }
  }

  /// 调用系统相机录制视频。
  ///
  /// - [preferFrontCamera]: 是否优先使用前置摄像头，默认 false（后置）。
  /// - [maxDuration]: 可选最长录制时长限制。
  static Future<IOResult<PickedFile>> pickVideoByCamera({
    bool preferFrontCamera = false,
    Duration? maxDuration,
  }) async {
    try {
      final xFile = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        preferredCameraDevice:
            preferFrontCamera ? CameraDevice.front : CameraDevice.rear,
        maxDuration: maxDuration,
      );

      if (xFile == null) {
        return const IOResult.cancelled();
      }

      final picked = await _fromXFile(xFile);
      return IOResult.success(picked);
    } on PlatformException catch (e) {
      return _handlePlatformException(e);
    } catch (e) {
      return IOResult.failure(
        errorMessage: 'Failed to record video with camera: $e',
        rawError: e,
      );
    }
  }

  // ==========================================================
  // 3. 音频与通用文件选取 (系统文件管理器)
  // ==========================================================

  /// 选取单个音频文件。
  ///
  /// - [allowedExtensions]: 可选限定音频后缀名（如 ['mp3', 'm4a', 'wav', 'aac']）。
  static Future<IOResult<PickedFile>> pickAudio({
    List<String>? allowedExtensions,
  }) async {
    final result = await _pickFilesWithFilter(
      type: (allowedExtensions != null && allowedExtensions.isNotEmpty)
          ? FileType.custom
          : FileType.audio,
      allowedExtensions: allowedExtensions,
      allowMultiple: false,
    );

    if (result.isSuccess && result.data != null && result.data!.isNotEmpty) {
      return IOResult.success(result.data!.first);
    }
    if (result.isCancelled) {
      return const IOResult.cancelled();
    }
    return IOResult.failure(
      errorMessage: result.errorMessage ?? 'No audio selected',
      errorType: result.errorType,
      rawError: result.rawError,
    );
  }

  /// 选取多个音频文件。
  static Future<IOResult<List<PickedFile>>> pickMultipleAudios({
    List<String>? allowedExtensions,
  }) async {
    return _pickFilesWithFilter(
      type: (allowedExtensions != null && allowedExtensions.isNotEmpty)
          ? FileType.custom
          : FileType.audio,
      allowedExtensions: allowedExtensions,
      allowMultiple: true,
    );
  }

  /// 选取单个通用文件（如 .pdf, .xlsx, .bak 等）。
  ///
  /// - [allowedExtensions]: 限定后缀名，不填则允许选取任意格式。
  static Future<IOResult<PickedFile>> pickFile({
    List<String>? allowedExtensions,
  }) async {
    final result = await _pickFilesWithFilter(
      type: (allowedExtensions != null && allowedExtensions.isNotEmpty)
          ? FileType.custom
          : FileType.any,
      allowedExtensions: allowedExtensions,
      allowMultiple: false,
    );

    if (result.isSuccess && result.data != null && result.data!.isNotEmpty) {
      return IOResult.success(result.data!.first);
    }
    if (result.isCancelled) {
      return const IOResult.cancelled();
    }
    return IOResult.failure(
      errorMessage: result.errorMessage ?? 'No file selected',
      errorType: result.errorType,
      rawError: result.rawError,
    );
  }

  /// 选取多个通用文件。
  static Future<IOResult<List<PickedFile>>> pickMultipleFiles({
    List<String>? allowedExtensions,
  }) async {
    return _pickFilesWithFilter(
      type: (allowedExtensions != null && allowedExtensions.isNotEmpty)
          ? FileType.custom
          : FileType.any,
      allowedExtensions: allowedExtensions,
      allowMultiple: true,
    );
  }

  /// 选取本地文件夹目录路径。
  ///
  /// 仅桌面端（macOS/Windows/Linux）和 Android 支持；Web 端和 iOS 由于沙盒限制不支持，将返回 null。
  static Future<IOResult<String>> pickDirectory() async {
    try {
      final selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null || selectedDirectory.isEmpty) {
        return const IOResult.cancelled();
      }
      return IOResult.success(selectedDirectory);
    } on PlatformException catch (e) {
      return _handlePlatformException(e);
    } catch (e) {
      return IOResult.failure(
        errorMessage: 'Failed to pick directory: $e',
        rawError: e,
      );
    }
  }

  // ==========================================================
  // 私有辅助方法
  // ==========================================================

  /// 将 ImagePicker 的 XFile 转换为跨平台 PickedFile
  static Future<PickedFile> _fromXFile(XFile xFile) async {
    final length = await xFile.length();
    final ext = _extractExtension(xFile.name);
    final mime = lookupMimeType(xFile.name) ?? xFile.mimeType;

    return PickedFile(
      name: xFile.name,
      size: length,
      extension: ext,
      path: xFile.path.isNotEmpty ? xFile.path : null,
      mimeType: mime,
      bytesLoader: () => xFile.readAsBytes(),
      streamLoader: ([int? start, int? end]) => xFile.openRead(start, end),
    );
  }

  /// 基于 FilePicker 统一选取通用文件
  static Future<IOResult<List<PickedFile>>> _pickFilesWithFilter({
    required FileType type,
    List<String>? allowedExtensions,
    required bool allowMultiple,
    int? limit,
  }) async {
    try {
      // 规范化后缀列表（去除点，小写）
      final normalizedExtensions = allowedExtensions
          ?.map((e) => e.replaceAll('.', '').toLowerCase())
          .toList();

      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: normalizedExtensions,
        allowMultiple: allowMultiple,
        // Web 必须带数据；原生端不强行全量读内存 bytes，采用路径惰性读取
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return const IOResult.cancelled();
      }

      final files = <PickedFile>[];
      for (final pf in result.files) {
        if (limit != null && files.length >= limit) break;

        final ext = pf.extension?.toLowerCase() ?? _extractExtension(pf.name);
        final mime = lookupMimeType(pf.name);

        files.add(
          PickedFile(
            name: pf.name,
            size: pf.size,
            extension: ext,
            path: pf.path,
            mimeType: mime,
            memoryBytes: pf.bytes,
            bytesLoader: pf.bytes != null ? () async => pf.bytes! : null,
            streamLoader: pf.readStream != null
                ? ([int? start, int? end]) {
                    // 若底层提供 readStream 则抹平为 Uint8List
                    return pf.readStream!.map(
                      (c) => c is Uint8List ? c : Uint8List.fromList(c),
                    );
                  }
                : null,
          ),
        );
      }

      return IOResult.success(files);
    } on PlatformException catch (e) {
      return _handlePlatformException(e);
    } catch (e) {
      return IOResult.failure(
        errorMessage: 'Failed to pick files: $e',
        rawError: e,
      );
    }
  }

  static String _extractExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < fileName.length - 1) {
      return fileName.substring(dotIndex + 1).toLowerCase();
    }
    return '';
  }

  static IOResult<T> _handlePlatformException<T>(PlatformException e) {
    final code = e.code.toLowerCase();
    final msg = (e.message ?? '').toLowerCase();

    if (code.contains('permission') ||
        code.contains('access') ||
        msg.contains('permission') ||
        msg.contains('access_denied') ||
        msg.contains('photo_access_denied')) {
      return IOResult.failure(
        errorMessage: 'Permission denied: ${e.message ?? e.code}',
        errorType: IOErrorType.permissionDenied,
        rawError: e,
      );
    }

    return IOResult.failure(
      errorMessage: 'System error: ${e.message ?? e.code}',
      errorType: IOErrorType.unknown,
      rawError: e,
    );
  }
}
