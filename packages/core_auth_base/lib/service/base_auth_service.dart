import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/auth_error_code.dart';
import '../model/auth_result.dart';
import '../model/user_data.dart';
import 'user_sync_service.dart';

/// 认证与业务用户档案服务抽象基类
///
/// 托管底层 Supabase 认证生命周期、会话监听、`common` 数据表原子同步
/// 以及 [userDataStream] 响应式状态流。
abstract class BaseAuthService {
  /// SupabaseClient 客户端实例 (非空)
  final SupabaseClient client;

  /// 当前应用在 common.apps 中的唯一 UUID (非空)
  final String appId;

  /// 档案同步中枢 (非空)
  final UserSyncService syncService;

  final StreamController<UserData?> _userDataController =
      StreamController<UserData?>.broadcast();
  UserData? _currentUser;
  StreamSubscription<AuthState>? _authSubscription;

  BaseAuthService({
    required this.client,
    required this.appId,
  }) : syncService = UserSyncService(
          client: client,
          appId: appId,
        ) {
    _authSubscription = client.auth.onAuthStateChange.listen(_onAuthStateChanged);
  }

  /// 当前登录用户的全量业务档案 (内存只读快照，未登录为 null)
  UserData? get currentUser => _currentUser;

  /// 用户业务数据响应式流
  Stream<UserData?> get userDataStream => _userDataController.stream;

  /// 释放资源
  @mustCallSuper
  void dispose() {
    _authSubscription?.cancel();
    _userDataController.close();
  }

  // =========================================================================
  // 1. 通用内置实现 (所有渠道包自动继承)
  // =========================================================================

  /// 静默自动恢复登录态 (冷启动专属)
  ///
  /// 若用户此前已登录且 Session 有效，则自动拉取并刷新业务档案；
  /// 若用户尚未登录，则直接返回 [AuthErrorCode.unauthorized]，绝不隐式自动创建匿名账号。
  Future<AuthResult<UserData>> autoLogin() async {
    final currentSupabaseUser = client.auth.currentUser;
    if (currentSupabaseUser != null) {
      return await syncAndEmit();
    }
    return AuthResult.failure(AuthErrorCode.unauthorized, '当前未登录');
  }

  /// 匿名登录
  Future<AuthResult<UserData>> signInAnonymously() async {
    try {
      final res = await client.auth.signInAnonymously();
      if (res.user == null) {
        return AuthResult.failure(AuthErrorCode.internalError, '匿名登录失败：未能获取用户凭证');
      }
      return await syncAndEmit();
    } catch (e, stack) {
      debugPrint('BaseAuthService.signInAnonymously failed: $e\n$stack');
      return AuthResult.failure(AuthErrorCode.internalError, '匿名登录异常: $e');
    }
  }

  /// 发送邮箱 6 位动态验证码 (OTP)
  Future<AuthResult<void>> sendEmailOtp({required String email}) async {
    try {
      await client.auth.signInWithOtp(
        email: email.trim(),
        shouldCreateUser: true,
      );
      return AuthResult.success(null);
    } catch (e, stack) {
      debugPrint('BaseAuthService.sendEmailOtp(email: $email) failed: $e\n$stack');
      return AuthResult.failure(AuthErrorCode.otpInvalid, '发送验证码失败: $e');
    }
  }

  /// 邮箱验证码 (OTP) 登录 / 免密注册 (全自动处理转正或老账号登录)
  Future<AuthResult<UserData>> signInWithEmailOtp({
    required String email,
    required String token,
  }) async {
    try {
      final res = await client.auth.verifyOTP(
        email: email.trim(),
        token: token.trim(),
        type: OtpType.email,
      );
      if (res.user == null && client.auth.currentUser == null) {
        return AuthResult.failure(AuthErrorCode.otpInvalid, '邮箱验证码校验失败');
      }
      return await syncAndEmit();
    } catch (e, stack) {
      debugPrint('BaseAuthService.signInWithEmailOtp(email: $email) failed: $e\n$stack');
      return AuthResult.failure(AuthErrorCode.otpInvalid, '验证码错误或已过期');
    }
  }

  /// 主动刷新当前用户的业务档案、会员权益与积分余额
  Future<AuthResult<UserData>> refreshProfile() async {
    if (client.auth.currentUser == null) {
      _currentUser = null;
      _userDataController.add(null);
      return AuthResult.failure(AuthErrorCode.unauthorized, '当前未登录');
    }
    return await syncAndEmit();
  }

  /// 退出当前登录态
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e, stack) {
      debugPrint('BaseAuthService.signOut failed: $e\n$stack');
    } finally {
      _currentUser = null;
      _userDataController.add(null);
    }
  }

  // =========================================================================
  // 2. 待渠道包按需重写的虚方法 (默认返回未支持)
  // =========================================================================

  /// 渠道默认一键登录 (由具体渠道包重写，例如 Apple 登录、Google 登录或国内手机号一键登录)
  Future<AuthResult<UserData>> signIn() async =>
      AuthResult.failure(AuthErrorCode.oauthFailed, '当前渠道未实现默认登录方法');

  /// Sign in with Apple 登录 (由 core_auth_apple 重写)
  Future<AuthResult<UserData>> signInWithApple() async =>
      AuthResult.failure(AuthErrorCode.oauthFailed, '当前渠道未提供 Apple 登录实现');

  /// Google 登录 (由 core_auth_google 重写)
  Future<AuthResult<UserData>> signInWithGoogle() async =>
      AuthResult.failure(AuthErrorCode.oauthFailed, '当前渠道未提供 Google 登录实现');

  // =========================================================================
  // 3. 内部状态同步与辅助
  // =========================================================================

  /// 同步数据库档案并触发 [userDataStream] 广播
  @protected
  Future<AuthResult<UserData>> syncAndEmit() async {
    final result = await syncService.fetchUserProfile();
    if (result.isSuccess) {
      _currentUser = result.data;
      _userDataController.add(result.data);
    }
    return result;
  }

  void _onAuthStateChanged(AuthState state) {
    if (state.event == AuthChangeEvent.signedOut) {
      _currentUser = null;
      _userDataController.add(null);
    } else if (state.event == AuthChangeEvent.tokenRefreshed && state.session?.user != null) {
      syncAndEmit().catchError((e, stack) {
        debugPrint('BaseAuthService._onAuthStateChanged failed: $e\n$stack');
        return AuthResult<UserData>.failure(AuthErrorCode.internalError, '$e');
      });
    }
  }
}
