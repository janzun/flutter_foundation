import 'dart:async';

/// 纯 Dart 轻量类型安全全局事件总线
class EventBus {
  EventBus._();

  static StreamController<dynamic>? _streamController;

  static StreamController<dynamic> get _controller {
    if (_streamController == null || _streamController!.isClosed) {
      _streamController = StreamController<dynamic>.broadcast();
    }
    return _streamController!;
  }

  /// 发布事件
  static void emit<T>(T event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }

  /// 订阅特定类型的事件流
  static Stream<T> on<T>() {
    if (T == dynamic) {
      return _controller.stream as Stream<T>;
    }
    return _controller.stream.where((event) => event is T).cast<T>();
  }

  /// 销毁（支持按需关闭，后续调用会自动安全重建，杜绝永久失效）
  static Future<void> destroy() async {
    final c = _streamController;
    _streamController = null;
    if (c != null && !c.isClosed) {
      await c.close();
    }
  }
}
