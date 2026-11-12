import 'dart:io';
import 'dart:typed_data';
import 'package:core_io/core_io.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IOResult Tests', () {
    test('IOResult.success returns correct state and data', () {
      const result = IOResult<String>.success('saved_path.png');
      expect(result.isSuccess, isTrue);
      expect(result.isCancelled, isFalse);
      expect(result.isFailure, isFalse);
      expect(result.data, equals('saved_path.png'));
      expect(result.status, equals(IOStatus.success));
    });

    test('IOResult.cancelled behaves correctly', () {
      const result = IOResult<String>.cancelled();
      expect(result.isSuccess, isFalse);
      expect(result.isCancelled, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.data, isNull);
      expect(result.status, equals(IOStatus.cancelled));
    });

    test('IOResult.failure identifies permission denial correctly', () {
      const result = IOResult<String>.failure(
        errorMessage: 'User denied photo library access',
        errorType: IOErrorType.permissionDenied,
      );
      expect(result.isSuccess, isFalse);
      expect(result.isCancelled, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.isPermissionDenied, isTrue);
      expect(result.errorType, equals(IOErrorType.permissionDenied));
    });
  });

  group('PickedFile Tests', () {
    test('readableSize formats bytes correctly across units', () {
      final fileB = PickedFile(name: 'a.txt', size: 512, extension: 'txt');
      expect(fileB.readableSize, equals('512 B'));

      final fileKB = PickedFile(
        name: 'b.png',
        size: 1536, // 1.5 KB
        extension: 'png',
      );
      expect(fileKB.readableSize, equals('1.5 KB'));

      final fileMB = PickedFile(
        name: 'c.mp4',
        size: 2621440, // 2.5 MB
        extension: 'mp4',
      );
      expect(fileMB.readableSize, equals('2.5 MB'));
    });

    test('readBytes and openRead work seamlessly with memoryBytes', () async {
      final rawData = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]);
      final picked = PickedFile(
        name: 'memory.bin',
        size: rawData.length,
        extension: 'bin',
        memoryBytes: rawData,
      );

      final bytes = await picked.readBytes();
      expect(bytes, equals(rawData));

      final streamChunks = await picked.openRead().toList();
      expect(streamChunks.length, equals(1));
      expect(streamChunks.first, equals(rawData));

      // Range read
      final partialChunks = await picked.openRead(2, 5).toList();
      expect(partialChunks.first, equals(Uint8List.fromList([3, 4, 5])));
    });

    test('copyToPath writes file correctly to destination', () async {
      final tempDir = await Directory.systemTemp.createTemp('core_io_test_');
      final targetPath = '${tempDir.path}/sub/test_copied.bin';

      final rawData = Uint8List.fromList([10, 20, 30, 40]);
      final picked = PickedFile(
        name: 'source.bin',
        size: rawData.length,
        extension: 'bin',
        memoryBytes: rawData,
      );

      final savedPath = await picked.copyToPath(targetPath);
      expect(savedPath, equals(targetPath));

      final savedFile = File(savedPath);
      expect(await savedFile.exists(), isTrue);
      expect(await savedFile.readAsBytes(), equals(rawData));

      await tempDir.delete(recursive: true);
    });
  });
}
