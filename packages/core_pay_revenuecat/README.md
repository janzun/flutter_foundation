# core_pay_revenuecat

基于 **RevenueCat SDK** 实现的跨平台应用内购买与订阅底座，继承并实现 `core_pay_base` 规范。支持 iOS App Store 与 Android Google Play 的订阅、消耗品与非消耗品购买，内置与 Supabase 商业产品的自动对齐与价格本地化映射。

---

## 模块定位

- **角色**：`core_pay_base` 的 RevenueCat 原生实现渠道。
- **支持平台**：iOS、Android（支持与 Web/桌面端的抽象兼容）。
- **核心能力**：
  - **开箱即用集成**：一行代码配置 RevenueCat SDK，自动同步 Supabase Auth UID。
  - **产品多源合流**：从 Supabase `products` 数据库拉取商业策略配置，同时通过 RevenueCat 查询商店本地化货币与真实价格进行精准补齐。
  - **统一订阅生命周期**：支持一键购买、掉单补单、恢复购买（`restorePurchases`）以及权益变动实时广播。
  - **全量透传导出**：透传 `core_pay_base` 所有的模型与枚举（`ProductInfo`、`PayResult`、`ProductType`、`BillingCycle` 等）。

---

## 依赖配置

在宿主 App 的 `pubspec.yaml` 中引入：

```yaml
dependencies:
  core_pay:
    path: packages/core_pay_revenuecat
```

---

## 快速使用

### 1. 实例化与初始化

```dart
import 'package:core_pay_revenuecat/core_pay_revenuecat.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 1. 创建 Service 实例
final payService = createPayService(
  appId: 'your_app_slug',
  supabaseClient: Supabase.instance.client,
);

// 2. 监听资产变动（续费、退订、购买成功）
payService.onEntitlementsChanged = () {
  print('用户订阅/资产状态发生变动，触发重新拉取或刷新 UI');
};

// 3. 在 App 启动时初始化 RevenueCat 平台密钥
await payService.initialize(
  apiKey: Platform.isIOS ? 'appl_YourIosApiKey' : 'goog_YourAndroidApiKey',
);
```

### 2. 拉取商品列表 (含本地化货币显示)

```dart
// 拉取当前 App 和当前平台激活的商品列表（可选指定业务分组 group）
final List<ProductInfo> products = await payService.fetchProducts(group: 'pro_vip');

for (final product in products) {
  print('${product.name}: ${product.localizedPrice ?? product.price} (${product.billingCycle})');
}
```

### 3. 发起购买

```dart
final ProductInfo targetProduct = products.first;

final PayResult result = await payService.purchase(targetProduct);

if (result.isSuccess) {
  print('支付成功！交易凭证号: ${result.channelTransactionId}');
} else if (result.isCancelled) {
  print('用户主动取消支付');
} else {
  print('支付失败: ${result.errorMessage}');
}
```

### 4. 恢复购买

```dart
final PayResult restoreResult = await payService.restorePurchases();
if (restoreResult.isSuccess) {
  print('恢复成功: ${restoreResult.rawDetails}');
} else {
  print('恢复失败: ${restoreResult.errorMessage}');
}
```

---

## 核心 API

| 类 / 函数 | 说明 |
| :--- | :--- |
| `createPayService({required String appId, required SupabaseClient supabaseClient})` | 工厂函数，返回统一的 `BasePayService` 实例 |
| `RevenueCatPayService` | 实现类，继承自 `BasePayService` |
| `initialize({required String apiKey})` | 配置 RevenueCat SDK 并与 Supabase Auth 登录态绑定 |
| `fetchProducts({String? group})` | 从 Supabase 获取商品定义，结合应用商店查询真实本地化货币价格 |
| `purchase(ProductInfo product)` | 唤起苹果/谷歌系统支付面板发起购买 |
| `restorePurchases()` | 恢复用户在应用商店的历史购买凭证 |
| `onEntitlementsChanged` | 回调函数属性：当监听到外部续费、掉单处理、取消等变动时自动触发 |
