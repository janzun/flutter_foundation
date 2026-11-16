import 'package:core_auth_base/auth.dart' as base;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'apple_auth_service.dart';

export 'package:core_auth_base/auth.dart' hide Auth;
export 'apple_auth_service.dart';

/// Apple 渠道专属统一认证门面（默认自动注入 [AppleAuthService]）
class Auth {
  Auth._();

  /// 初始化全局认证单例（默认绑定 [AppleAuthService]）
  static void initialize({
    required SupabaseClient client,
    required String appId,
    base.BaseAuthService? service,
  }) =>
      base.Auth.initialize(
        service: service ??
            AppleAuthService(
              client: client,
              appId: appId,
            ),
      );

  static bool get isInitialized => base.Auth.isInitialized;
  static base.UserData? get currentUser => base.Auth.currentUser;
  static Stream<base.UserData?> get userDataStream => base.Auth.userDataStream;

  static Future<base.AuthResult<base.UserData>> autoLogin() =>
      base.Auth.autoLogin();
  static Future<base.AuthResult<base.UserData>> signIn() => base.Auth.signIn();
  static Future<base.AuthResult<base.UserData>> signInAnonymously() =>
      base.Auth.signInAnonymously();
  static Future<base.AuthResult<void>> sendEmailOtp({required String email}) =>
      base.Auth.sendEmailOtp(email: email);
  static Future<base.AuthResult<base.UserData>> signInWithEmailOtp({
    required String email,
    required String token,
  }) =>
      base.Auth.signInWithEmailOtp(email: email, token: token);
  static Future<base.AuthResult<base.UserData>> signInWithApple() =>
      base.Auth.signInWithApple();
  static Future<base.AuthResult<base.UserData>> signInWithGoogle() =>
      base.Auth.signInWithGoogle();
  static Future<base.AuthResult<base.UserData>> refreshProfile() =>
      base.Auth.refreshProfile();
  static Future<void> signOut() => base.Auth.signOut();
}
