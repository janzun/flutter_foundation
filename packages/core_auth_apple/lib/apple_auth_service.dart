import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:core_auth_base/auth.dart';

/// Apple 渠道专用的认证服务实现类 (原生 FaceID / TouchID 授权)
class AppleAuthService extends BaseAuthService {
  AppleAuthService({
    required super.client,
    required super.appId,
  });

  /// 渠道默认登录方式即为 Sign in with Apple
  @override
  Future<AuthResult<UserData>> signIn() => signInWithApple();

  /// 重写 Sign in with Apple (iOS 原生授权)
  @override
  Future<AuthResult<UserData>> signInWithApple() async {
    try {
      final rawNonce = client.auth.generateRawNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      if (credential.identityToken == null) {
        return AuthResult.failure(
          AuthErrorCode.oauthFailed,
          'Apple 登录失败：未能获取 identityToken',
        );
      }

      await client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: credential.identityToken!,
        nonce: rawNonce,
      );

      return await syncAndEmit();
    } on SignInWithAppleAuthorizationException catch (e, stack) {
      debugPrint('AppleAuthService.signInWithApple canceled or failed: $e\n$stack');
      return AuthResult.failure(
        AuthErrorCode.oauthFailed,
        '用户取消了 Apple 登录或授权异常',
      );
    } catch (e, stack) {
      debugPrint('AppleAuthService.signInWithApple failed: $e\n$stack');
      return AuthResult.failure(
        AuthErrorCode.oauthFailed,
        'Apple 登录异常: $e',
      );
    }
  }
}
