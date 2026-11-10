import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../mvvm/view_state.dart';

/// 配合 [ViewState] 的标准化页面四态/五态渲染容器
class StateLoadWidget extends StatelessWidget {
  /// 当前视图状态
  final ViewState viewState;

  /// 状态为 success 或 idle 时渲染的正常业务内容
  final WidgetBuilder contentBuilder;

  /// 空数据时的自定义文案
  final String emptyText;

  /// 出错时的自定义文案
  final String errorText;

  /// 错误状态下的点击重试回调（若提供则自动展示重试按钮）
  final VoidCallback? onRetry;

  /// 自定义加载中组件
  final Widget? loadingWidget;

  /// 自定义空数据组件
  final Widget? emptyWidget;

  /// 自定义错误组件
  final Widget? errorWidget;

  const StateLoadWidget({
    super.key,
    required this.viewState,
    required this.contentBuilder,
    this.emptyText = '暂无相关数据',
    this.errorText = '数据加载失败，请稍后重试',
    this.onRetry,
    this.loadingWidget,
    this.emptyWidget,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return switch (viewState) {
      ViewState.loading => loadingWidget ?? _defaultLoading(),
      ViewState.empty => emptyWidget ?? _defaultEmpty(),
      ViewState.error => errorWidget ?? _defaultError(),
      ViewState.idle || ViewState.success => contentBuilder(context),
    };
  }

  Widget _defaultLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _defaultEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            emptyText,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _defaultError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text(
              errorText,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onRetry?.call();
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('点击重试'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
