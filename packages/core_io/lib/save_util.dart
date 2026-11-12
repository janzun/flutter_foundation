import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';
import 'models/io_result.dart';

/// 系统文件与媒体保存导出工具门面类。
///
/// 核心特性：
/// 1. 媒体存相册：
///    - 移动端（iOS / Android）存入系统原生相册（通过 [Gal] 实现，Android 10+ 零权限，iOS 仅需 AddOnly 权限）。
///    - 桌面端存入系统 Pictures/Videos 目录，Web 端自动触发下载图片/视频。
/// 2. 通用文件导出：
///    - 移动端/桌面端统一拉起系统原生“另存为 / 存储到文件”面板（由 [FilePicker.platform.saveFile] 驱动），零存储权限。
///    - Web 端自动触发浏览器原生文件下载。
/// 3. 支持 [Uint8List] 内存字节与沙盒物理路径 [sourceFilePath] 两种输出源。
class SaveUtil {
  SaveUtil._();

  // ==========================================================
  // 1. 存入系统相册 (图片 / 视频)
  // ==========================================================

  /// 将内存图片二进制字节存入系统相册。
  ///
  /// - [bytes]: 图片二进制数据。
  /// - [name]: 建议保存的文件名（如 "poster.png"）。
  /// - [albumName]: 可选。系统相册中的自定义相簿名称。
  static Future<IOResult<void>> saveImageBytesToGallery({
    required Uint8List bytes,
    String? name,
    String? albumName,
  }) async {
    try {
      await Gal.putImageBytes(
        bytes,
        name: name ?? 'image',
        album: albumName,
      );
      return const IOResult.success(null);
    } on GalException catch (e) {
      return _handleGalException(e);
    } catch (e) {
      return IOResult.failure(
        errorMessage: 'Failed to save image bytes to gallery: $e',
        rawError: e,
      );
    }
  }

  /// 将本地已有图片文件存入系统相册。
  ///
  /// - [filePath]: 本地图片文件的绝对路径。
  /// - [albumName]: 可选相簿名称。
  static Future<IOResult<void>> saveImageFileToGallery({
    required String filePath,
    String? albumName,
  }) async {
    try {
      if (!kIsWeb && !await File(filePath).exists()) {
        return IOResult.failure(
          errorMessage: 'Source image file does not exist: $filePath',
          errorType: IOErrorType.fileNotFound,
        );
      }

      await Gal.putImage(
        filePath,
        album: albumName,
      );
      return const IOResult.success(null);
    } on GalException catch (e) {
      return _handleGalException(e);
    } catch (e) {
      return IOResult.failure(
        errorMessage: 'Failed to save image file to gallery: $e',
        rawError: e,
      );
    }
  }

  /// 将本地已有视频文件存入系统相册。
  ///
  /// - [filePath]: 本地视频文件的绝对路径。
  /// - [albumName]: 可选相簿名称。
  static Future<IOResult<void>> saveVideoFileToGallery({
    required String filePath,
    String? albumName,
  }) async {
    try {
      if (!kIsWeb && !await File(filePath).exists()) {
        return IOResult.failure(
          errorMessage: 'Source video file does not exist: $filePath',
          errorType: IOErrorType.fileNotFound,
        );
      }

      await Gal.putVideo(
        filePath,
        album: albumName,
      );
      return const IOResult.success(null);
    } on GalException catch (e) {
      return _handleGalException(e);
    } catch (e) {
      return IOResult.failure(
        errorMessage: 'Failed to save video to gallery: $e',
        rawError: e,
      );
    }
  }

  // ==========================================================
  // 2. 导出通用文件 / 音频 (另存为交互面板 / Web 下载)
  // ==========================================================

  /// 将内存字节另存为外部文件（如生成的 PDF、Excel、音频、文本数据）。
  ///
  /// - 移动端（iOS / Android）：唤起系统原生文件保存面板（iOS 存到“文件”App，Android 调起 SAF 另存为）。
  /// - 桌面端（macOS / Windows / Linux）：弹出原生另存为对话框，由用户选择保存目录。
  /// - Web 端：自动触发浏览器下载该文件。
  ///
  /// 返回：最终保存的目标路径（Web 端返回文件名）；若用户主动取消另存为弹窗则返回 [IOStatus.cancelled]。
  static Future<IOResult<String>> saveBytesAsFile({
    required Uint8List bytes,
    required String fileName,
  }) async {
    try {
      final savedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save File',
        fileName: fileName,
        bytes: bytes,
      );

      if (savedPath == null || savedPath.isEmpty) {
        return const IOResult.cancelled();
      }

      return IOResult.success(savedPath);
    } catch (e) {
      return IOResult.failure(
        errorMessage: 'Failed to save bytes as file: $e',
        rawError: e,
      );
    }
  }

  /// 将沙盒内已有的物理文件另存到外部（如生成的 .bak 备份包、导出的报表文件）。
  ///
  /// - [sourceFilePath]: 沙盒内待保存源文件的绝对路径。
  /// - [fileName]: 可选预填文件名。若不填，默认自动截取 [sourceFilePath] 的文件名。
  ///
  /// 返回：最终保存的目标路径；若用户主动取消另存为则返回 [IOStatus.cancelled]。
  static Future<IOResult<String>> saveFile({
    required String sourceFilePath,
    String? fileName,
  }) async {
    try {
      final sourceFile = File(sourceFilePath);
      if (!await sourceFile.exists()) {
        return IOResult.failure(
          errorMessage: 'Source file does not exist: $sourceFilePath',
          errorType: IOErrorType.fileNotFound,
        );
      }

      final resolvedName = fileName ?? _extractFileName(sourceFilePath);
      final bytes = await sourceFile.readAsBytes();

      final savedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save File',
        fileName: resolvedName,
        bytes: bytes,
      );

      if (savedPath == null || savedPath.isEmpty) {
        return const IOResult.cancelled();
      }

      return IOResult.success(savedPath);
    } catch (e) {
      return IOResult.failure(
        errorMessage: 'Failed to save file: $e',
        rawError: e,
      );
    }
  }

  // ==========================================================
  // 私有辅助方法
  // ==========================================================

  static String _extractFileName(String filePath) {
    final separator = filePath.contains('\\') ? '\\' : '/';
    final lastIndex = filePath.lastIndexOf(separator);
    if (lastIndex != -1 && lastIndex < filePath.length - 1) {
      return filePath.substring(lastIndex + 1);
    }
    return filePath;
  }

  static IOResult<T> _handleGalException<T>(GalException e) {
    if (e.type == GalExceptionType.accessDenied) {
      return IOResult.failure(
        errorMessage: 'Photo gallery access was denied by user.',
        errorType: IOErrorType.permissionDenied,
        rawError: e,
      );
    }
    if (e.type == GalExceptionType.notEnoughSpace) {
      return IOResult.failure(
        errorMessage: 'Not enough storage space to save media.',
        errorType: IOErrorType.unknown,
        rawError: e,
      );
    }
    return IOResult.failure(
      errorMessage: 'Gallery save failed: ${e.type.message}',
      errorType: IOErrorType.unknown,
      rawError: e,
    );
  }
}
