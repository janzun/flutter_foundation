/// 用户与认证模块标准错误码常量
class AuthErrorCode {
  AuthErrorCode._();

  /// 成功
  static const int success = 0;

  /// 未授权或会话已过期，请重新登录
  static const int unauthorized = 20001;

  /// 账号已被封禁或注销
  static const int userBlocked = 20002;

  /// 应用未注册或已停用
  static const int appNotFound = 20003;

  /// 验证码错误或已过期
  static const int otpInvalid = 20004;

  /// 第三方账号授权或绑定失败
  static const int oauthFailed = 20005;

  /// 服务端或系统内部异常
  static const int internalError = 10500;
}
