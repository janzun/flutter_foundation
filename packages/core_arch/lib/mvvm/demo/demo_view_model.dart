import 'package:freezed_annotation/freezed_annotation.dart';
import '../base_view_model.dart';

part 'demo_view_model.freezed.dart'; 
// 注意：编写完该文件后需要运行代码生成器： `flutter pub run build_runner build --delete-conflicting-outputs`

/// -------------------------------------------------------------------------
/// 1. 页面状态 (UI State)
/// -------------------------------------------------------------------------
/// 取代散落各处的变量状态，使用 Freezed 强制定义完全不可变的 UI 聚合状态。
/// implements BaseUiState 必须带上，以符合泛型要求。
@freezed
abstract class DemoUiState with _$DemoUiState implements BaseUiState {
  const factory DemoUiState({
    @Default(false) bool isLoading,     // 页面是否处于网络加载状态
    @Default('Guest') String username,  // 用户基础信息
    @Default(0) int counter,            // 点击计数器的值
  }) = _DemoUiState;
}

/// -------------------------------------------------------------------------
/// 2. 页面事件 (UI Event)
/// -------------------------------------------------------------------------
/// 您的建议非常棒！在 Dart 3.0 之后，对于不需要 `copyWith` 且仅用于模式匹配的 Event 类，
/// 强烈推荐使用原生的 `sealed class` (密封类)，它不仅不需要运行 build_runner 生成代码，
/// 还能在 switch 语句中实现完美的 exhaustiveness (穷尽性) 检查。
sealed class DemoUiEvent extends BaseUiEvent {
  const DemoUiEvent();
}

/// 发送纯文本 Toast 事件
class ShowToastEvent extends DemoUiEvent {
  final String message;
  const ShowToastEvent(this.message);
}

/// 通知跳转到登录页面
class NavigateToLoginEvent extends DemoUiEvent {
  const NavigateToLoginEvent();
}

/// -------------------------------------------------------------------------
/// 3. 视图模型 (ViewModel / Controller)
/// -------------------------------------------------------------------------
/// 继承自 BaseViewModel，并将上文定好的状态和事件范型注入。
class DemoViewModel extends BaseViewModel<DemoUiState, DemoUiEvent> {
  /// 初始化必须给与一个默认全量的 `DemoUiState`
  DemoViewModel() : super(const DemoUiState());

  /// ============================== 
  /// 生命周期事件重写
  /// ============================== 
  @override
  void onInit() {
    super.onInit();
    // 页面开启时自动被调用，非常适合在这里发起首屏网络请求
    _fetchUserInfo();
  }

  /// ============================== 
  /// 业务操作方法 (Public Actions)
  /// ============================== 
  
  /// 发起网络请求获取用户信息
  Future<void> _fetchUserInfo() async {
    // 1. 发射状态：显示 Loading 圈
    // 这里使用最新的 transform 模式进行局部更新
    updateUiState((state) => state.copyWith(isLoading: true));
    
    // 模拟网络请求耗时 2 秒钟
    await Future.delayed(const Duration(seconds: 2));
    
    // 2. 发射状态：关闭 Loading 圈，并成功更新了用户名
    updateUiState((state) => state.copyWith(
      isLoading: false,
      username: 'Flutter_GDE',
    ));
    
    // 3. 触发操作副作用：触发 Event 向外丢出一个单次的 Toast
    sendUiEvent(const ShowToastEvent('用户信息加载成功!'));
  }

  /// 点击浮动按钮行为：增加计数器数值
  void incrementCounter() {
    // 使用 transform 模式，确保基于最新状态累加，避免异步竞争问题
    updateUiState((state) => state.copyWith(
      counter: state.counter + 1,
    ));
  }

  /// 执行登出操作行为
  void logout() {
    // 触发操作副作用：发送页面跳转路由事件，交由 UI 层具体执行
    sendUiEvent(const NavigateToLoginEvent());
  }
}
