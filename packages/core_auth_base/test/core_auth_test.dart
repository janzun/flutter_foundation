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

    test('UserData deserialization from server JSON with entitlements', () {
      final mockJson = {
        'id': '7c9e6679-7425-40de-944b-e07fc1f90ae7',
        'app_id': 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
        'supabase_uid': '9f3537f2-9244-4ddf-b45a-28a6b6b09962',
        'is_anonymous': false,
        'auth_provider': 'apple',
        'is_new_user': true,
        'email': 'alex@example.com',
        'phone': null,
        'display_name': 'alex',
        'avatar_url': null,
        'risk_level': 'normal',
        'last_login_at': '2026-08-31T06:50:00.000Z',
        'created_at': '2026-08-31T06:50:00.000Z',
        'entitlements': [
          {
            'id': 'ent_1',
            'type': 'membership',
            'code': 'pro',
            'status': 'active',
            'tier': 'pro',
            'billing_cycle': 'monthly',
            'balance': 0.0,
            'expire_at':
                DateTime.now().add(const Duration(days: 30)).toIso8601String(),
            'allowed_platforms': ['android', 'ios'],
          },
          {
            'id': 'ent_2',
            'type': 'points',
            'code': 'standard_point',
            'status': 'active',
            'balance': 100.0,
          },
          {
            'id': 'ent_3',
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
        'app_id': 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
        'supabase_uid': '9f3537f2-9244-4ddf-b45a-28a6b6b09962',
        'is_anonymous': true,
        'auth_provider': 'anonymous',
        'is_new_user': false,
        'display_name': '访客',
        'created_at': '2026-08-31T06:50:00.000Z',
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
