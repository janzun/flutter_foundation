# Core Pay 商业化支付与资产中心

`core_pay_base` 是跨应用、跨平台的商业化统一中枢。定义了商店原生品项模型、交易终态订单、统一资产模型与支付抽象契约。支持多渠道（RevenueCat、StoreKit、Google Play、Stripe 等）无缝插拔，采用**无预创单、票据驱动、商店单品项平铺、解耦回调联动**的工业级设计。

---

## 一、 涉及数据与数据模型

### 1. 数据库核心表 (Supabase / Postgres)
* **`common.products`** (统一商品定义表 - 单记录单商店品项)：
  * `code`: 业务唯一编码（如 `vip_monthly_ios`）。
  * `group`: 业务商品分组（如 `'subscription'` 订阅付费墙、`'points'` 积分加油包、`'single_pass'` 单次权益）。
  * `type`: 官方标准交易类型（`subscription` 自动续期订阅、`consumable` 消耗型、`non_consumable` 非消耗型）。
  * `platform`: 目标平台（`ios`, `android`, `web`）。
  * `store`: 所属商店或支付方式（`app_store`, `play_store`, `stripe`）。
  * `store_product_id`: 该商店真实配置的产品 ID（如 `com.rtt.vip.monthly`）。
  * `store_params (JSONB)`: 商店专属额外参数（如 Google Play 的 `base_plan_id`, `offer_id`，Stripe 的 `price_id`）。
  * `reward_tier`, `reward_duration_days`, `reward_points`, `reward_perks (JSONB)`: 购买后发放的附赠权益。
* **`common.orders`** (核心终态订单表)：
  * 仅记录终态订单 (`paid`, `refunded`)，杜绝大量 pending 垃圾订单。
  * 联合唯一键 `(store, channel_transaction_id)` 保证幂等，记录流水凭证与退款审计信息。
* **`common.user_entitlements`** (统一用户资产与权益表)：
  * 统一由 Auth 模块直接读取和感知，管理用户的 VIP 有效期 (`expire_at`)、积分余额 (`balance`)。
* **`common.entitlement_transactions`** (权益审计流水明细表)：
  * 记录所有充值、赠送、退款与消费明细，留存审计追踪依据。

### 2. Dart 数据模型 (`@freezed`)
* **`ProductInfo`**：单商店商品描述模型，包含业务编码、商品分组 `group`、商店名 `store`、商店品项 ID `storeProductId`、本地化价格（如 `$4.99`）、标准类型 (`subscription` / `consumable` / `nonConsumable`) 及附赠权益。
* **`PayResult`**：支付与恢复购买的结果模型 (`success`, `cancelled`, `failed`)。

---

## 二、 工作原理与核心链路

### 1. 极速购买与核销链路 (无预创单 + 回调解耦联动)
```
[Flutter Client] ────── 1. 发起购买 (无需预建待支付订单) ──────► [App Store / Google Play]
       ▲                                                                 │
       │                                                          2. 用户扣款成功
       │                                                                 ▼
       │                                                       [RevenueCat Server]
       │                                                                 │
       │                                                          3. Webhook 签名通知
       │                                                                 ▼
       │                                                   [Edge Function: payment-webhook]
       │                                                                 │
       │                                                          4. 验签并调用 RPC
       │                                                                 ▼
       │                                                      [Postgres RPC: provision_entitlements]
       │                                                      ├─ 校验凭证幂等性
       │                                                      ├─ 插入终态订单 (status = 'paid')
       │                                                      ├─ 顺延会员有效截止时间
       │                                                      ├─ 累加积分与混合权益包
       │                                                      └─ 记录流水明细
       │
       └────── 5. Pay 触发 onEntitlementsChanged 回调 ──► 驱动 Auth.refreshProfile() 刷新
```

### 2. 退款撤回链路 (自动清零防透支)
```
[用户申请退款] ──► [Apple/Google 客服通过] ──► [RevenueCat Webhook (CANCELLATION)]
                                                          │
                                                          ▼
                                            [payment-webhook]
                                                          │
                                                          ▼
                                           [Postgres RPC: revoke_entitlements]
                                           ├─ 命中原订单更新 status = 'refunded'
                                           ├─ 会员立即失效 (expire_at = now())
                                           ├─ 积分扣减至 0 为止 (扣完即止)
                                           ├─ 记录退款流水
                                           └─ 高额退款标记 users.risk_level = 'high'
```

---

## 三、 对外 API

通过统一门面类 `Pay` 进行调用：

```dart
// 1. 初始化支付服务 (在应用冷启动时完成)
await Pay.initialize(
  client: Supabase.instance.client,
  appId: AppConfig.appId,
  apiKey: AppConfig.revenueCatApiKey,
);

// 2. 绑定资产自动刷新闭环 (购买/恢复成功时自动刷新 Auth 用户档案)
Pay.onEntitlementsChanged = () {
  Auth.refreshProfile();
};

// 3. 获取商品列表 (支持按业务分组 group 过滤，如 'subscription', 'points')
final List<ProductInfo> vipProducts = await Pay.fetchProducts(group: 'subscription');
for (final product in vipProducts) {
  print('${product.name} - 价格: ${product.localizedPrice}');
}

// 4. 唤起购买
final PayResult result = await Pay.purchase(vipProducts.first);
if (result.status == PayStatus.success) {
  print('支付成功！交易凭证: ${result.channelTransactionId}');
} else if (result.status == PayStatus.cancelled) {
  print('用户取消了支付');
} else {
  print('支付失败: ${result.errorMessage}');
}

// 5. 恢复购买 (用于换机或重新安装)
final PayResult restoreResult = await Pay.restorePurchases();
if (restoreResult.status == PayStatus.success) {
  print('已成功恢复购买权益！');
}
```

---

## 四、 插件生态与具体实现包

* **`core_pay_base`**：定义所有支付实体、枚举（官方标准的 `ProductType`）、`BasePayService` 契约与 `Pay` 静态门面。
* **`core_pay_revenuecat`**：实现基于 `purchases_flutter` 的跨平台支付集成，处理商品获取、购买调起、商店异常拦截（精准识别用户取消），并在购买与恢复成功时自动触发 `onEntitlementsChanged` 广播。
