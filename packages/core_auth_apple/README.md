# core_auth_apple

Apple 原生认证渠道模块，继承并实现 `core_auth_base` 规范，提供 iOS / macOS 上的原生 **Sign in with Apple** 能力，并自动与 Supabase Auth 完成身份令牌校验与会话绑定。

---

## 模块定位

- **角色**：`core_auth_base` 的 Apple 平台原生实现。
- **支持端**：iOS / macOS。
- **内部技术**：`sign_in_with_apple` + `crypto` (SHA256 Nonce 生成) + `supabase_flutter`。
- **透传导出**：全量重导出 `core_auth_base/auth.dart` 中的通用模型（`UserData`、`AuthResult`、`AuthErrorCode` 等）和 `BaseAuthService`。

---

## 依赖配置

在宿主 App 的 `pubspec.yaml` 中引入：

```yaml
dependencies:
  core_auth:
    path: packages/core_auth_apple
```

*(注：包名对外暴露为 `core_auth`，可在不同编译构建渠道或 Target 中无缝替换为其他渠道包)*

---

## 快速使用

### 1. 实例化与工厂构造

```dart
import 'package:core_auth/auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authService = createAuthService(
  client: Supabase.instance.client,
  appId: 'your_app_slug',
);
```

### 2. 执行 Apple 原生登录

```dart
// 触发 Apple 原生 FaceID / TouchID / Apple ID 弹窗授权
final result = await authService.signIn(); // 默认指向 signInWithApple()

if (result.isSuccess) {
  final user = result.data!;
  print('登录成功: ${user.uid}, email: ${user.email}');
} else {
  print('登录失败: [${result.errorCode}] ${result.errorMessage}');
}
```

### 3. 监听登录态变更

```dart
authService.userStream.listen((UserData? user) {
  if (user != null) {
    print('用户在线: ${user.uid}');
  } else {
    print('用户已登出或未登录');
  }
});
```

---

## 核心 API

| 类 / 函数 | 说明 |
| :--- | :--- |
| `createAuthService({required SupabaseClient client, required String appId})` | 顶层工厂函数，返回配置好 Apple 原生授权的 `BaseAuthService` 实例 |
| `AppleAuthService` | 实现类，继承自 `BaseAuthService` |
| `AppleAuthService.signIn()` | 默认登录实现，直接调用 `signInWithApple()` |
| `AppleAuthService.signInWithApple()` | 生成安全 Nonce，拉起 Apple 原生弹窗，完成 Supabase `signInWithIdToken` |
| `BaseAuthService.userStream` | 用户登录态响应式流 (`Stream<UserData?>`) |
| `BaseAuthService.currentUser` | 获取当前缓存的 `UserData?` |
| `BaseAuthService.signOut()` | 安全登出并清理 Supabase 会话 |
