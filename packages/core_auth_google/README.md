# core_auth_google

Google 原生认证渠道模块，继承并实现 `core_auth_base` 规范，提供 Android / 跨端平台上的原生 **Google Sign-In** 能力，并自动与 Supabase Auth 完成身份令牌校验与会话绑定。

---

## 模块定位

- **角色**：`core_auth_base` 的 Google 平台原生实现。
- **支持端**：Android、iOS、Web 等。
- **内部技术**：`google_sign_in` + `supabase_flutter`。
- **透传导出**：全量重导出 `core_auth_base/auth.dart` 中的通用数据模型与 `BaseAuthService`。

---

## 依赖配置

在宿主 App 的 `pubspec.yaml` 中引入：

```yaml
dependencies:
  core_auth:
    path: packages/core_auth_google
```

---

## 快速使用

### 1. 实例化与工厂构造

```dart
import 'package:core_auth/auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authService = createAuthService(
  client: Supabase.instance.client,
  appId: 'your_app_slug',
  serverClientId: 'YOUR_GOOGLE_WEB_CLIENT_ID.apps.googleusercontent.com', // Android 获取 idToken 所需
);
```

### 2. 执行 Google 原生登录

```dart
// 拉起系统 Google 账号选择器并登录
final result = await authService.signIn(); // 默认指向 signInWithGoogle()

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
    print('当前用户: ${user.uid}');
  } else {
    print('用户未登录');
  }
});
```

---

## 核心 API

| 类 / 函数 | 说明 |
| :--- | :--- |
| `createAuthService({required SupabaseClient client, required String appId, String? serverClientId})` | 顶层工厂函数，返回配置好 Google 原生授权的 `BaseAuthService` 实例 |
| `GoogleAuthService` | 实现类，继承自 `BaseAuthService` |
| `GoogleAuthService.signIn()` | 默认登录实现，直接调用 `signInWithGoogle()` |
| `GoogleAuthService.signInWithGoogle()` | 拉起 Google 原生账号列表授权，取得 `idToken` 并完成 Supabase `signInWithIdToken` |
| `BaseAuthService.userStream` | 用户登录态响应式流 (`Stream<UserData?>`) |
| `BaseAuthService.currentUser` | 获取当前缓存的 `UserData?` |
| `BaseAuthService.signOut()` | 安全登出并清理 Supabase 会话 |
