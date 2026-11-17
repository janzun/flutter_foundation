import 'package:core_auth_base/auth.dart' as base;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'google_auth_service.dart';

export 'package:core_auth_base/auth.dart' hide Auth;
export 'google_auth_service.dart';

/// Google 渠道专属统一认证门面（默认自动注入 [GoogleAuthService]）
class Auth {
  Auth._();

  /// 初始化全局认证单例（默认绑定 [GoogleAuthService]）
  ///
  /// [debug] 默认跟随 [kDebugMode]：`true` 使用 `common_test`，`false` 使用 `common`。
  static void initialize({
    required SupabaseClient client,
    required String appId,
    bool debug = kDebugMode,
    String? serverClientId,
  }) =>
      base.Auth.registerService(
        GoogleAuthService(
          client: client,
          appId: appId,
          debug: debug,
          serverClientId: serverClientId,
        ),
      );

  static bool get isInitialized => base.Auth.isInitialized;
  static base.UserData? get currentUser => base.Auth.currentUser;
  static Stream<base.UserData?> get userDataStream => base.Auth.userDataStream;

  static Future<base.AuthResult<base.UserData>> restoreSession() =>
      base.Auth.restoreSession();
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
  static Future<base.AuthResult<base.UserData>> refreshProfileWithRetry({
    List<Duration> delays = const [
      Duration(milliseconds: 800),
      Duration(milliseconds: 1500),
      Duration(milliseconds: 2500),
    ],
  }) =>
      base.Auth.refreshProfileWithRetry(delays: delays);
  static Future<void> signOut() => base.Auth.signOut();
}
