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

  group('ApiResponse Tests', () {
    test('ApiResponse parses code 200 as success', () {
      final res = ApiResponse<String>(code: 200, message: 'ok', data: 'data');
      expect(res.isSuccess, isTrue);
      expect(res.data, 'data');
    });

    test('ApiResponse parses code 400 as failure', () {
      final res = ApiResponse<String>(code: 400, message: 'fail');
      expect(res.isSuccess, isFalse);
    });
  });
}
