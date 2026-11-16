import 'package:core_pay_base/core_pay_base.dart' as base;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'service/revenuecat_pay_service.dart';

export 'package:core_pay_base/core_pay_base.dart' hide Pay;
export 'service/revenuecat_pay_service.dart';

/// RevenueCat 渠道专属统一支付门面（自动注入 [RevenueCatPayService]）
class Pay {
  Pay._();

  static VoidCallback? get onEntitlementsChanged =>
      base.Pay.onEntitlementsChanged;
  static set onEntitlementsChanged(VoidCallback? callback) {
    base.Pay.onEntitlementsChanged = callback;
  }

  /// 初始化全局支付单例（默认自动创建 [RevenueCatPayService]）
  static Future<void> initialize({
    required SupabaseClient client,
    required String appId,
    required String apiKey,
    base.BasePayService? service,
  }) =>
      base.Pay.initialize(
        service: service ??
            RevenueCatPayService(
              appId: appId,
              supabaseClient: client,
            ),
        apiKey: apiKey,
      );

  static bool get isInitialized => base.Pay.isInitialized;

  /// 获取商品列表 (支持按业务分组 [group] 过滤，不传则返回当前平台全部上架商品)
  static Future<List<base.ProductInfo>> fetchProducts({String? group}) =>
      base.Pay.fetchProducts(group: group);

  /// 唤起购买指定商品
  static Future<base.PayResult> purchase(base.ProductInfo product) =>
      base.Pay.purchase(product);

  /// 恢复购买记录
  static Future<base.PayResult> restorePurchases() =>
      base.Pay.restorePurchases();

  static void dispose() => base.Pay.dispose();
}
