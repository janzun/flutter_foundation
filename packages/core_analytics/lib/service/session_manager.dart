import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

/// 会话 (Session) 生命周期管理器
///
/// 基于标准移动端 30 分钟后台超时滑动窗口机制：
/// 1. 冷启动时自动生成唯一的 [sessionId]。
/// 2. 当 App 切入后台（`AppLifecycleState.paused`）时记录时间戳。
/// 3. 当 App 切回前台（`AppLifecycleState.resumed`）时：
///    - 若切后台时间 < 30 分钟，继续沿用当前 [sessionId]；
///    - 若切后台时间 >= 30 分钟，判定为新的一轮使用会话，自动生成全新的 [sessionId]。
class SessionManager with WidgetsBindingObserver {
  SessionManager._();

  static final SessionManager instance = SessionManager._();

  String _sessionId = const Uuid().v4();
  DateTime? _lastPausedAt;
  static const Duration _sessionTimeout = Duration(minutes: 30);
  bool _isObserverAdded = false;

  /// 当前活跃的会话 ID
  String get sessionId => _sessionId;

  /// 初始化会话管理器并注册前后台生命周期监听
  void init() {
    if (!_isObserverAdded) {
      WidgetsBinding.instance.addObserver(this);
      _isObserverAdded = true;
    }
  }

  /// 开启新会话
  void refreshSession() {
    _sessionId = const Uuid().v4();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _lastPausedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_lastPausedAt != null) {
        final backgroundDuration = DateTime.now().difference(_lastPausedAt!);
        if (backgroundDuration >= _sessionTimeout) {
          // 超时唤醒，开启新会话
          refreshSession();
        }
      }
      _lastPausedAt = null;
    }
  }

  /// 释放监听器
  void dispose() {
    if (_isObserverAdded) {
      WidgetsBinding.instance.removeObserver(this);
      _isObserverAdded = false;
    }
  }
}
