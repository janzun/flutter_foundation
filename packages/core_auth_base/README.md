# Core Auth 认证与用户档案中心

`core_auth_base` 是跨应用、跨平台的统一核心用户认证中枢。基于 **Supabase Auth** 与中台数据架构设计，提供访客匿名体验、邮件验证码免密登录、三方 OAuth 插件化扩展能力，并负责用户业务主档与资产的自愈初始化。

---

## 一、 涉及数据与数据模型

### 1. 底层存储与数据表
* **`auth.users`** (Supabase 认证中心)：存储底层身份账号（邮箱、手机号、第三方登录 UID、加密 Hash）。
* **`common.users`** (业务用户档案主表)：
  * `id`: 业务层全局统一的用户 UUID。
  * `app_id`: 归属应用标识。
  * `supabase_uid`: 映射 `auth.users.id`。
  * `display_name` / `avatar_url`: 用户昵称与头像。
  * `auth_provider`: 登录方式 (`anonymous` / `email` / `apple` / `google`)。
  * `risk_level`: 用户风控等级 (`normal` / `high` / `banned`)。
* **`common.user_entitlements`** (统一资产与权益表)：
  * 集中管理用户的所有资产（会员身份、通用积分、功能额度），与 Auth、Pay 双模块数据底层打通。

### 2. Dart 数据模型 (`@freezed`)
* **`UserData`**：完整的用户业务档案对象。
  * `entitlements`：`List<EntitlementInfo>` 统一权益列表，囊括会员、积分与配额。
  * `isVip`：便捷计算属性，自动检索是否有有效未过期的会员。
  * `vipTier`：当前有效 VIP 等级（如 `'pro'`, `'svip'`）。
  * `vipExpireAt`：会员到期截止时间。
  * `pointsBalance`：标准积分余额。
  * `getBalance(code)`：按权益标识查询特定资产/配额余额。
  * `isAnonymous`：当前是否为匿名访客。
* **`EntitlementInfo`**：单项权益/资产模型。
  * `id`：资产唯一标识。
  * `type`：类别 (`membership` / `points` / `quota`)。
  * `code`：业务标识（如 `pro`, `standard_point`, `ai_summary`）。
  * `status`：状态 (`active` / `expired` / `frozen`)。
  * `tier` / `billingCycle`：会员档位与计费周期。
  * `balance`：当前余额。
  * `expireAt`：到期时间。
* **`AuthResult<T>`**：标准返回包装器，包含成功标识、状态码及错误信息。

---

## 二、 工作原理与核心链路

```
                   ┌──────────────────────────────────────┐
                   │          Flutter App Client          │
                   └──────────────────┬───────────────────┘
                                      │
            ┌─────────────────────────┼─────────────────────────┐
            │ 1. 匿名/邮件/三方登录    │                         │
            ▼                         ▼                         ▼
   Supabase Auth SDK         Apple Native SDK          Google Sign-In SDK
            │                         │                         │
            └─────────────────────────┼─────────────────────────┘
                                      │ 2. 拿到认证 Session (JWT)
                                      ▼
                   Postgres RPC: common.sync_user_profile
            ┌───────────────────────────────────────────────────┐
            │ • 自动判定是否新用户 (自愈建档)                   │
            │ • 初始化 common.users & common.user_entitlements  │
            │ • 聚合返回包含全量 entitlements 的 UserData 档案  │
            └─────────────────────────┬─────────────────────────┘
                                      │ 3. 广播给前端
                                      ▼
                         Auth.userDataStream
```

1. **静默登录与自愈建档**：
   应用冷启动时调用 `Auth.autoLogin()`。若本地存在会话则校验刷新，若不存在则无感拉起匿名登录，确保用户无需繁琐注册即可体验核心功能。
2. **账号转正 (Linking / Upgrade)**：
   匿名用户通过验证码登录或绑定 Apple/Google 账号后，底层会话平滑升级为正式账号，原本地历史数据完整保留。
3. **响应式状态流**：
   通过 `Auth.userDataStream` 全局广播用户登录态与资产变更，UI 页面可细粒度监听。

---

## 三、 对外 API

通过统一门面类 `Auth` 进行调用（使用前在应用入口调用 `Auth.initialize(...)`）：

```dart
// 1. 初始化 (在 main() 或 App 初始化 ViewModel 中)
Auth.initialize(
  client: Supabase.instance.client,
  appId: AppConfig.appId,
);

// 2. 冷启动静默自动登录
final result = await Auth.autoLogin();
if (result.isSuccess) {
  final user = result.data!;
  print('登录成功: ${user.displayName}');
  print('是否为VIP: ${user.isVip}, 等级: ${user.vipTier}, 到期时间: ${user.vipExpireAt}');
  print('标准积分余额: ${user.pointsBalance}');
}

// 3. 监听全局用户状态变化
Auth.userDataStream.listen((UserData? user) {
  if (user == null) {
    print('用户已登出');
  } else {
    print('当前用户: ${user.displayName}, VIP: ${user.isVip}, 权益总数: ${user.entitlements.length}');
  }
});

// 4. 发送邮箱验证码 (OTP)
await Auth.sendEmailOtp(email: 'user@example.com');

// 5. 验证码登录 / 注册
final loginResult = await Auth.signInWithEmailOtp(
  email: 'user@example.com',
  token: '123456',
);

// 6. 三方登录 (需引入对应渠道包，如 core_auth_app_store)
await Auth.signInWithApple();
await Auth.signInWithGoogle();

// 7. 刷新用户档案与资产
await Auth.refreshProfile();

// 8. 退出登录
await Auth.signOut();
```

---

## 四、 渠道包架构分层

* **`core_auth_base`**：核心抽象、纯 Dart 领域模型（`UserData`, `EntitlementInfo`）、`sync_user_profile` RPC 交互与 `Auth` 单例门面。
* **`core_auth_app_store`**：继承基类，集成 `sign_in_with_apple` 与 `google_sign_in`。
* **`core_auth_google_play`**：继承基类，面向纯 Google 生态分发。
