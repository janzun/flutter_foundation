# core_auth_google

Google 渠道专用认证实现包，封装 Android / Web 原生 Google Sign-In 一键授权并使用 `idToken` 交换 Supabase 会话，全自动与 `core_auth_base` 桥接。

## 🏷️ 最新版本 Tag

`auth_google@1.0.0`

## 📦 接入方式 (Installation)

在 Android / Google Play 或 Web 发行包中直接接入本包（自动依赖并全量透传 `core_auth_base` 的所有模型与全局 `Auth` 门面）：

```yaml
dependencies:
  core_auth_google:
    git:
      url: https://github.com/janzun/flutter_foundation.git
      path: packages/core_auth_google
      ref: auth_google@1.0.0
```

## ⚙️ 必要配置 (Configuration)

### 1. Google Cloud Console 凭据配置
在 Google Cloud Console / Firebase Console 中：
- 配置 Android SHA-1 指纹与包名；
- 获取用于获取 `idToken` 的 **Web Client ID**。

### 2. 初始化
直接使用全局统一门面初始化（支持通过参数或 `--dart-define=GOOGLE_SERVER_CLIENT_ID=xxx` 传入 Web Client ID）：
```dart
import 'package:core_auth_google/auth.dart';

Auth.initialize(
  client: Supabase.instance.client,
  appId: 'YOUR_APP_UUID',
);
```

---

## 📚 完整 API 列表 (API Reference)

本包全量透传 `core_auth_base` 的全部 API，并提供以下专有实现：

```dart
class GoogleAuthService extends BaseAuthService {
  final String? serverClientId;

  GoogleAuthService({
    required super.client,
    required super.appId,
    this.serverClientId,
  });

  /// 渠道默认登录方式 (直接触发原生 Google 登录)
  @override
  Future<AuthResult<UserData>> signIn();

  /// 原生 Google 登录 (拉起系统 Google 授权弹窗，获取 idToken 后在 Supabase 换取 Session，自动同步中台档案)
  @override
  Future<AuthResult<UserData>> signInWithGoogle();
}
```

### 全局一键调用示例
```dart
// 直接调用渠道默认登录，或显式调用 Google 登录
final res = await Auth.signIn(); // 或 Auth.signInWithGoogle();

if (res.isSuccess) {
  final UserData user = res.data!;
  print('登录成功: ${user.displayName}, VIP: ${user.isVip}');
}
```
