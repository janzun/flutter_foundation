/// 标准预定义事件名称常量表 (EventNames)
///
/// 严格收敛命名空间，防止各端随意使用不同字符串导致数据仓库无法聚合统计。
abstract class EventNames {
  // 1. 生命周期 (全自动)
  static const String appInstall = 'app_install';
  static const String appLaunch = 'app_launch';
  static const String appShow = 'app_show';
  static const String appHide = 'app_hide';

  // 2. 页面浏览 (全自动)
  static const String pageView = 'page_view';

  // 3. 曝光 (手动)
  static const String paywallShow = 'paywall_show';
  static const String bannerShow = 'banner_show';
  static const String dialogShow = 'dialog_show';

  // 4. 用户交互 (手动)
  static const String clickPay = 'click_pay';
  static const String clickLogin = 'click_login';
  static const String clickShare = 'click_share';
  static const String featureUse = 'feature_use';

  // 5. 核心转化 (手动)
  static const String signupSuccess = 'signup_success';
  static const String loginSuccess = 'login_success';
  static const String paymentSuccess = 'payment_success';

  // 6. 异常与错误 (手动)
  static const String apiError = 'api_error';
  static const String paymentError = 'payment_error';
  static const String crash = 'crash';
}
