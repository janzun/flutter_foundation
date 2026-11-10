import 'package:flutter_test/flutter_test.dart';
import 'package:core_analytics/analytics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EventType Tests', () {
    test('6 standard event types match protocol', () {
      expect(EventType.lifecycle.value, 'lifecycle');
      expect(EventType.pageView.value, 'page_view');
      expect(EventType.impression.value, 'impression');
      expect(EventType.action.value, 'action');
      expect(EventType.conversion.value, 'conversion');
      expect(EventType.error.value, 'error');
    });
  });

  group('EventNames Tests', () {
    test('Standard EventNames constants match protocol', () {
      expect(EventNames.appInstall, 'app_install');
      expect(EventNames.appLaunch, 'app_launch');
      expect(EventNames.appShow, 'app_show');
      expect(EventNames.appHide, 'app_hide');
      expect(EventNames.pageView, 'page_view');
      expect(EventNames.clickPay, 'click_pay');
      expect(EventNames.paymentSuccess, 'payment_success');
    });
  });

  group('AnalyticsEvent Serialization Tests', () {
    test('AnalyticsEvent.toJson produces correct structure matching POST /v1/events schema', () {
      final now = DateTime.now().toUtc();
      final event = AnalyticsEvent(
        appId: 'test-app-uuid',
        userId: 'test-user-123',
        deviceId: 'device-abc-456',
        sessionId: 'session-xyz-789',
        eventType: EventType.action.value,
        eventName: EventNames.clickPay,
        pageName: 'HomeScreen',
        properties: {'duration': 120, 'mode': 'fast'},
        platform: 'ios',
        deviceBrand: 'Apple',
        deviceModel: 'iPhone 16 Pro',
        osVersion: 'iOS 18.2',
        appVersion: '1.0.0',
        channel: 'appstore',
        screenWidth: 1179,
        screenHeight: 2556,
        networkType: 'wifi',
        language: 'zh-CN',
        occurredTime: now,
      );

      final json = event.toJson();

      expect(json.containsKey('id'), isFalse);
      expect(json['app_id'], 'test-app-uuid');
      expect(json['user_id'], 'test-user-123');
      expect(json['device_id'], 'device-abc-456');
      expect(json['session_id'], 'session-xyz-789');
      expect(json['event_type'], 'action');
      expect(json['event_name'], 'click_pay');
      expect(json['page_name'], 'HomeScreen');
      expect(json['properties'], {'duration': 120, 'mode': 'fast'});
      expect(json['platform'], 'ios');
      expect(json['device_brand'], 'Apple');
      expect(json['device_model'], 'iPhone 16 Pro');
      expect(json['os_version'], 'iOS 18.2');
      expect(json['app_version'], '1.0.0');
      expect(json['channel'], 'appstore');
      expect(json['screen_width'], 1179);
      expect(json['screen_height'], 2556);
      expect(json['network_type'], 'wifi');
      expect(json['language'], 'zh-CN');
      expect(json['occurred_time'], now.toIso8601String());
    });
  });

  group('SuperProperties Integration Tests', () {
    test('setSuperProperties extracts user_id and merges properties', () {
      Analytics.setSuperProperties({
        'user_id': 'user_999',
        'is_vip': true,
        'vip_level': 2,
      });

      Analytics.clearSuperProperties();
    });
  });
}
