import 'dart:async';
import 'package:flutter/foundation.dart';

/// -------------------------------------------------------------------------
/// [BaseUiState] - 页面状态基类
/// -------------------------------------------------------------------------
/// 在现代单向数据流 (UDF) 架构中，UI 被视为当前状态的字面映射：
/// UI = f(State)
/// 
/// 该基类应当被子类继承，用于承载页面的所有持久化状态。
/// 
/// 【最佳实践】：
/// 1. 推荐配合 `Freezed` 插件使用，确保状态的不可变性 (Immutability)。
/// 2. 状态更新应当通过 `copyWith` 创建新实例，而非修改原有属性。
abstract class BaseUiState {
  const BaseUiState();
}

/// -------------------------------------------------------------------------
/// [BaseUiEvent] - UI 一次性事件基类 (Side Effect)
/// -------------------------------------------------------------------------
/// 用于处理那些不属于持久状态、只需执行一次的“副作用”操作。
/// 典型场景：弹窗 (Dialog/Toast)、页面跳转 (Navigation)、SnackBar 提示。
/// 
/// 【设计意图】：
/// 将“状态 (持久存留)”与“事件 (瞬时触发)”剥离，可以有效避免由热重载或 Widget 树重建
/// 导致的逻辑重复执行（如：重建时重复弹出上次的错误提示）。
/// 
/// 【最佳实践】：
/// 在子类中推荐使用 Dart 3 的 `sealed class` 配合模式匹配 (Switch Case) 进行消费处理。
abstract class BaseUiEvent {
  const BaseUiEvent();
}

/// -------------------------------------------------------------------------
/// [BaseViewModel] - 视图模型基类 (Architectural Core)
/// -------------------------------------------------------------------------
/// 它是 UI 与业务逻辑的桥接器，基于 `ChangeNotifier` 与 `Provider` 构建。
/// 旨在提供类似于现代 Android 开发中 ViewModel + StateFlow + SharedFlow 的开发体验。
///
/// 泛型参数说明：
/// - [S] 指定绑定的页面状态模型，需继承自 [BaseUiState]。
/// - [E] 指定下发的一次性事件流，需继承自 [BaseUiEvent]。
abstract class BaseViewModel<S extends BaseUiState, E extends BaseUiEvent>
    extends ChangeNotifier {
  
  /// 内部管理的绝对聚合状态
  S _uiState;

  /// 暴露给外部 (UI 层) 的只读状态路径。
  /// UI 层应通过 `context.watch<T>().uiState` 或 `Consumer<T>` 进行响应式监听。
  S get uiState => _uiState;

  /// 处理瞬时交互的事件总线 (采用 Broadcast廣播流，支持热重载与多处监听适配)
  final StreamController<E> _uiEventController = StreamController<E>.broadcast();

  /// (内部) 提供给监听机制的基础流
  @visibleForTesting
  Stream<E> get uiEventStream => _uiEventController.stream;

  /// 内部托管的订阅凭证池
  /// 用于在 ViewModel 销毁时利用生命周期钩子自动清理，无需 UI 层干预。
  final List<StreamSubscription<E>> _eventSubscriptions = [];

  /// 构造函数，要求子类必须传入初始状态。
  BaseViewModel(S initialState) : _uiState = initialState {
    onInit();
  }

  /// 初始化钩子方法
  /// 该方法在 ViewModel 的构造函数中同步调用。
  /// 
  /// 【严格警告】：
  /// **绝不**在此方法中执行任何耗时操作（如网络请求、I/O、数据库查询、通道通信等）！
  /// 构造函数内的同步耗时操作会直接阻塞主线程，导致页面推入（路由转场）动画严重卡顿掉帧。
  /// 
  /// 对于首屏需要拉取的网络请求或耗时的本地配置初始化，请在具体的 Screen 页面
  /// 的 `initState` 中，利用 `WidgetsBinding.instance.addPostFrameCallback`
  /// 确保在首帧渲染完成后，再显式调用 ViewModel 的专门初始化方法（如 `initData()`）。
  @protected
  void onInit() {}

  /// -----------------------------------------------------------------------
  /// 核心机制：事件监听 (Event Subscribing)
  /// -----------------------------------------------------------------------

  /// 在 UI 层 (推荐在 `initState`) 中注入监听器。
  ///
  /// 【核心优势】：
  /// 通过此方法注册的监听，其订阅生命周期完全交由 [BaseViewModel] 内部托管。
  /// 当 Provider 随 Widget 树卸载时，会自动执行 cancel()，彻底规避内存泄漏。
  void listenEvent(void Function(E event) onEvent) {
    if (_uiEventController.isClosed) return;
    _eventSubscriptions.add(_uiEventController.stream.listen(onEvent));
  }

  /// -----------------------------------------------------------------------
  /// 核心机制：状态更新 (State Mutation)
  /// -----------------------------------------------------------------------

  /// 更新页面状态并触发 UI 重绘 (采用 Transform / Reducer 变换模式)
  ///
  /// 该方法接收一个转换闭包，该闭包接收当前最新状态快照并生成新状态。
  /// 
  /// 【核心价值】：
  /// 原子化更新。即使在高度复杂的异步/并发场景下，也能确保状态演进是基于实时内存快照的，
  /// 从而彻底预防传统赋值模式下常见的“竞态条件 (Race Condition)”导致的状态覆盖问题。
  ///
  /// 示例：
  /// ```dart
  /// updateUiState((state) => state.copyWith(count: state.count + 1));
  /// ```
  @protected
  void updateUiState(S Function(S state) transform) {
    final newState = transform(_uiState);
    
    // 执行深度比对 (需子类重写 ==)，若状态未变化则跳过通知，优化刷新频率
    if (_uiState == newState) return;

    _uiState = newState;
    // 通知 Provider 包裹的 UI 节点进行重建
    notifyListeners();
  }

  /// -----------------------------------------------------------------------
  /// 核心机制：事件派发 (Event Emitting)
  /// -----------------------------------------------------------------------

  /// 向 UI 层发射一个单次触发的一次性事件。
  ///
  /// 示例：
  /// ```dart
  /// sendUiEvent(const ShowToastEvent("操作成功"));
  /// ```
  @protected
  void sendUiEvent(E event) {
    if (!_uiEventController.isClosed) {
      _uiEventController.add(event);
    }
  }

  /// -----------------------------------------------------------------------
  /// 生命周期：资源释放
  /// -----------------------------------------------------------------------

  @override
  @mustCallSuper
  void dispose() {
    // 1. 自动清理所有托管的事件订阅，无需 UI 层在 dispose 中调用 cancel
    for (var sub in _eventSubscriptions) {
      sub.cancel();
    }
    _eventSubscriptions.clear();
    
    // 2. 销毁事件流控制器，防止管道残留
    _uiEventController.close();
    
    super.dispose();
  }
}