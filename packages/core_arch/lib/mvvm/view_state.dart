/// 标准页面视图状态枚举
enum ViewState {
  /// 初始空闲状态
  idle,

  /// 正在加载中
  loading,

  /// 空数据状态
  empty,

  /// 发生异常或错误
  error,

  /// 成功且有数据
  success;

  bool get isIdle => this == ViewState.idle;
  bool get isLoading => this == ViewState.loading;
  bool get isEmpty => this == ViewState.empty;
  bool get isError => this == ViewState.error;
  bool get isSuccess => this == ViewState.success;
}
