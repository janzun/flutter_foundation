# core_auth_base

通用跨平台用户认证与中台档案同步基础底座，基于 Supabase Auth 驱动，提供统一不可变用户档案模型 (`UserData`)、会员与积分资产解析 (`EntitlementInfo`)，以及响应式用户流 (`userDataStream`)。

## 🏷️ 最新版本 Tag

`auth_base@1.1.0`

## 📦 接入方式 (Installation)

> ⚠️ **重要规范**：
> `core_auth_base` 属于**纯核心领域抽象与契约定义包**，**严禁在实际业务 App 中直接接入使用**。
> - **宿主 App 端**：必须根据目标平台/渠道接入具体的实现包，如 `core_auth_apple`（iOS/macOS）或 `core_auth_google`（Android/Web），具体实现包会全量透传本包的所有模型与门面；
> - **扩展开发者**：仅在需要扩展新渠道（如实现桌面端登录、微信/TikTok 登录、第三方 OAuth 适配器）时，作为内部依赖引入本包并继承 `BaseAuthService`。

```yaml
# 仅供渠道实现包的 pubspec.yaml 依赖，业务 App 严禁直接依赖
dependencies:
  core_auth_base:
    git:
      url: git@github.com:janzun/flutter_foundation.git
      path: packages/core_auth_base
      ref: auth_base@1.1.0
```

## ⚙️ 必要配置 (Configuration)

纯 Dart + Supabase SDK，无需敏感原生权限。仅需在应用启动入口初始化 Supabase：
```dart
await Supabase.initialize(url: 'YOUR_SUPABASE_URL', anonKey: 'YOUR_ANON_KEY');
```

---

## 📚 完整 API 列表 (API Reference)

### 1. 全局统一认证门面 (`Auth`)

```dart
class Auth {
  /// 初始化全局认证单例 (默认自动注入 DefaultAuthService)
  ///
  /// [debug] 默认跟随 [kDebugMode]：`true` 时读写 common_test 测试架构，`false` 时读写 common 正式架构。
  static void initialize({
    required SupabaseClient client,
    required String appId,
    bool debug = kDebugMode,
  });

  /// 供渠道包注入自定义服务实现 (如 AppleAuthService / GoogleAuthService)
  static void registerService(BaseAuthService service);

  /// 获取当前已登录用户的内存档案快照 (未登录为 null)
  static UserData? get currentUser;

  /// 用户业务档案响应式广播流 (登录/登出/刷新全自动推送)
  static Stream<UserData?> get userDataStream;

  /// 冷启动静默恢复已有会话 (若未登录直接返回 unauthorized，绝不隐式创建匿名账号)
  static Future<AuthResult<UserData>> restoreSession();

  /// 渠道默认一键登录 (基础包默认走匿名登录；渠道包对应 Apple/Google 原生登录)
  static Future<AuthResult<UserData>> signIn();

  /// 匿名登录 (延迟建档，仅在触发付费或云端能力时调用)
  static Future<AuthResult<UserData>> signInAnonymously();

  /// 发送邮箱 6 位 OTP 动态验证码
  static Future<AuthResult<void>> sendEmailOtp({required String email});

  /// 邮箱验证码登录 / 免密注册
  static Future<AuthResult<UserData>> signInWithEmailOtp({
    required String email,
    required String token,
  });

  /// 原生 Apple 登录 (由 core_auth_apple 实现)
  static Future<AuthResult<UserData>> signInWithApple();

  /// 原生 Google 登录 (由 core_auth_google 实现)
  static Future<AuthResult<UserData>> signInWithGoogle();

  /// 主动刷新当前用户业务档案与权益
  static Future<AuthResult<UserData>> refreshProfile();

  /// 带退避重试的档案刷新 (用于支付或恢复购买后等待 Webhook 异步落库)
  static Future<AuthResult<UserData>> refreshProfileWithRetry({
    List<Duration> delays = const [
      Duration(milliseconds: 800),
      Duration(milliseconds: 1500),
      Duration(milliseconds: 2500),
    ],
  });

  /// 退出登录 (自动重置内部状态与广播)
  static Future<void> signOut();
}
```

### 2. 用户业务档案与权益模型 (`UserData` & `EntitlementInfo`)

```dart
class UserData {
  final String id;             // 用户在中台 common.users 的全局 UUID
  final String appId;          // 所属应用 UUID
  final String supabaseUid;    // Supabase auth.users.id
  final bool isAnonymous;      // 是否为匿名访客
  final String authProvider;   // 认证渠道 ('anonymous' | 'apple' | 'google' | 'email')
  final bool isNewUser;        // 本次是否为新注册用户
  final String? email;         // 绑定邮箱
  final String displayName;    // 展示昵称
  final String? avatarUrl;     // 头像 URL
  final List<EntitlementInfo> entitlements; // 用户拥有的有效权益资产列表

  // 便捷计算属性
  bool get isVip;              // 当前是否为有效 VIP 会员
  String? get vipTier;         // 当前有效 VIP 等级 ('pro' / 'svip')
  DateTime? get vipExpireAt;   // VIP 到期截止时间 (null 为永久)
  int get pointsBalance;       // 当前标准积分余额
  double getBalance(String code, {String type = 'quota'}); // 获取指定资产额度
}

class EntitlementInfo {
  final String type;           // 权益类别 ('membership' | 'points' | 'quota')
  final String code;           // 业务代码 ('vip' | 'standard_point' | 'ai_quota')
  final String status;         // 状态 ('active' | 'expired' | 'paused' | 'frozen')
  final String? tier;          // 会员等级 ('free' | 'pro' | 'svip')
  final double balance;        // 余额数值 (积分或额度)
  final DateTime? expireAt;    // 到期时间 (null 为永久有效)
}
```

### 3. 操作结果与错误码 (`AuthResult` & `AuthErrorCode`)

```dart
class AuthResult<T> {
  final bool isSuccess;
  final T? data;
  final AuthErrorCode? code;
  final String? message;

  bool get isFailure => !isSuccess;
  const AuthResult.success(T? data);
  const AuthResult.failure(AuthErrorCode code, [String? message]);
}

enum AuthErrorCode {
  unauthorized,          // 未登录 / 会话过期
  userNotFound,          // 用户不存在
  otpInvalid,            // 验证码错误或已过期
  oauthFailed,           // 第三方授权被取消或失败
  riskBlocked,           // 命中风控限制
  networkUnavailable,    // 网络异常
  internalError,         // 内部服务异常
}
```
