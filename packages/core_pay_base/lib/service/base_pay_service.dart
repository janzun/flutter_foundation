import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/pay_result.dart';
import '../model/product_info.dart';

/// 跨端通用支付核心服务抽象契约 (专注商品目录拉取、交易生命周期与商店交互)
abstract class BasePayService {
  /// 应用标识 UUID
  final String appId;

  /// Supabase 客户端 (用于从 common / common_test 拉取商品目录)
  final SupabaseClient supabaseClient;

  /// 是否使用测试环境 (`common_test` Schema)，默认取 [kDebugMode]
  final bool debug;

  /// 当前激活的数据库 Schema
  String get schema => debug ? 'common_test' : 'common';

  /// 资产可能发生变动的全局回调 (购买成功/恢复成功/渠道后台推送)
  VoidCallback? onEntitlementsChanged;

  BasePayService({
    required this.appId,
    required this.supabaseClient,
    this.debug = kDebugMode,
  });

  /// 初始化支付 SDK 环境与渠道凭证
  Future<void> initialize({
    required String apiKey,
  });

  /// 获取商品配置列表 (支持按业务分组 [group] 过滤，不传则返回当前平台全部上架商品)
  ///
  /// 采用模板方法：
  /// 1. 统一从 `common.products` 白名单拉取基础商品信息（不拉取服务端发权字段）；
  /// 2. 调用 [enrichStoreProducts] 钩子由具体渠道包补齐商店本地化价格。
  Future<List<ProductInfo>> fetchProducts({String? group}) async {
    try {
      final platform = currentPlatform;
      var query = supabaseClient
          .schema(schema)
          .from('products')
          .select(
            'code, group, type, billing_cycle, store_product_id, store_params',
          )
          .eq('app_id', appId)
          .eq('platform', platform)
          .eq('is_active', true);

      if (group != null && group.isNotEmpty) {
        query = query.eq('group', group);
      }

      final response = await query.order('sort_order', ascending: true);
      final List<dynamic> rawList = response as List<dynamic>;
      final List<ProductInfo> products = [];

      for (final item in rawList) {
        final map = Map<String, dynamic>.from(item as Map);
        products.add(ProductInfo(
          code: map['code'] as String,
          group: map['group'] as String? ?? 'default',
          type: _parseProductType(map['type'] as String? ?? 'subscription'),
          billingCycle:
              _parseBillingCycle(map['billing_cycle'] as String? ?? 'one_off'),
          storeProductId: map['store_product_id'] as String? ?? '',
          storeParams: Map<String, dynamic>.from(
            map['store_params'] as Map? ?? <String, dynamic>{},
          ),
        ));
      }

      return await enrichStoreProducts(products);
    } catch (e, stack) {
      debugPrint(
        'BasePayService.fetchProducts(appId: $appId, group: $group) failed. Error: $e\n$stack',
      );
      return [];
    }
  }

  /// 渠道扩展钩子：用于向应用商店（App Store / Google Play）补齐实时本地化价格
  @protected
  Future<List<ProductInfo>> enrichStoreProducts(List<ProductInfo> products) async =>
      products;

  /// 当前运行平台标识
  @protected
  String get currentPlatform {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    return 'unknown';
  }

  /// 唤起购买指定商品
  Future<PayResult> purchase(ProductInfo product);

  /// 恢复购买记录 (针对 iOS/Android 换机或重新安装)
  Future<PayResult> restorePurchases();

  /// 释放资源
  @mustCallSuper
  void dispose() {}

  ProductType _parseProductType(String str) {
    switch (str) {
      case 'consumable':
        return ProductType.consumable;
      case 'non_consumable':
        return ProductType.nonConsumable;
      case 'subscription':
      default:
        return ProductType.subscription;
    }
  }

  BillingCycle _parseBillingCycle(String str) {
    switch (str) {
      case 'monthly':
        return BillingCycle.monthly;
      case 'annual':
        return BillingCycle.annual;
      case 'lifetime':
        return BillingCycle.lifetime;
      case 'one_off':
      default:
        return BillingCycle.oneOff;
    }
  }
}
