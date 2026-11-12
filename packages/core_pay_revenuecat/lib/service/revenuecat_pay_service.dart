import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:core_pay_base/core_pay_base.dart';

/// 基于 RevenueCat SDK 的跨平台支付实现
class RevenueCatPayService extends BasePayService {
  final SupabaseClient supabaseClient;

  RevenueCatPayService({
    required super.appId,
    required this.supabaseClient,
  });

  @override
  Future<void> initialize({
    required String apiKey,
  }) async {
    try {
      final configuration = PurchasesConfiguration(apiKey);
      final currentUserId = supabaseClient.auth.currentUser?.id;
      if (currentUserId != null && currentUserId.isNotEmpty) {
        configuration.appUserID = currentUserId;
      }
      await Purchases.configure(configuration);

      // 监听用户认证状态变动，自动与 RevenueCat 绑定
      supabaseClient.auth.onAuthStateChange.listen((data) async {
        final uid = data.session?.user.id;
        if (uid != null && uid.isNotEmpty) {
          try {
            await Purchases.logIn(uid);
          } catch (err, st) {
            debugPrint('RevenueCat Purchases.logIn($uid) failed: $err\n$st');
          }
        }
      });

      // 监听 RevenueCat 侧状态变更 (续费/降级/取消)，触发资产变动回调
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        onEntitlementsChanged?.call();
      });
    } catch (e, stack) {
      debugPrint(
        'RevenueCatPayService.initialize(apiKey: $apiKey) failed. Error: $e\n$stack',
      );
      rethrow;
    }
  }

  @override
  Future<List<ProductInfo>> fetchProducts({String? group}) async {
    try {
      final currentPlatform = _currentPlatform();

      // 1. 构建查询 common.products 过滤条件
      var query = supabaseClient
          .from('products')
          .select()
          .eq('app_id', appId)
          .eq('platform', currentPlatform)
          .eq('is_active', true);

      if (group != null && group.isNotEmpty) {
        query = query.eq('group', group);
      }

      final response = await query.order('sort_order', ascending: true);
      final List<dynamic> rawList = response as List<dynamic>;
      final List<ProductInfo> products = [];
      final List<String> storeProductIds = [];

      for (final item in rawList) {
        final map = Map<String, dynamic>.from(item as Map);
        final storeId = map['store_product_id'] as String? ?? '';
        if (storeId.isNotEmpty) {
          storeProductIds.add(storeId);
        }

        final productTypeStr = map['type'] as String? ?? 'subscription';
        final billingCycleStr = map['billing_cycle'] as String? ?? 'one_off';

        products.add(ProductInfo(
          code: map['code'] as String,
          appId: map['app_id'] as String,
          group: map['group'] as String? ?? 'default',
          name: map['name'] as String? ?? '',
          description: map['description'] as String? ?? '',
          price: (map['price'] as num?)?.toDouble() ?? 0.0,
          currency: map['currency'] as String? ?? 'USD',
          type: _parseProductType(productTypeStr),
          billingCycle: _parseBillingCycle(billingCycleStr),
          platform: map['platform'] as String? ?? currentPlatform,
          store: map['store'] as String? ?? 'app_store',
          storeProductId: storeId,
          storeParams: Map<String, dynamic>.from(
              map['store_params'] as Map? ?? <String, dynamic>{}),
          rewardTier: map['reward_tier'] as String?,
          rewardDurationDays: map['reward_duration_days'] as int? ?? 0,
          rewardPoints: (map['reward_points'] as num?)?.toDouble() ?? 0.0,
          rewardPerks: Map<String, dynamic>.from(
              map['reward_perks'] as Map? ?? <String, dynamic>{}),
          sortOrder: map['sort_order'] as int? ?? 0,
        ));
      }

      // 2. 在移动端向应用商店查询本地化货币格式价格进行补齐
      if ((Platform.isIOS || Platform.isAndroid) &&
          storeProductIds.isNotEmpty) {
        try {
          final storeProducts =
              await Purchases.getProducts(storeProductIds);
          final storeMap = {for (var p in storeProducts) p.identifier: p};

          return products.map((p) {
            if (storeMap.containsKey(p.storeProductId)) {
              final sp = storeMap[p.storeProductId]!;
              return p.copyWith(
                localizedPrice: sp.priceString,
                price: sp.price,
                currency: sp.currencyCode,
              );
            }
            return p;
          }).toList();
        } catch (storeError, storeStack) {
          debugPrint(
            'RevenueCatPayService.fetchProducts store query failed: $storeError\n$storeStack',
          );
        }
      }

      return products;
    } catch (e, stack) {
      debugPrint(
        'RevenueCatPayService.fetchProducts(appId: $appId, group: $group) failed. Error: $e\n$stack',
      );
      return [];
    }
  }

  @override
  Future<PayResult> purchase(ProductInfo product) async {
    try {
      final storeProducts = await Purchases.getProducts([product.storeProductId]);
      if (storeProducts.isEmpty) {
        return PayResult.failed(
          'Product not available in Store: ${product.storeProductId}',
          productCode: product.code,
        );
      }

      final storeProduct = storeProducts.first;
      final purchaseResult = await Purchases.purchase(
        PurchaseParams.storeProduct(storeProduct),
      );

      // 支付成功，立即触发资产可能变动的全局通知
      onEntitlementsChanged?.call();

      return PayResult.success(
        productCode: product.code,
        channelTransactionId:
            purchaseResult.storeTransaction.transactionIdentifier,
      );
    } on PlatformException catch (pe) {
      final errorCode = PurchasesErrorHelper.getErrorCode(pe);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        return PayResult.cancelled(productCode: product.code);
      }
      return PayResult.failed(
        pe.message ?? 'Purchase failed: ${errorCode.name}',
        productCode: product.code,
      );
    } catch (e, stack) {
      debugPrint(
        'RevenueCatPayService.purchase(product: ${product.code}) failed. Error: $e\n$stack',
      );
      return PayResult.failed(e.toString(), productCode: product.code);
    }
  }

  @override
  Future<PayResult> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      // 恢复成功，触发资产变动通知
      onEntitlementsChanged?.call();

      return PayResult.success(
        rawDetails: <String, dynamic>{
          'activeSubscriptions': customerInfo.activeSubscriptions,
        },
      );
    } catch (e, stack) {
      debugPrint(
        'RevenueCatPayService.restorePurchases() failed. Error: $e\n$stack',
      );
      return PayResult.failed(e.toString());
    }
  }

  String _currentPlatform() {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    return 'unknown';
  }

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
