import 'paywall_plan.dart';

/// 付费墙关闭后的最终结果。
enum PaywallOutcome {
  purchased,
  restored,
  dismissed,
}

/// 付费墙返回给调用方的结果实体。
class PaywallResult {
  final PaywallOutcome outcome;
  final PaywallPlan? plan;

  const PaywallResult({
    required this.outcome,
    this.plan,
  });

  bool get isPurchased => outcome == PaywallOutcome.purchased;
  bool get isRestored => outcome == PaywallOutcome.restored;
  bool get isDismissed => outcome == PaywallOutcome.dismissed;
}

/// App 执行实际支付/恢复后返回给 `core_paywall` 的结果协议。
class PaywallPurchaseResult {
  final bool success;
  final bool cancelled;
  final String? errorMessage;

  const PaywallPurchaseResult({
    required this.success,
    this.cancelled = false,
    this.errorMessage,
  });

  const PaywallPurchaseResult.success()
      : success = true,
        cancelled = false,
        errorMessage = null;

  const PaywallPurchaseResult.cancelled()
      : success = false,
        cancelled = true,
        errorMessage = null;

  const PaywallPurchaseResult.failed([this.errorMessage])
      : success = false,
        cancelled = false;
}
