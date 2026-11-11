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
