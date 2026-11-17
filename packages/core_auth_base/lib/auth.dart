import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'model/auth_result.dart';
import 'model/user_data.dart';
import 'service/base_auth_service.dart';

export 'model/user_data.dart';
export 'model/entitlement_info.dart';
export 'model/auth_error_code.dart';
export 'model/auth_result.dart';
export 'service/base_auth_service.dart';

/// 默认基础认证服务实现 (仅包含 Supabase 原生能力，默认登录为匿名登录)
class DefaultAuthService extends BaseAuthService {
  DefaultAuthService({
    required super.client,
    required super.appId,
    super.debug = kDebugMode,
  });

  @override
  Future<AuthResult<UserData>> signIn() => signInAnonymously();
}

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

  /// 初始化全局认证单例（默认自动注入 [DefaultAuthService]）
  ///
  /// [debug] 默认跟随 [kDebugMode]：`true` 使用 `common_test`，`false` 使用 `common`。
  static void initialize({
    required SupabaseClient client,
    required String appId,
    bool debug = kDebugMode,
  }) {
    _instance = DefaultAuthService(
      client: client,
      appId: appId,
      debug: debug,
    );
  }

  /// 供渠道包（如 core_auth_apple / core_auth_google）内部注入自定义服务实例
  static void registerService(BaseAuthService service) {
    _instance = service;
  }

  /// 是否已初始化
  static bool get isInitialized => _instance != null;

  /// 获取当前已登录用户的全量业务档案
  static UserData? get currentUser => _impl.currentUser;

  /// 用户业务数据响应式流
  static Stream<UserData?> get userDataStream => _impl.userDataStream;

  /// 冷启动静默恢复已有会话（绝不隐式创建新账号）
  static Future<AuthResult<UserData>> restoreSession() =>
      _impl.restoreSession();

  /// 渠道默认一键登录 (基础包默认走匿名登录；渠道包对应 Apple / Google 登录)
  static Future<AuthResult<UserData>> signIn() => _impl.signIn();

  /// 匿名登录
  static Future<AuthResult<UserData>> signInAnonymously() =>
      _impl.signInAnonymously();

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
  static Future<AuthResult<UserData>> signInWithApple() =>
      _impl.signInWithApple();

  /// Google 登录 (由对应渠道包实现)
  static Future<AuthResult<UserData>> signInWithGoogle() =>
      _impl.signInWithGoogle();

  /// 主动刷新当前用户档案与权益
  static Future<AuthResult<UserData>> refreshProfile() =>
      _impl.refreshProfile();

  /// 带退避重试的档案刷新（用于支付或恢复购买后等待 Webhook 异步落库）
  static Future<AuthResult<UserData>> refreshProfileWithRetry({
    List<Duration> delays = const [
      Duration(milliseconds: 800),
      Duration(milliseconds: 1500),
      Duration(milliseconds: 2500),
    ],
  }) =>
      _impl.refreshProfileWithRetry(delays: delays);

  /// 退出登录
  static Future<void> signOut() => _impl.signOut();
}
