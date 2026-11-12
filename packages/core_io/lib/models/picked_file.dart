import 'dart:io';
import 'package:flutter/foundation.dart';

/// 抹平 6 端物理差异的已选文件实体。
///
/// 核心特性：
/// 1. 屏蔽 Web 端 `path == null` 的空安全陷阱。
/// 2. 原生端（Native）优先保持惰性读取，不将全量字节强行加载入内存，避免大视频和大文件 OOM。
/// 3. 支持小文件快速全量读取 [readBytes]，大文件/分块上传流式读取 [openRead]。
class PickedFile {
  /// 文件名（包含扩展名，如 "avatar.png", "sample.mp4"）。
  final String name;

  /// 文件大小（单位：字节 Bytes）。
  final int size;

  /// 文件扩展名（已转换为小写，且不包含开头的点，如 "png", "mp4", "pdf"）。
  final String extension;

  /// 本地物理绝对路径。
  ///
  /// - 移动端 / 桌面端：有有效绝对路径。
  /// - Web 端：浏览器沙盒安全限制，恒为 null。
  final String? path;

  /// MIME 类型（如 "image/png", "video/mp4"），可能为 null。
  final String? mimeType;

  /// Web 端或内存来源预载的二进制字节（原生端按需惰性读取，此处通常为 null）。
  final Uint8List? _memoryBytes;

  /// 惰性读取字节的回调（若由上层提供）。
  final Future<Uint8List> Function()? _bytesLoader;

  /// 惰性流读取回调。
  final Stream<Uint8List> Function([int? start, int? end])? _streamLoader;

  PickedFile({
    required this.name,
    required this.size,
    required this.extension,
    this.path,
    this.mimeType,
    Uint8List? memoryBytes,
    Future<Uint8List> Function()? bytesLoader,
    Stream<Uint8List> Function([int? start, int? end])? streamLoader,
  })  : _memoryBytes = memoryBytes,
        _bytesLoader = bytesLoader,
        _streamLoader = streamLoader;

  /// 当前是否运行在 Web 平台。
  bool get isWeb => kIsWeb || path == null;

  /// 人类可读格式的大小字符串（如 "1.2 MB", "450 KB", "32 B"）。
  String get readableSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// 统一读取全量字节流。
  ///
  /// - Web 端：直接返回内存字节。
  /// - 原生端：按需从物理路径读取。
  Future<Uint8List> readBytes() async {
    if (_memoryBytes != null) return _memoryBytes;
    if (_bytesLoader != null) return await _bytesLoader();
    if (path != null) {
      return await File(path!).readAsBytes();
    }
    throw StateError('Cannot read bytes: no path or loader available for $name');
  }

  /// 流式按分块读取文件内容（直接返回强类型的 [Uint8List] 分块）。
  ///
  /// 专为大体积视频、音频或备份包设计，防止一次性将几百兆文件读进内存导致 OOM。
  ///
  /// - [start]: 可选起始字节偏移量。
  /// - [end]: 可选结束字节偏移量。
  Stream<Uint8List> openRead([int? start, int? end]) {
    if (_streamLoader != null) {
      return _streamLoader(start, end);
    }
    if (path != null) {
      return File(path!).openRead(start, end).map(
            (chunk) => chunk is Uint8List ? chunk : Uint8List.fromList(chunk),
          );
    }
    if (_memoryBytes != null) {
      final sub = (start != null || end != null)
          ? _memoryBytes.sublist(start ?? 0, end ?? _memoryBytes.length)
          : _memoryBytes;
      return Stream.value(sub);
    }
    throw StateError('Cannot open stream: no stream source available for $name');
  }

  /// 将选取的外部文件拷贝到应用沙盒指定目标路径。
  ///
  /// - 原生端：执行底层原子文件复制。
  /// - Web 端：将内存数据写出（若在混合容器下）。
  /// 返回保存后的沙盒绝对路径。
  Future<String> copyToPath(String targetFilePath) async {
    final target = File(targetFilePath);
    await target.parent.create(recursive: true);

    if (path != null) {
      final copied = await File(path!).copy(targetFilePath);
      return copied.path;
    } else {
      final bytes = await readBytes();
      final written = await target.writeAsBytes(bytes, flush: true);
      return written.path;
    }
  }

  @override
  String toString() =>
      'PickedFile(name: $name, size: $readableSize, extension: $extension, path: $path)';
}
