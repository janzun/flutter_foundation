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
    super.debug = kDebugMode,
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
      await Purchases.setAttributes(<String, String>{
        r'$app_id': appId,
        r'$debug': debug.toString(),
      });

      await _authSubscription?.cancel();
      _authSubscription =
          supabaseClient.auth.onAuthStateChange.listen((data) async {
        if (data.event == AuthChangeEvent.signedOut) {
          try {
            if (!await Purchases.isAnonymous) {
              await Purchases.logOut();
            }
          } catch (err, st) {
            debugPrint('RevenueCat Purchases.logOut() failed: $err\n$st');
          }
          return;
        }
        final uid = data.session?.user.id;
        if (uid != null && uid.isNotEmpty) {
          try {
            await Purchases.logIn(uid);
            await Purchases.setAttributes(<String, String>{
              r'$app_id': appId,
              r'$debug': debug.toString(),
            });
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

  /// 确保延迟匿名登录后，RevenueCat 的 appUserID 与当前 supabase_uid 严格一致
  Future<void> _ensureRevenueCatUserSynced() async {
    final uid = supabaseClient.auth.currentUser?.id;
    if (uid != null && uid.isNotEmpty) {
      final currentRcId = await Purchases.appUserID;
      if (currentRcId != uid) {
        await Purchases.logIn(uid);
        await Purchases.setAttributes(<String, String>{
          r'$app_id': appId,
          r'$debug': debug.toString(),
        });
      }
    }
  }

  @override
  Future<PayResult> purchase(ProductInfo product) async {
    try {
      await _ensureRevenueCatUserSynced();

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
      await _ensureRevenueCatUserSynced();

      final customerInfo = await Purchases.restorePurchases();
      final hasActive = customerInfo.entitlements.active.isNotEmpty ||
          customerInfo.activeSubscriptions.isNotEmpty ||
          customerInfo.nonSubscriptionTransactions.isNotEmpty;

      if (!hasActive) {
        return PayResult.failed('No active purchases found');
      }

      onEntitlementsChanged?.call();

      return PayResult.success();
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
