import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../model/analytics_event.dart';

/// 内存事件调度与批量上报队列
///
/// 核心特性：
/// 1. 批量上限 30 条切片，符合网关协议；
/// 2. 批量阈值 (默认 20 条) 触发；
/// 3. 定时调度 (默认 15s) 轮询；
/// 4. 生命周期 (App 切入后台) 强制清空上报防丢；
/// 5. 弱网异常时保留在队列等待重试。
class EventQueue with WidgetsBindingObserver {
  final String endpoint;
  final int batchSize;
  final Duration flushInterval;

  final List<AnalyticsEvent> _queue = [];
  Timer? _timer;
  bool _isFlushing = false;
  bool _isDisposed = false;

  EventQueue({
    required this.endpoint,
    this.batchSize = 20,
    this.flushInterval = const Duration(seconds: 15),
  });

  /// 启动定时器与生命周期监听
  void start() {
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
  }

  /// 事件入队
  void enqueue(AnalyticsEvent event, {bool isImmediate = false}) {
    if (_isDisposed) return;
    _queue.add(event);

    // 核心转化/错误或达到批量阈值立即触发上报
    if (isImmediate || _queue.length >= batchSize) {
      flush();
    }
  }

  /// 立即清空并批量上报
  Future<void> flush() async {
    if (_isFlushing || _queue.isEmpty || _isDisposed) return;

    _isFlushing = true;
    
    // 动态计算批次：同时满足最多 30 条且 UTF-8 Payload < 100KB (低于网关 128KB 限制)
    const int maxPayloadBytes = 100 * 1024;
    const int maxBatchItems = 30;

    final List<AnalyticsEvent> batchToSend = [];
    int currentBytes = 2; // '[]'.length = 2

    for (int i = 0; i < _queue.length && batchToSend.length < maxBatchItems; i++) {
      final jsonMap = _queue[i].toJson();
      final itemStr = jsonEncode(jsonMap);
      final itemBytes = utf8.encode(itemStr).length + (batchToSend.isNotEmpty ? 1 : 0);

      // 单条若超 100KB 视为异常数据丢弃，避免队列永久堵塞
      if (batchToSend.isEmpty && itemBytes > maxPayloadBytes) {
        debugPrint('[Analytics] Single event exceeds 100KB limit, dropping.');
        _queue.removeAt(i);
        i--;
        continue;
      }

      if (currentBytes + itemBytes > maxPayloadBytes) {
        break;
      }

      batchToSend.add(_queue[i]);
      currentBytes += itemBytes;
    }

    if (batchToSend.isEmpty) {
      _isFlushing = false;
      return;
    }

    try {
      final payload = batchToSend.map((e) => e.toJson()).toList();

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 8));

      // 接口返回 200/202 视为成功
      if (response.statusCode == 200 || response.statusCode == 202) {
        _queue.removeRange(0, batchToSend.length);
      }
    } catch (e) {
      debugPrint('[Analytics] flush failed (network/server): $e');
    } finally {
      _isFlushing = false;
      // 若还有积压，继续处理下一批
      if (_queue.length >= batchSize) {
        flush();
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(flushInterval, (_) => flush());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      flush(); // 切后台强制上报
    }
  }

  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }
}
