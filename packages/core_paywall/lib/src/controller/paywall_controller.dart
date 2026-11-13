import 'package:flutter/foundation.dart';

import '../model/paywall_enums.dart';
import '../model/paywall_event.dart';
import '../model/paywall_plan.dart';
import '../model/paywall_result.dart';
import '../model/paywall_strings.dart';

typedef PaywallPurchaseHandler = Future<PaywallPurchaseResult> Function(
  PaywallPlan plan,
);
typedef PaywallRestoreHandler = Future<PaywallPurchaseResult> Function();
typedef PaywallBeforePurchaseHook = Future<bool> Function(PaywallPlan plan);
typedef PaywallEventCallback = void Function(PaywallEvent event);

/// 付费墙状态、SKU 联动与合规逻辑控制器（可独立于 UI 使用）。
class PaywallController extends ChangeNotifier {
  final String placement;
  final PaywallTemplate template;
  final List<PaywallPlan> plans;
  final PaywallStrings strings;
  final PaywallPurchaseHandler onPurchase;
  final PaywallRestoreHandler? onRestore;
  final PaywallBeforePurchaseHook? onBeforePurchase;
  final PaywallEventCallback? onEvent;
  final RetentionConfig? retentionConfig;

  PaywallPlan? _selectedPlan;
  bool _isPurchasing = false;
  bool _isRestoring = false;
  String? _errorMessage;
  bool _retentionShown = false;

  PaywallController({
    required this.placement,
    required this.template,
    required this.plans,
    required this.strings,
    required this.onPurchase,
    this.onRestore,
    this.onBeforePurchase,
    this.onEvent,
    this.retentionConfig,
    String? initialSelectedPlanId,
  }) {
    if (plans.isNotEmpty) {
      if (initialSelectedPlanId != null) {
        _selectedPlan = plans.cast<PaywallPlan?>().firstWhere(
              (p) => p?.id == initialSelectedPlanId,
              orElse: () => plans.first,
            );
      } else {
        _selectedPlan = plans.first;
      }
    }
  }

  PaywallPlan? get selectedPlan => _selectedPlan;
  bool get isPurchasing => _isPurchasing;
  bool get isRestoring => _isRestoring;
  bool get isBusy => _isPurchasing || _isRestoring;
  String? get errorMessage => _errorMessage;
  bool get hasRetentionShown => _retentionShown;

  /// 是否应当显示恢复购买按钮（纯消耗型商品隐藏 Restore）
  bool get shouldShowRestore {
    if (onRestore == null) return false;
    final current = _selectedPlan;
    if (current != null && current.billingType == PlanBillingType.consumable) {
      return false;
    }
    return plans.any((p) => p.billingType != PlanBillingType.consumable);
  }

  /// 是否允许在关闭时触发挽留弹窗（每个生命周期最多 1 次）
  bool get canTriggerRetention =>
      !_retentionShown && retentionConfig != null && !isBusy;

  /// 根据当前选中 SKU 自动推导 CTA 按钮文案
  String get resolvedCtaText {
    final plan = _selectedPlan;
    if (plan == null) return strings.subscribeCtaPrefix;
    if (plan.ctaText != null && plan.ctaText!.isNotEmpty) {
      return plan.ctaText!;
    }
    switch (plan.billingType) {
      case PlanBillingType.autoRenewable:
        if (plan.hasTrial) {
          return strings.freeTrialCtaTemplate
              .replaceAll('{days}', '${plan.trialDays}');
        }
        return '${strings.subscribeCtaPrefix} · ${plan.localizedPrice}';
      case PlanBillingType.nonRenewing:
        return '${strings.nonRenewingCtaPrefix} · ${plan.localizedPrice}';
      case PlanBillingType.lifetime:
        return '${strings.lifetimeCtaPrefix} · ${plan.localizedPrice}';
      case PlanBillingType.consumable:
        return '${strings.consumableCtaPrefix} · ${plan.localizedPrice}';
    }
  }

  /// 根据当前选中 SKU 自动推导底部合规免责声明
  String get resolvedLegalDisclaimer {
    final plan = _selectedPlan;
    if (plan == null) return strings.autoRenewDisclaimer;
    switch (plan.billingType) {
      case PlanBillingType.autoRenewable:
        if (plan.hasTrial) {
          return strings.trialDisclaimerTemplate
              .replaceAll('{days}', '${plan.trialDays}')
              .replaceAll('{price}', plan.localizedPrice);
        }
        return strings.autoRenewDisclaimer;
      case PlanBillingType.nonRenewing:
        return strings.nonRenewingDisclaimer;
      case PlanBillingType.lifetime:
        return strings.lifetimeDisclaimer;
      case PlanBillingType.consumable:
        return strings.consumableDisclaimer;
    }
  }

  void notifyShown() {
    _emit(PaywallEventType.paywallShown, planId: _selectedPlan?.id);
  }

  void selectPlan(PaywallPlan plan) {
    if (isBusy || _selectedPlan?.id == plan.id) return;
    _selectedPlan = plan;
    _errorMessage = null;
    notifyListeners();
    _emit(PaywallEventType.planSelected, planId: plan.id);
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  /// 执行购买（支持指定替代方案，如挽留弹窗里的优惠 SKU）
  Future<PaywallResult?> purchase({PaywallPlan? overridePlan}) async {
    final plan = overridePlan ?? _selectedPlan;
    if (plan == null || isBusy) return null;

    _errorMessage = null;
    _isPurchasing = true;
    notifyListeners();
    _emit(PaywallEventType.purchaseClicked, planId: plan.id);

    try {
      if (onBeforePurchase != null) {
        final shouldContinue = await onBeforePurchase!(plan);
        if (!shouldContinue) {
          return null;
        }
      }

      final res = await onPurchase(plan);
      if (res.success) {
        _emit(PaywallEventType.purchaseSucceeded, planId: plan.id);
        return PaywallResult(outcome: PaywallOutcome.purchased, plan: plan);
      }

      if (!res.cancelled) {
        _errorMessage = res.errorMessage ?? 'Purchase failed';
        _emit(
          PaywallEventType.purchaseFailed,
          planId: plan.id,
          errorMessage: _errorMessage,
        );
      }
      return null;
    } catch (e) {
      _errorMessage = e.toString();
      _emit(
        PaywallEventType.purchaseFailed,
        planId: plan.id,
        errorMessage: _errorMessage,
      );
      return null;
    } finally {
      _isPurchasing = false;
      notifyListeners();
    }
  }

  Future<PaywallResult?> restore() async {
    if (onRestore == null || isBusy) return null;

    _errorMessage = null;
    _isRestoring = true;
    notifyListeners();
    _emit(PaywallEventType.restoreClicked);

    try {
      final res = await onRestore!();
      if (res.success) {
        _emit(PaywallEventType.restoreSucceeded);
        return const PaywallResult(outcome: PaywallOutcome.restored);
      }
      if (!res.cancelled) {
        _errorMessage = res.errorMessage ?? 'Restore failed';
        _emit(
          PaywallEventType.restoreFailed,
          errorMessage: _errorMessage,
        );
      }
      return null;
    } catch (e) {
      _errorMessage = e.toString();
      _emit(
        PaywallEventType.restoreFailed,
        errorMessage: _errorMessage,
      );
      return null;
    } finally {
      _isRestoring = false;
      notifyListeners();
    }
  }

  void markRetentionShown() {
    _retentionShown = true;
    _emit(PaywallEventType.retentionShown, planId: _selectedPlan?.id);
  }

  void notifyRetentionAccepted(PaywallPlan? offerPlan) {
    _emit(PaywallEventType.retentionAccepted, planId: offerPlan?.id);
  }

  void notifyDismissed() {
    _emit(PaywallEventType.paywallDismissed, planId: _selectedPlan?.id);
  }

  void _emit(
    PaywallEventType type, {
    String? planId,
    String? errorMessage,
  }) {
    onEvent?.call(
      PaywallEvent(
        type: type,
        placement: placement,
        template: template,
        planId: planId,
        errorMessage: errorMessage,
      ),
    );
  }
}
