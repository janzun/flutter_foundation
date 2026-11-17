import 'package:flutter_test/flutter_test.dart';
import 'package:core_auth_base/auth.dart';

void main() {
  group('AuthResult & Models Test', () {
    test('AuthResult.success returns isSuccess == true', () {
      final res = AuthResult.success('test_data');
      expect(res.isSuccess, isTrue);
      expect(res.isFailure, isFalse);
      expect(res.code, equals(AuthErrorCode.success));
      expect(res.data, equals('test_data'));
    });

    test('AuthResult.failure returns isFailure == true and error code', () {
      final res = AuthResult<String>.failure(
        AuthErrorCode.unauthorized,
        '未登录',
      );
      expect(res.isSuccess, isFalse);
      expect(res.isFailure, isTrue);
      expect(res.code, equals(20001));
      expect(res.data, isNull);
    });

    test('UserData deserialization from minimal server JSON with entitlements', () {
      final mockJson = {
        'id': '7c9e6679-7425-40de-944b-e07fc1f90ae7',
        'is_anonymous': false,
        'is_new_user': true,
        'email': 'alex@example.com',
        'display_name': 'alex',
        'avatar_url': null,
        'entitlements': [
          {
            'type': 'membership',
            'code': 'pro',
            'status': 'active',
            'tier': 'pro',
            'billing_cycle': 'monthly',
            'balance': 0.0,
            'expire_at':
                DateTime.now().add(const Duration(days: 30)).toIso8601String(),
          },
          {
            'type': 'points',
            'code': 'standard_point',
            'status': 'active',
            'balance': 100.0,
          },
          {
            'type': 'quota',
            'code': 'ai_summary',
            'status': 'active',
            'balance': 5.0,
          }
        ],
      };

      final user = UserData.fromJson(mockJson);
      expect(user.id, equals('7c9e6679-7425-40de-944b-e07fc1f90ae7'));
      expect(user.displayName, equals('alex'));
      expect(user.isNewUser, isTrue);
      expect(user.isVip, isTrue);
      expect(user.vipTier, equals('pro'));
      expect(user.pointsBalance, equals(100));
      expect(user.getBalance('ai_summary'), equals(5.0));
      expect(user.entitlements.length, equals(3));
    });

    test('UserData handles empty entitlements safely', () {
      final mockJson = {
        'id': '7c9e6679-7425-40de-944b-e07fc1f90ae7',
        'is_anonymous': true,
        'is_new_user': false,
        'display_name': '访客',
        'entitlements': [],
      };

      final user = UserData.fromJson(mockJson);
      expect(user.isVip, isFalse);
      expect(user.vipTier, isNull);
      expect(user.pointsBalance, equals(0));
      expect(user.entitlements, isEmpty);
    });
  });
}
