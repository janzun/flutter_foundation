import 'package:flutter/foundation.dart';
import '../model/pay_result.dart';
import '../model/product_info.dart';
import '../service/base_pay_service.dart';

export 'model/product_info.dart';
export 'model/entitlement_info.dart';
export 'model/pay_result.dart';
export 'service/base_pay_service.dart';

/// 全局统一支付中枢门面 (Pay)
class Pay {
  Pay._();

  static BasePayService? _instance;

  static BasePayService get _impl {
    if (_instance == null) {
      throw StateError('Pay 尚未初始化，请先调用 Pay.initialize()');
    }
    return _instance!;
  }

  /// 资产可能发生变动的全局回调 (购买成功/恢复成功/渠道后台推送)
  static VoidCallback? get onEntitlementsChanged => _impl.onEntitlementsChanged;
  static set onEntitlementsChanged(VoidCallback? callback) {
    _impl.onEntitlementsChanged = callback;
  }

  /// 初始化全局支付单例（需传入具体的渠道实现 [service]）
  static Future<void> initialize({
    required BasePayService service,
    required String apiKey,
  }) async {
    _instance?.dispose();
    _instance = service;
    await _impl.initialize(apiKey: apiKey);
  }

  /// 是否已初始化
  static bool get isInitialized => _instance != null;

  /// 获取商品列表 (支持按业务分组 [group] 过滤，不传则返回当前平台全部上架商品)
  static Future<List<ProductInfo>> fetchProducts({String? group}) =>
      _impl.fetchProducts(group: group);

  /// 唤起购买指定商品
  static Future<PayResult> purchase(ProductInfo product) =>
      _impl.purchase(product);

  /// 恢复购买记录
  static Future<PayResult> restorePurchases() => _impl.restorePurchases();

  /// 释放支付服务资源
  static void dispose() {
    _instance?.dispose();
    _instance = null;
  }
}
