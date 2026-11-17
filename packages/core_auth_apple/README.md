# core_auth_apple

Apple 渠道专用认证实现包，封装 iOS / macOS 原生 Face ID / Touch ID 极速授权与安全 Nonce 校验，全自动与 `core_auth_base` 桥接。

## 🏷️ 最新版本 Tag

`auth_apple@1.1.0`

## 📦 接入方式 (Installation)

在 iOS / macOS 发行包中直接接入本包（自动依赖并全量透传 `core_auth_base` 的所有模型与全局 `Auth` 门面）：

```yaml
dependencies:
  core_auth:
    git:
      url: git@github.com:janzun/flutter_foundation.git
      path: packages/core_auth_apple
      ref: auth_apple@1.1.0
```

## ⚙️ 必要配置 (Configuration)

### 1. Xcode Signing & Capabilities
在 Xcode 中为 Runner 目标添加 **Sign in with Apple** Capability。

### 2. 初始化
直接使用全局统一门面初始化，内部自动绑定 Apple 原生认证服务：
```dart
import 'package:flutter/foundation.dart';
import 'package:core_auth/auth.dart';

Auth.initialize(
  client: Supabase.instance.client,
  appId: 'YOUR_APP_UUID',
  debug: kDebugMode, // 默认 kDebugMode：true 使用 common_test，false 使用 common
);
```

---

## 📚 完整 API 列表 (API Reference)

本包全量透传 `core_auth_base` 的全部 API，并提供以下专有实现：

```dart
class AppleAuthService extends BaseAuthService {
  AppleAuthService({
    required super.client,
    required super.appId,
    super.debug = kDebugMode,
  });

  /// 渠道默认登录方式 (直接触发原生 Sign in with Apple)
  @override
  Future<AuthResult<UserData>> signIn();

  /// 原生 Sign in with Apple (生成安全 Nonce，拉起系统授权并在 Supabase 换取 Session，自动同步中台档案)
  @override
  Future<AuthResult<UserData>> signInWithApple();
}
```

### 全局一键调用示例
```dart
// 1. 冷启动静默恢复已有会话 (未登录返回 unauthorized，绝不隐式新建匿名账号)
final sessionRes = await Auth.restoreSession();
if (sessionRes.isSuccess) {
  print('恢复已登录会话: ${sessionRes.data!.displayName}');
}

// 2. 触发 Apple 授权登录 (直接调用渠道默认登录，或显式调用 Apple 登录)
final res = await Auth.signIn(); // 或 Auth.signInWithApple();

if (res.isSuccess) {
  final UserData user = res.data!;
  print('登录成功: ${user.displayName}, VIP: ${user.isVip}');
}
```
