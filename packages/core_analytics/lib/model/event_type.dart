/// 统一埋点规范的 6 大标准事件分类枚举
///
/// 对应 POST /v1/events 接口的 `event_type` 字段
enum EventType {
  /// 应用生命周期 (全自动：app_install, app_launch, app_show, app_hide)
  lifecycle('lifecycle'),

  /// 页面浏览 (全自动：带停留时长 duration_sec)
  pageView('page_view'),

  /// 弹窗/付费墙/Banner 曝光 (手动：转化率分母)
  impression('impression'),

  /// 用户交互动作 (手动：点击、切换、提交等)
  action('action'),

  /// 核心业务转化 (手动：注册成功、付款成功、导出完成等，默认立即直发)
  conversion('conversion'),

  /// 异常与故障错误 (手动：接口报错、支付失败等，默认立即直发)
  error('error');

  /// 接口网络请求与数据库存储的文本值
  final String value;

  const EventType(this.value);

  @override
  String toString() => value;
}
