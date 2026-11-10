import 'package:flutter/foundation.dart';
import '../model/pay_result.dart';
import '../model/product_info.dart';

/// 跨端通用支付核心服务抽象契约 (专注交易生命周期与商店交互)
abstract class BasePayService {
  /// 应用标识 UUID
  final String appId;

  /// 资产可能发生变动的全局回调 (购买成功/恢复成功/渠道推送)
  VoidCallback? onEntitlementsChanged;

  BasePayService({required this.appId});

  /// 初始化支付 SDK 环境与渠道凭证
  Future<void> initialize({
    required String apiKey,
  });

  /// 获取商品配置列表 (支持按业务分组 group 过滤，并自动补齐商店本地化格式价格)
  Future<List<ProductInfo>> fetchProducts({String? group});

  /// 唤起购买指定商品
  Future<PayResult> purchase(ProductInfo product);

  /// 恢复购买记录 (针对 iOS/Android 换机或重新安装)
  Future<PayResult> restorePurchases();

  /// 释放资源
  @mustCallSuper
  void dispose() {}
}
