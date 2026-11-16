import 'dart:async';
import 'dart:io';

import 'package:core_pay_base/core_pay_base.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 基于 RevenueCat SDK 的跨平台支付实现
class RevenueCatPayService extends BasePayService {
  StreamSubscription<AuthState>? _authSubscription;

  RevenueCatPayService({
    required super.appId,
    required super.supabaseClient,
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

      await _authSubscription?.cancel();
      _authSubscription =
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
  Future<List<ProductInfo>> enrichStoreProducts(
    List<ProductInfo> products,
  ) async {
    if (products.isEmpty || (!Platform.isIOS && !Platform.isAndroid)) {
      return products;
    }

    try {
      final subIds = products
          .where((p) =>
              p.type == ProductType.subscription &&
              p.storeProductId.isNotEmpty)
          .map((p) => p.storeProductId)
          .toSet()
          .toList();

      final nonSubIds = products
          .where((p) =>
              p.type != ProductType.subscription &&
              p.storeProductId.isNotEmpty)
          .map((p) => p.storeProductId)
          .toSet()
          .toList();

      final List<StoreProduct> storeProducts = [];
      if (subIds.isNotEmpty) {
        storeProducts.addAll(await Purchases.getProducts(
          subIds,
          productCategory: ProductCategory.subscription,
        ));
      }
      if (nonSubIds.isNotEmpty) {
        storeProducts.addAll(await Purchases.getProducts(
          nonSubIds,
          productCategory: ProductCategory.nonSubscription,
        ));
      }

      final storeMap = {for (var p in storeProducts) p.identifier: p};

      return products.map((p) {
        final sp = storeMap[p.storeProductId];
        if (sp == null) return p;
        return p.copyWith(
          localizedPrice: sp.priceString,
          price: sp.price,
          currency: sp.currencyCode,
        );
      }).toList();
    } catch (storeError, storeStack) {
      debugPrint(
        'RevenueCatPayService.enrichStoreProducts failed: $storeError\n$storeStack',
      );
      return products;
    }
  }

  @override
  Future<PayResult> purchase(ProductInfo product) async {
    try {
      final category = product.type == ProductType.subscription
          ? ProductCategory.subscription
          : ProductCategory.nonSubscription;

      final storeProducts = await Purchases.getProducts(
        [product.storeProductId],
        productCategory: category,
      );
      if (storeProducts.isEmpty) {
        return PayResult.failed(
          'Product not available in Store: ${product.storeProductId}',
          productCode: product.code,
        );
      }

      final purchaseResult = await Purchases.purchase(
        PurchaseParams.storeProduct(storeProducts.first),
      );

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
      final hasActive = customerInfo.entitlements.active.isNotEmpty ||
          customerInfo.activeSubscriptions.isNotEmpty ||
          customerInfo.nonSubscriptionTransactions.isNotEmpty;

      if (!hasActive) {
        return PayResult.failed('No active purchases found');
      }

      onEntitlementsChanged?.call();

      return PayResult.success(
        rawDetails: <String, dynamic>{
          'activeSubscriptions': customerInfo.activeSubscriptions,
          'activeEntitlements': customerInfo.entitlements.active.keys.toList(),
        },
      );
    } catch (e, stack) {
      debugPrint(
        'RevenueCatPayService.restorePurchases() failed. Error: $e\n$stack',
      );
      return PayResult.failed(e.toString());
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _authSubscription = null;
    super.dispose();
  }
}
