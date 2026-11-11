import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:core_arch/core_arch.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Result & ViewState Tests', () {
    test('Ok result behaves as expected', () {
      const result = Result.ok('hello');
      expect(result.isOk, isTrue);
      expect(result.isErr, isFalse);
      expect(result.valueOrNull, 'hello');
      expect(result.errorOrNull, isNull);

      final mapped = result.map((v) => v.length);
      expect(mapped.valueOrNull, 5);
    });

    test('Err result behaves as expected', () {
      const err = Result<String>.err(
        AppException(code: 'TEST_ERR', message: 'Test message'),
      );
      expect(err.isOk, isFalse);
      expect(err.isErr, isTrue);
      expect(err.valueOrNull, isNull);
      expect(err.errorOrNull?.code, 'TEST_ERR');
    });

    test('ViewState getters work properly', () {
      expect(ViewState.loading.isLoading, isTrue);
      expect(ViewState.empty.isEmpty, isTrue);
      expect(ViewState.error.isError, isTrue);
      expect(ViewState.success.isSuccess, isTrue);
      expect(ViewState.idle.isIdle, isTrue);
    });
  });

  group('DioClient & Guard Tests', () {
    test('DioClient.guard catches normal execution and returns Ok', () async {
      final res = await DioClient.guard<String>(() async {
        return 'success_data';
      });

      expect(res.isOk, isTrue);
      expect(res.valueOrNull, 'success_data');
    });

    test('DioClient.guard catches AppException and returns Err', () async {
      final res = await DioClient.guard<String>(() async {
        throw const AppException(code: 'CUSTOM_ERR', message: 'Custom Fail');
      });

      expect(res.isErr, isTrue);
      expect(res.errorOrNull?.code, 'CUSTOM_ERR');
    });
  });

  group('FileUtil Tests', () {
    test('writeString and readString works atomically', () async {
      final tempDir = Directory.systemTemp.createTempSync('file_util_test_');
      final testFilePath = '${tempDir.path}/sub_dir/test.txt';

      // 1. 自动递归建目录 + 原子写入
      final file = await FileUtil.writeString(testFilePath, 'Hello FileUtil');
      expect(file.existsSync(), isTrue);
      expect(FileUtil.exists(testFilePath), isTrue);

      // 2. 读取文本
      final content = await FileUtil.readString(testFilePath);
      expect(content, 'Hello FileUtil');

      // 3. 读取不存在文件安全返回 null
      final nonExist = await FileUtil.readString('${tempDir.path}/none.txt');
      expect(nonExist, isNull);

      // 4. 清理
      await FileUtil.deleteDir(tempDir.path);
    });

    test('zip and unzip works seamlessly', () async {
      final tempDir = Directory.systemTemp.createTempSync('zip_test_');
      await FileUtil.writeString('${tempDir.path}/f1.txt', 'Content 1');
      await FileUtil.writeString('${tempDir.path}/sub/f2.txt', 'Content 2');

      final zipPath = '${tempDir.path}/test_archive.zip';
      final zipFile = await FileUtil.zipDirectory(
        sourceDir: tempDir,
        targetZipPath: zipPath,
      );
      expect(zipFile.existsSync(), isTrue);

      final extractDir = '${tempDir.path}/extracted';
      await FileUtil.unzipFile(zipFile: zipFile, targetDirPath: extractDir);
      expect(FileUtil.exists('$extractDir/f1.txt'), isTrue);
      expect(FileUtil.exists('$extractDir/sub/f2.txt'), isTrue);

      await FileUtil.deleteDir(tempDir.path);
    });
  });

  group('BackupUtil Tests', () {
    test('createBackup and extractBackup completes full roundtrip', () async {
      final tempDir = Directory.systemTemp.createTempSync('backup_test_');
      final dbFakeFile = await FileUtil.writeString('${tempDir.path}/fake_db.bin', 'ISAR_DB_DATA');
      final attachDir = Directory('${tempDir.path}/photos');
      await attachDir.create();
      await FileUtil.writeString('${attachDir.path}/photo1.jpg', 'PHOTO_BYTES');

      final backupFilePath = '${tempDir.path}/my_backup.bak';

      // 1. 创建聚合备份
      final createResult = await BackupUtil.createBackup(
        targetBackupFilePath: backupFilePath,
        databaseFile: dbFakeFile,
        attachmentDirs: [attachDir],
        kvData: {'theme': 'dark', 'version': 1},
        schemaVersion: 1,
        appVersion: '1.0.0',
      );

      expect(createResult.isOk, isTrue);
      final backupFile = createResult.valueOrNull!;
      expect(backupFile.existsSync(), isTrue);

      // 2. 解包提炼
      final extractResult = await BackupUtil.extractBackup(
        backupFile: backupFile,
        targetExtractDir: '${tempDir.path}/extracted_data',
        expectedMaxSchemaVersion: 2,
      );

      expect(extractResult.isOk, isTrue);
      final extracted = extractResult.valueOrNull!;
      expect(extracted.manifest.schemaVersion, 1);
      expect(extracted.manifest.appVersion, '1.0.0');
      expect(extracted.databaseFile, isNotNull);
      expect(await extracted.databaseFile!.readAsString(), 'ISAR_DB_DATA');
      expect(extracted.attachmentsDir, isNotNull);
      expect(extracted.kvData?['theme'], 'dark');

      await FileUtil.deleteDir(tempDir.path);
    });
  });

  group('EventBus Tests', () {
    test('EventBus emits and listens correctly', () async {
      final events = <String>[];
      final sub = EventBus.on<String>().listen((event) {
        events.add(event);
      });

      EventBus.emit('event_1');
      EventBus.emit('event_2');

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(events, equals(['event_1', 'event_2']));
      await sub.cancel();
    });
  });

  group('Extensions Tests', () {
    test('DateExtension formats correctly', () {
      final date = DateTime(2026, 11, 10, 15, 30);
      expect(date.toFormattedDate(pattern: 'yyyy-MM-dd'), '2026-11-10');
      expect(date.toUtcIso8601String().contains('2026-11-10'), isTrue);
    });

    test('NumExtension formats currency and bytes correctly', () {
      expect(1299.99.toCurrency(symbol: '\$'), '\$1,299.99');
      expect(1024.toByteSizeString(), '1.0 KB');
      expect((1024 * 1024 * 2.5).toByteSizeString(), '2.5 MB');
    });

    test('StringExtension masks email and phone correctly', () {
      expect('alex.smith@gmail.com'.isEmail, isTrue);
      expect('invalid-email'.isEmail, isFalse);
      expect('alex.smith@gmail.com'.maskEmail(), 'al***h@gmail.com');
      expect('+16501234567'.maskPhone(), '+165***4567');
      expect('https://google.com'.isUrl, isTrue);
    });
  });
}
