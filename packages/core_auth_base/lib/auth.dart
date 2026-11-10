import 'package:supabase_flutter/supabase_flutter.dart';
import 'model/auth_result.dart';
import 'model/user_data.dart';
import 'service/base_auth_service.dart';

export 'model/user_data.dart';
export 'model/entitlement_info.dart';
export 'model/auth_error_code.dart';
export 'model/auth_result.dart';
export 'service/base_auth_service.dart';

/// 默认基础认证服务实现 (仅包含 Supabase 原生能力)
class DefaultAuthService extends BaseAuthService {
  DefaultAuthService({
    required super.client,
    required super.appId,
  });
}

/// 基础顶层工厂函数 (提供通用兜底)
BaseAuthService createAuthService({
  required SupabaseClient client,
  required String appId,
}) =>
    DefaultAuthService(
      client: client,
      appId: appId,
    );

/// 全局统一认证与用户中枢门面 (Auth)
class Auth {
  Auth._();

  static BaseAuthService? _instance;

  static BaseAuthService get _impl {
    if (_instance == null) {
      throw StateError('Auth 尚未初始化，请先调用 Auth.initialize()');
    }
    return _instance!;
  }

  /// 初始化全局认证单例 (自动调用当前渠道包的 createAuthService 工厂)
  static void initialize({
    required SupabaseClient client,
    required String appId,
  }) {
    _instance = createAuthService(
      client: client,
      appId: appId,
    );
  }

  /// 获取当前已登录用户的全量业务档案
  static UserData? get currentUser => _impl.currentUser;

  /// 用户业务数据响应式流
  static Stream<UserData?> get userDataStream => _impl.userDataStream;

  /// 冷启动静默自动登录
  static Future<AuthResult<UserData>> autoLogin() => _impl.autoLogin();

  /// 渠道默认一键登录 (根据当前依赖的渠道包执行对应的原生登录，如 Apple / Google)
  static Future<AuthResult<UserData>> signIn() => _impl.signIn();

  /// 匿名登录
  static Future<AuthResult<UserData>> signInAnonymously() => _impl.signInAnonymously();

  /// 发送邮箱 6 位动态验证码
  static Future<AuthResult<void>> sendEmailOtp({required String email}) =>
      _impl.sendEmailOtp(email: email);

  /// 邮箱验证码登录 / 免密注册
  static Future<AuthResult<UserData>> signInWithEmailOtp({
    required String email,
    required String token,
  }) =>
      _impl.signInWithEmailOtp(email: email, token: token);

  /// Apple 登录 (由对应渠道包实现)
  static Future<AuthResult<UserData>> signInWithApple() => _impl.signInWithApple();

  /// Google 登录 (由对应渠道包实现)
  static Future<AuthResult<UserData>> signInWithGoogle() => _impl.signInWithGoogle();

  /// 主动刷新当前用户档案与权益
  static Future<AuthResult<UserData>> refreshProfile() => _impl.refreshProfile();

  /// 退出登录
  static Future<void> signOut() => _impl.signOut();
}
