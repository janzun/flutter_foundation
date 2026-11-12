# core_auth_base

通用跨平台用户认证与中台档案同步基础底座，基于 Supabase Auth 驱动，提供统一不可变用户档案模型 (`UserData`)、会员与积分资产解析 (`EntitlementInfo`)，以及响应式用户流 (`userDataStream`)。

## 🏷️ 最新版本 Tag

`auth_base@1.0.0`

## 📦 接入方式 (Installation)

> 提示：在实际工程中，若针对特定平台发行，建议直接接入渠道实现包 `core_auth_apple`（iOS/macOS）或 `core_auth_google`（Android）；纯 Web/桌面端或自定义渠道可直接接入本基底包。

```yaml
dependencies:
  core_auth_base:
    git:
      url: https://github.com/janzun/flutter_foundation.git
      path: packages/core_auth_base
      ref: auth_base@1.0.0
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
  /// 初始化全局认证单例
  static void initialize({
    required SupabaseClient client,
    required String appId,
  });

  /// 获取当前已登录用户的内存档案快照 (未登录为 null)
  static UserData? get currentUser;

  /// 用户业务档案响应式广播流 (登录/登出/刷新全自动推送)
  static Stream<UserData?> get userDataStream;

  /// 冷启动静默自动恢复登录态 (若未登录直接返回 unauthorized，绝不隐式创建匿名账号)
  static Future<AuthResult<UserData>> autoLogin();

  /// 渠道默认一键登录 (具体行为由当前引入的渠道包覆盖，如 Apple/Google 原生登录)
  static Future<AuthResult<UserData>> signIn();

  /// 匿名登录 (快速体验)
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

  /// 退出登录
  static Future<void> signOut();
}
```

### 2. 用户业务档案与权益模型 (`UserData` & `EntitlementInfo`)

```dart
class UserData {
  final String id;             // common.users.id
  final String appId;          // common.apps.id
  final String supabaseUid;    // auth.users.id
  final bool isAnonymous;      // 是否为匿名用户
  final String authProvider;   // 'anonymous' | 'apple' | 'google' | 'email'
  final bool isNewUser;        // 是否为本次刚刚注册的新用户
  final String? email;
  final String? phone;
  final String displayName;
  final String? avatarUrl;
  final String riskLevel;      // 'normal' | 'high' | 'banned'
  final List<EntitlementInfo> entitlements; // 会员/积分/额度资产列表
  final DateTime? lastLoginAt;
  final DateTime createdAt;

  // 便捷计算属性
  bool get isVip;              // 当前是否为有效 VIP
  String? get vipTier;         // 当前有效 VIP 等级 ('pro' / 'svip')
  DateTime? get vipExpireAt;   // VIP 到期截止时间
  int get pointsBalance;       // 当前标准积分余额
  double getBalance(String code, {String type = 'quota'}); // 获取指定资产额度
}

class EntitlementInfo {
  final String id;
  final String code;           // 权益标识 (如 'membership', 'standard_point')
  final String type;           // 'membership' | 'points' | 'quota'
  final String tier;           // 'free' | 'pro' | 'svip'
  final double balance;        // 余额数值
  final String status;         // 'active' | 'expired' | 'revoked'
  final DateTime? expireAt;
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
