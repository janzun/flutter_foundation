import 'package:core_arch/core_arch.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeReview implements InAppReview {
  bool available = true;
  int requests = 0;
  int storeOpens = 0;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<void> requestReview() async => requests++;

  @override
  Future<void> openStoreListing({String? appStoreId, String? microsoftStoreId}) async =>
      storeOpens++;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeReview fake;
  late DateTime now;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SpUtil.init();
    await SpUtil.clear();
    fake = _FakeReview();
    now = DateTime(2026, 1, 1);
    RateAppUtil.debugClient = fake;
    RateAppUtil.debugNow = () => now;
    RateAppUtil.debugVersion = '1.0.0+1';
  });

  Future<bool> fire() => RateAppUtil.trigger(eventKey: 'export');

  test('stays silent until minEvents and minDays are met', () async {
    expect(await fire(), isFalse); // 1st, day 0
    expect(await fire(), isFalse); // 2nd
    expect(await fire(), isFalse); // 3rd, but day 0 < 2
    now = now.add(const Duration(days: 2));
    expect(await fire(), isTrue);
    expect(fake.requests, 1);
  });

  test('respects cool-down and same-version guard', () async {
    for (var i = 0; i < 3; i++) {
      await fire();
    }
    now = now.add(const Duration(days: 2));
    expect(await fire(), isTrue);

    now = now.add(const Duration(days: 30));
    expect(await fire(), isFalse); // within cool-down

    now = now.add(const Duration(days: 40));
    expect(await fire(), isFalse); // cool-down over, same version

    RateAppUtil.debugVersion = '1.1.0+2';
    expect(await fire(), isTrue);
    expect(fake.requests, 2);
  });

  test('does not consume quota when native review unavailable', () async {
    fake.available = false;
    for (var i = 0; i < 3; i++) {
      await fire();
    }
    now = now.add(const Duration(days: 2));
    expect(await fire(), isFalse);

    fake.available = true;
    expect(await fire(), isTrue);
  });

  test('requestReview falls back to store listing', () async {
    await RateAppUtil.requestReview(appStoreId: '123');
    expect(fake.requests, 1);

    fake.available = false;
    await RateAppUtil.requestReview(appStoreId: '123');
    expect(fake.storeOpens, 1);
  });
}
