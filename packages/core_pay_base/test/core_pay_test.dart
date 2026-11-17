import 'package:flutter_test/flutter_test.dart';
import 'package:core_pay_base/core_pay_base.dart';

void main() {
  group('Core Pay Models & Contracts Test', () {
    test('ProductInfo serialization & deserialization with minimal contract', () {
      final json = {
        'code': 'vip_monthly_ios',
        'group': 'subscription',
        'type': 'subscription',
        'billing_cycle': 'monthly',
        'store_product_id': 'com.rtt.vip.monthly',
        'store_params': {'offer_id': 'intro_discount'},
        'localized_price': '\$4.99',
        'price': 4.99,
        'currency': 'USD',
      };

      final product = ProductInfo.fromJson(json);

      expect(product.code, equals('vip_monthly_ios'));
      expect(product.group, equals('subscription'));
      expect(product.type, equals(ProductType.subscription));
      expect(product.billingCycle, equals(BillingCycle.monthly));
      expect(product.storeProductId, equals('com.rtt.vip.monthly'));
      expect(product.storeParams['offer_id'], equals('intro_discount'));
      expect(product.localizedPrice, equals('\$4.99'));
      expect(product.price, equals(4.99));
      expect(product.currency, equals('USD'));

      final serialized = product.toJson();
      expect(serialized['type'], equals('subscription'));
      expect(serialized['billing_cycle'], equals('monthly'));
      expect(serialized['group'], equals('subscription'));
      expect(serialized['store_product_id'], equals('com.rtt.vip.monthly'));
    });

    test('ProductInfo handles consumable and non_consumable types', () {
      const consumable = ProductInfo(
        code: 'points_100',
        group: 'points',
        type: ProductType.consumable,
        storeProductId: 'com.rtt.points.100',
      );
      expect(consumable.type, equals(ProductType.consumable));
      expect(consumable.toJson()['type'], equals('consumable'));

      const nonConsumable = ProductInfo(
        code: 'lifetime_vip',
        group: 'subscription',
        type: ProductType.nonConsumable,
        billingCycle: BillingCycle.lifetime,
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
