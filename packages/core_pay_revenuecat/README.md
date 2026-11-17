# core_pay_revenuecat

基于 RevenueCat SDK 的出海跨平台应用内购买（In-App Purchase / Subscription）实现包，负责商品本地化价格补齐、收据验证、恢复购买并全自动与 `core_pay_base` 桥接。

## 🏷️ 最新版本 Tag

`pay_revenuecat@1.2.0`

## 📦 接入方式 (Installation)

在实际发行工程中直接接入本包（自动依赖并全量透传 `core_pay_base` 的所有模型与全局 `Pay` 门面）：

```yaml
dependencies:
  core_pay_revenuecat:
    git:
      url: git@github.com:janzun/flutter_foundation.git
      path: packages/core_pay_revenuecat
      ref: pay_revenuecat@1.2.0
```

## ⚙️ 必要配置 (Configuration)

### 1. RevenueCat 后台配置
- 在 RevenueCat Dashboard 创建 Project，并绑定 iOS App Store Shared Secret 与 Android Google Play Service Account。
- 录入 Entitlement 标识（如 `pro`）与 Offerings 商品。
- 配置 Webhook 指向 Supabase Edge Function：`https://<project-ref>.supabase.co/functions/v1/revenuecat-webhook`。

### 2. 初始化
直接调用全局统一 `Pay.initialize`，内部自动调用工厂构造 `RevenueCatPayService`：
```dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:core_pay_revenuecat/core_pay_revenuecat.dart';

await Pay.initialize(
  client: Supabase.instance.client,
  appId: 'YOUR_APP_UUID',
  apiKey: Platform.isIOS ? 'appl_api_key' : 'goog_api_key',
  debug: kDebugMode, // 默认 kDebugMode：true 使用 common_test，false 使用 common
);

// 监听资产变化（购买成功/恢复成功后自动带退避重试刷新用户权益）
Pay.onEntitlementsChanged = () {
  Auth.refreshProfileWithRetry();
};
```

---

## 📚 完整 API 列表 (API Reference)

本包全量透传 `core_pay_base` 的全部 API，并提供以下专有实现：

```dart
class RevenueCatPayService extends BasePayService {
  RevenueCatPayService({
    required super.appId,
    required super.supabaseClient,
    super.debug = kDebugMode,
  });

  /// 初始化 RevenueCat，自动注入 $app_id 与 $debug Subscriber 属性并监听会话
  @override
  Future<void> initialize({required String apiKey});

  /// 从 common/common_test.products 拉取商品，并向应用商店查询 localizedPrice 进行补齐
  @override
  Future<List<ProductInfo>> fetchProducts({String? group});

  /// 唤起原生购买弹窗 (自动确保延迟匿名与 uid 对齐，防丢单)
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

// 3. 恢复购买 (支持跨账号全量权益迁移：会员自动顺延、积分/次数自动累加合并)
final restoreResult = await Pay.restorePurchases();
if (restoreResult.isSuccess) {
  print('恢复购买成功');
}
```

---

## 🔄 环境隔离与跨账号权益迁移机制

1. **布尔 `$debug` 标记驱动环境路由**：
   - 客户端初始化时通过 `Purchases.setAttributes` 自动向 RevenueCat 注入 `$app_id` 与 `$debug`（`"true"` / `"false"`），不暴露底层数据库 Schema 命名。
   - 服务端 `revenuecat-webhook` 入口（`revenuecat_index.ts`）直接读取 `$debug` 布尔标记，将测试流量与正式流量严格分流至 `revenuecat_test.ts`（`common_test`）与 `revenuecat_prod.ts`（`common`），彻底解决 Apple 提审使用 Sandbox 环境测试正式包时的路由冲突。
2. **全量资产合并与恢复购买 (`TRANSFER`)**：
   - 当用户换机或切换账号点击“恢复购买”触发 RevenueCat `TRANSFER` 事件时，服务端 `transfer_entitlements` 会将该用户旧账号下持有的**全部有效权益（会员、积分、次数及任意自定义资产）**原子划转并累加合并至当前账号，旧账号权益自动置为失效并生成双边审计流水。
