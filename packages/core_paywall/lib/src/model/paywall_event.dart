import 'paywall_enums.dart';

/// 付费墙核心转化漏斗事件类型。
enum PaywallEventType {
  paywallShown,
  planSelected,
  purchaseClicked,
  purchaseSucceeded,
  purchaseFailed,
  restoreClicked,
  restoreSucceeded,
  restoreFailed,
  retentionShown,
  retentionAccepted,
  paywallDismissed,
}

/// 付费墙对外发射的标准转化事件，供 App 转发给埋点模块。
class PaywallEvent {
  final PaywallEventType type;
  final String placement;
  final PaywallTemplate template;
  final String? planId;
  final String? errorMessage;
  final Map<String, dynamic>? extra;

  const PaywallEvent({
    required this.type,
    required this.placement,
    required this.template,
    this.planId,
    this.errorMessage,
    this.extra,
  });
}
