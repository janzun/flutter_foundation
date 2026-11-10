import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// 网络连通状态感知工具
class NetworkConnectivity {
  NetworkConnectivity._();

  static final Connectivity _connectivity = Connectivity();

  /// 检查当前设备是否连接到可用网络（WiFi / 移动数据 / 以太网 / VPN）
  static Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return _hasValidConnection(results);
  }

  /// 检查当前详细连接类型列表
  static Future<List<ConnectivityResult>> get currentStatus async {
    return await _connectivity.checkConnectivity();
  }

  /// 监听网络连通性变化流（true: 有网, false: 断网）
  static Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(_hasValidConnection);
  }

  static bool _hasValidConnection(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    for (final result in results) {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet ||
          result == ConnectivityResult.vpn) {
        return true;
      }
    }
    return false;
  }
}
