import 'dart:async';

/// 纯 Dart 轻量类型安全全局事件总线
class EventBus {
  EventBus._();

  static final StreamController<dynamic> _streamController =
      StreamController<dynamic>.broadcast();

  /// 发布事件
  static void emit<T>(T event) {
    if (!_streamController.isClosed) {
      _streamController.add(event);
    }
  }

  /// 订阅特定类型的事件流
  static Stream<T> on<T>() {
    if (T == dynamic) {
      return _streamController.stream as Stream<T>;
    }
    return _streamController.stream.where((event) => event is T).cast<T>();
  }

  /// 销毁（通常用于单元测试清理）
  static Future<void> destroy() async {
    await _streamController.close();
  }
}
