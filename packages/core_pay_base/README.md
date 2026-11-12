# core_pay_base

跨平台商业化变现与支付抽象底座，统一定义商品模型 (`ProductInfo`)、交易生命周期结果 (`PayResult`)，以及基于单例的支付中枢门面 (`Pay`)。

## 🏷️ 最新版本 Tag

`pay_base@1.0.0`

## 📦 接入方式 (Installation)

> 提示：在实际工程中，出海内购建议直接接入基于 RevenueCat 的实现包 `core_pay_revenuecat`。

```yaml
dependencies:
  core_pay_base:
    git:
      url: https://github.com/janzun/flutter_foundation.git
      path: packages/core_pay_base
      ref: pay_base@1.0.0
```

## ⚙️ 必要配置 (Configuration)

纯 Dart 契约与模型定义，无需原生权限。

---

## 📚 完整 API 列表 (API Reference)

### 1. 全局支付中枢门面 (`Pay`)

```dart
class Pay {
  /// 资产可能发生变动的全局回调 (购买成功/恢复成功/渠道推送)
  static VoidCallback? get onEntitlementsChanged;
  static set onEntitlementsChanged(VoidCallback? callback);

  /// 初始化全局支付单例 (自动关联对应渠道包的实现)
  static Future<void> initialize({
    required SupabaseClient client,
    required String appId,
    required String apiKey,
    BasePayService? service,
  });

  /// 是否已初始化就绪
  static bool get isInitialized;

  /// 获取商品列表 (支持按业务分组 group 过滤，如 'subscription', 'points')
  static Future<List<ProductInfo>> fetchProducts({String? group});

  /// 唤起购买指定商品
  static Future<PayResult> purchase(ProductInfo product);

  /// 恢复购买记录 (换机或重新安装)
  static Future<PayResult> restorePurchases();
}
```

### 2. 商品模型 (`ProductInfo`)

```dart
enum ProductType { subscription, consumable, nonConsumable }
enum BillingCycle { oneOff, monthly, annual, lifetime }

class ProductInfo {
  final String code;                  // 业务商品唯一标识
  final String appId;                 // 应用唯一标识
  final String group;                 // 业务分组 ('subscription' | 'points' | 'quota')
  final String name;                  // 商品显示名称
  final String description;           // 商品详细描述
  final double price;                 // 本地基准价格
  final String currency;              // 货币单位 ('USD', 'CNY')
  final String? localizedPrice;       // 商店格式化本地化价格串 (如 '$9.99', '¥68.00')
  final ProductType type;             // 商品类型
  final BillingCycle billingCycle;    // 计费周期
  final String platform;              // 平台 ('ios', 'android', 'web')
  final String store;                 // 商店 ('app_store', 'google_play', 'stripe')
  final String storeProductId;        // 商店后台 Product ID
  final Map<String, dynamic> storeParams; // 商店特定扩展参数
  final String? rewardTier;           // 赠送权益等级 ('pro', 'svip')
  final int rewardDurationDays;       // 权益时长 (天)
  final double rewardPoints;          // 赠送积分数
  final Map<String, dynamic> rewardPerks; // 额外权益字典
  final int sortOrder;                // 排序权重
}
```

### 3. 支付结果模型 (`PayResult`)

```dart
enum PayStatus { success, cancelled, pending, failed }

class PayResult {
  final PayStatus status;
  final String? productCode;
  final String? channelTransactionId;
  final String? errorMessage;
  final Map<String, dynamic>? rawDetails;

  bool get isSuccess => status == PayStatus.success;
  bool get isCancelled => status == PayStatus.cancelled;
  bool get isPending => status == PayStatus.pending;
  bool get isFailed => status == PayStatus.failed;

  const PayResult.success({String? productCode, String? channelTransactionId, Map<String, dynamic>? rawDetails});
  const PayResult.cancelled({String? productCode});
  const PayResult.pending({String? productCode, String? channelTransactionId});
  const PayResult.failed(String errorMessage, {String? productCode, Map<String, dynamic>? rawDetails});
}
```
