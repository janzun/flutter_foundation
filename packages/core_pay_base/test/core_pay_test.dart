import 'package:flutter_test/flutter_test.dart';
import 'package:core_pay_base/core_pay_base.dart';

void main() {
  group('Core Pay Models & Contracts Test', () {
    test('ProductInfo serialization & deserialization with standard types and store params', () {
      final json = {
        'code': 'vip_monthly_ios',
        'app_id': 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
        'group': 'subscription',
        'name': '连续包月 VIP',
        'description': '无限转写，加赠 100 积分',
        'price': 4.99,
        'currency': 'USD',
        'localized_price': '\$4.99',
        'type': 'subscription',
        'billing_cycle': 'monthly',
        'platform': 'ios',
        'store': 'app_store',
        'store_product_id': 'com.rtt.vip.monthly',
        'store_params': {'offer_id': 'intro_discount'},
        'reward_tier': 'pro',
        'reward_duration_days': 30,
        'reward_points': 100.0,
        'reward_perks': {'ai_quota': 50},
        'sort_order': 10,
      };

      final product = ProductInfo.fromJson(json);

      expect(product.code, equals('vip_monthly_ios'));
      expect(product.group, equals('subscription'));
      expect(product.type, equals(ProductType.subscription));
      expect(product.billingCycle, equals(BillingCycle.monthly));
      expect(product.store, equals('app_store'));
      expect(product.storeProductId, equals('com.rtt.vip.monthly'));
      expect(product.storeParams['offer_id'], equals('intro_discount'));
      expect(product.rewardTier, equals('pro'));
      expect(product.rewardPoints, equals(100.0));
      expect(product.rewardPerks['ai_quota'], equals(50));

      final serialized = product.toJson();
      expect(serialized['type'], equals('subscription'));
      expect(serialized['billing_cycle'], equals('monthly'));
      expect(serialized['group'], equals('subscription'));
      expect(serialized['store_product_id'], equals('com.rtt.vip.monthly'));
    });

    test('ProductInfo handles consumable and non_consumable types', () {
      final consumable = ProductInfo(
        code: 'points_100',
        appId: 'test_app',
        group: 'points',
        name: '100 积分',
        price: 1.99,
        type: ProductType.consumable,
        platform: 'ios',
        store: 'app_store',
        storeProductId: 'com.rtt.points.100',
      );
      expect(consumable.type, equals(ProductType.consumable));
      expect(consumable.toJson()['type'], equals('consumable'));

      final nonConsumable = ProductInfo(
        code: 'lifetime_vip',
        appId: 'test_app',
        group: 'subscription',
        name: '终身会员',
        price: 89.99,
        type: ProductType.nonConsumable,
        platform: 'ios',
        store: 'app_store',
        storeProductId: 'com.rtt.vip.lifetime',
      );
      expect(nonConsumable.type, equals(ProductType.nonConsumable));
      expect(nonConsumable.toJson()['type'], equals('non_consumable'));
    });

    test('PayResult factory methods', () {
      final success = PayResult.success(
        channelTransactionId: 'tx_123456',
        productCode: 'vip_monthly_ios',
      );
      expect(success.status, equals(PayStatus.success));
      expect(success.channelTransactionId, equals('tx_123456'));
      expect(success.productCode, equals('vip_monthly_ios'));

      final cancelled = PayResult.cancelled(productCode: 'vip_monthly_ios');
      expect(cancelled.status, equals(PayStatus.cancelled));

      final failed = PayResult.failed('Network timeout', productCode: 'vip_monthly_ios');
      expect(failed.status, equals(PayStatus.failed));
      expect(failed.errorMessage, equals('Network timeout'));
    });
  });
}
