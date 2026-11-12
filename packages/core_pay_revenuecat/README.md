# core_pay_revenuecat

基于 RevenueCat SDK 的出海跨平台应用内购买（In-App Purchase / Subscription）实现包，负责商品本地化价格补齐、收据验证、恢复购买并全自动与 `core_pay_base` 桥接。

## 🏷️ 最新版本 Tag

`pay_revenuecat@1.0.0`

## 📦 接入方式 (Installation)

在实际发行工程中直接接入本包（自动依赖并全量透传 `core_pay_base` 的所有模型与全局 `Pay` 门面）：

```yaml
dependencies:
  core_pay_revenuecat:
    git:
      url: git@github.com:janzun/flutter_foundation.git
      path: packages/core_pay_revenuecat
      ref: pay_revenuecat@1.0.0
```

## ⚙️ 必要配置 (Configuration)

### 1. RevenueCat 后台配置
- 在 RevenueCat Dashboard 创建 Project，并绑定 iOS App Store Shared Secret 与 Android Google Play Service Account。
- 录入 Entitlement 标识（如 `pro`）与 Offerings 商品。

### 2. 初始化
直接调用全局统一 `Pay.initialize`，内部自动调用工厂构造 `RevenueCatPayService`：
```dart
import 'package:core_pay_revenuecat/core_pay_revenuecat.dart';

await Pay.initialize(
  client: Supabase.instance.client,
  appId: 'YOUR_APP_UUID',
  apiKey: Platform.isIOS ? 'appl_api_key' : 'goog_api_key',
);

// 监听资产变化（购买成功/恢复成功后自动同步刷新用户权益）
Pay.onEntitlementsChanged = () {
  Auth.refreshProfile();
};
```

---

## 📚 完整 API 列表 (API Reference)

本包全量透传 `core_pay_base` 的全部 API，并提供以下专有实现：

```dart
class RevenueCatPayService extends BasePayService {
  final SupabaseClient supabaseClient;

  RevenueCatPayService({
    required super.appId,
    required this.supabaseClient,
  });

  /// 初始化 RevenueCat，自动绑定当前 Supabase User ID 并监听会话与权益变更
  @override
  Future<void> initialize({required String apiKey});

  /// 从 common.products 拉取商品，并自动向应用商店查询本地化价格 (localizedPrice) 进行补齐
  @override
  Future<List<ProductInfo>> fetchProducts({String? group});

  /// 唤起原生购买弹窗 (支持订阅与消耗型商品)
  @override
  Future<PayResult> purchase(ProductInfo product);

  /// 恢复购买记录 (用户换机或重新安装)
  @override
  Future<PayResult> restorePurchases();
}
```

### 全局一键调用示例
```dart
// 1. 获取商品列表
final products = await Pay.fetchProducts(group: 'subscription');
final selected = products.first;

// 2. 唤起购买
final result = await Pay.purchase(selected);
if (result.isSuccess) {
  print('支付成功，交易流水: ${result.channelTransactionId}');
} else if (result.isCancelled) {
  print('用户主动取消支付');
} else {
  print('支付失败: ${result.errorMessage}');
}

// 3. 恢复购买
final restoreResult = await Pay.restorePurchases();
```
