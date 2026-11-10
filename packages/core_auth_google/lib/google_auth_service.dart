import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:core_auth_base/auth.dart';

/// Google 渠道专用的认证服务实现类 (原生 Google Sign-In)
class GoogleAuthService extends BaseAuthService {
  /// 用于 Android 平台获取 Google idToken 的 OAuth Web 客户端 ID (Web Client ID)
  final String? serverClientId;

  GoogleAuthService({
    required super.client,
    required super.appId,
    this.serverClientId,
  });

  /// 渠道默认登录方式即为 Google 登录
  @override
  Future<AuthResult<UserData>> signIn() => signInWithGoogle();

  /// 重写 Google 登录 (Android / Google Play 平台)
  @override
  Future<AuthResult<UserData>> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(
        serverClientId: serverClientId ??
            const String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID', defaultValue: ''),
        scopes: ['email', 'profile'],
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult.failure(
          AuthErrorCode.oauthFailed,
          '用户取消了 Google 登录',
        );
      }

      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null) {
        return AuthResult.failure(
          AuthErrorCode.oauthFailed,
          'Google 登录失败：未能获取 idToken',
        );
      }

      await client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      return await syncAndEmit();
    } catch (e, stack) {
      debugPrint('GoogleAuthService.signInWithGoogle failed: $e\n$stack');
      return AuthResult.failure(
        AuthErrorCode.oauthFailed,
        'Google 登录异常: $e',
      );
    }
  }
}
