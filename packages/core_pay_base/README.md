# core_pay_base

跨平台商业化变现与支付抽象底座，统一定义商品模型 (`ProductInfo`)、交易生命周期结果 (`PayResult`)，以及基于单例的支付中枢门面 (`Pay`)。

## 🏷️ 最新版本 Tag

`pay_base@1.2.0`

## 📦 接入方式 (Installation)

> ⚠️ **重要规范**：
> `core_pay_base` 属于**纯核心支付领域抽象与契约定义包**，**严禁在实际业务 App 中直接接入使用**。
> - **宿主 App 端**：必须接入具体的支付实现包（如海外移动端接入 `core_pay_revenuecat`）；
> - **扩展开发者**：仅在需要扩展新支付实现（如自建 Apple StoreKit 2 / Google Play Billing 原生直连、Stripe 桌面/Web 端收银台等）时，作为内部依赖引入本包并继承 `BasePayService`，App 最终只接入封装好的具体实现包。

```yaml
# 仅供支付实现包的 pubspec.yaml 依赖，业务 App 严禁直接依赖
dependencies:
  core_pay_base:
    git:
      url: git@github.com:janzun/flutter_foundation.git
      path: packages/core_pay_base
      ref: pay_base@1.2.0
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

  /// 初始化全局支付单例 (需传入具体渠道包实现)
  static Future<void> initialize({
    required BasePayService service,
    required String apiKey,
  });

  /// 是否已初始化就绪
  static bool get isInitialized;

  /// 获取商品列表 (支持按业务分组 group 过滤，不传则返回当前平台全部上架商品)
  static Future<List<ProductInfo>> fetchProducts({String? group});

  /// 唤起购买指定商品
  static Future<PayResult> purchase(ProductInfo product);

  /// 恢复购买记录 (换机或重新安装)
  static Future<PayResult> restorePurchases();

  /// 释放支付服务资源
  static void dispose();
}
```

### 2. 商品模型 (`ProductInfo`)

> **精简设计规范**：商品展示名称、多语言描述与本地货币价格由应用商店 SDK（如 RevenueCat / StoreKit / Play Billing）实时本地化呈现，数据库仅作为商品唯一标识与权益映射元数据。

```dart
enum ProductType { subscription, consumable, nonConsumable }
enum BillingCycle { oneOff, monthly, annual, lifetime }

class ProductInfo {
  final String code;                  // 业务商品唯一标识 (如 'vip_yearly_ios')
  final String group;                 // 业务分组 ('subscription' | 'points' | 'quota' | 'default')
  final ProductType type;             // 商品类型 (订阅/消耗品/非消耗品)
  final BillingCycle billingCycle;    // 计费周期 (一次性/月/年/终身)
  final String storeProductId;        // 商店后台 Product ID (如 'com.app.vip.yearly')
  final String? localizedPrice;       // 商店格式化本地化价格串 (如 '$9.99', '¥68.00')
  final double? price;                // 商店本地货币实际价格 (由商店 SDK 实时填充)
  final String? currency;             // 商店本地货币代码 (如 'USD', 'CNY')
  final Map<String, dynamic> storeParams; // 商店特定扩展参数
}
```

### 3. 支付结果模型 (`PayResult`)

```dart
enum PayStatus { success, cancelled, pending, failed }

class PayResult {
  final PayStatus status;             // 支付状态
  final String? channelTransactionId; // 渠道交易流水号
  final String? errorCode;            // 失败错误代码
  final String? errorMessage;         // 失败错误描述

  bool get isSuccess => status == PayStatus.success;
  bool get isCancelled => status == PayStatus.cancelled;
  bool get isPending => status == PayStatus.pending;
  bool get isFailure => status == PayStatus.failed;
}
```
