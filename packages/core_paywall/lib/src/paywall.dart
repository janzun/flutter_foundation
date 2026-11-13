import 'package:flutter/material.dart';

import 'controller/paywall_controller.dart';
import 'model/paywall_enums.dart';
import 'model/paywall_plan.dart';
import 'model/paywall_result.dart';
import 'model/paywall_strings.dart';
import 'model/paywall_theme.dart';
import 'templates/classic_paywall_view.dart';
import 'templates/consumable_paywall_view.dart';
import 'templates/single_purchase_sheet_view.dart';
import 'templates/timeline_paywall_view.dart';
import 'widgets/paywall_retention_dialog.dart';

/// 付费墙对外唯一门面入口。
class Paywall {
  Paywall._();

  /// 唤起付费墙，返回最终结果（`purchased` / `restored` / `dismissed`）。
  static Future<PaywallResult> show(
    BuildContext context, {
    required String placement,
    required List<PaywallPlan> plans,
    required PaywallLinks links,
    required PaywallPurchaseHandler onPurchase,
    PaywallRestoreHandler? onRestore,
    PaywallBeforePurchaseHook? onBeforePurchase,
    PaywallEventCallback? onEvent,
    PaywallTemplate template = PaywallTemplate.classic,
    PaywallPresentation presentation = PaywallPresentation.auto,
    PaywallChannel channel = PaywallChannel.overseas,
    PaywallStrings? strings,
    PaywallTheme theme = const PaywallTheme(),
    List<PaywallFeature> features = const [],
    String? initialSelectedPlanId,
    String? currentBalanceText,
    RetentionConfig? retentionConfig,
    WidgetBuilder? heroBuilder,
    WidgetBuilder? contentBuilder,
  }) async {
    assert(
      channel == PaywallChannel.overseas,
      'PaywallChannel.domestic is reserved and not yet implemented.',
    );

    final resolvedStrings = strings ?? PaywallStrings.en();
    final bool isBottomSheet = presentation == PaywallPresentation.bottomSheet ||
        (presentation == PaywallPresentation.auto &&
            (template == PaywallTemplate.consumable ||
                template == PaywallTemplate.singlePurchase));

    final controller = PaywallController(
      placement: placement,
      template: template,
      plans: plans,
      strings: resolvedStrings,
      onPurchase: onPurchase,
      onRestore: onRestore,
      onBeforePurchase: onBeforePurchase,
      onEvent: onEvent,
      retentionConfig: isBottomSheet ? null : retentionConfig,
      initialSelectedPlanId: initialSelectedPlanId,
    );

    PaywallResult? result;
    try {
      if (isBottomSheet) {
        result = await showModalBottomSheet<PaywallResult>(
          context: context,
          isScrollControlled: true,
          backgroundColor: theme.resolveBackground(context),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) => _PaywallHost(
            controller: controller,
            theme: theme,
            links: links,
            features: features,
            currentBalanceText: currentBalanceText,
            heroBuilder: heroBuilder,
            contentBuilder: contentBuilder,
          ),
        );
      } else {
        result = await Navigator.of(context, rootNavigator: true).push<PaywallResult>(
          MaterialPageRoute<PaywallResult>(
            fullscreenDialog: true,
            builder: (_) => Scaffold(
              body: _PaywallHost(
                controller: controller,
                theme: theme,
                links: links,
                features: features,
                currentBalanceText: currentBalanceText,
                heroBuilder: heroBuilder,
                contentBuilder: contentBuilder,
              ),
            ),
          ),
        );
      }
    } finally {
      controller.dispose();
    }

    return result ?? const PaywallResult(outcome: PaywallOutcome.dismissed);
  }
}

class _PaywallHost extends StatefulWidget {
  final PaywallController controller;
  final PaywallTheme theme;
  final PaywallLinks links;
  final List<PaywallFeature> features;
  final String? currentBalanceText;
  final WidgetBuilder? heroBuilder;
  final WidgetBuilder? contentBuilder;

  const _PaywallHost({
    required this.controller,
    required this.theme,
    required this.links,
    required this.features,
    this.currentBalanceText,
    this.heroBuilder,
    this.contentBuilder,
  });

  @override
  State<_PaywallHost> createState() => _PaywallHostState();
}

class _PaywallHostState extends State<_PaywallHost> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.controller.notifyShown();
    });
  }

  Future<void> _handlePurchase({PaywallPlan? overridePlan}) async {
    final result = await widget.controller.purchase(overridePlan: overridePlan);
    if (result != null && mounted) {
      Navigator.of(context).pop(result);
    }
  }

  Future<void> _handleRestore() async {
    final result = await widget.controller.restore();
    if (result != null && mounted) {
      Navigator.of(context).pop(result);
    }
  }

  Future<void> _handleClose() async {
    final ctrl = widget.controller;
    if (ctrl.isBusy) return;

    if (ctrl.canTriggerRetention) {
      ctrl.markRetentionShown();
      final accepted = await PaywallRetentionDialog.show(
        context,
        config: ctrl.retentionConfig!,
        theme: widget.theme,
      );
      if (!mounted) return;
      if (accepted) {
        final offerPlan = ctrl.retentionConfig!.offerPlan;
        ctrl.notifyRetentionAccepted(offerPlan);
        await _handlePurchase(overridePlan: offerPlan);
        return;
      }
    }

    ctrl.notifyDismissed();
    if (mounted) {
      Navigator.of(context).pop(
        const PaywallResult(outcome: PaywallOutcome.dismissed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleClose();
      },
      child: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          switch (widget.controller.template) {
            case PaywallTemplate.classic:
              return ClassicPaywallView(
                controller: widget.controller,
                theme: widget.theme,
                links: widget.links,
                features: widget.features,
                heroBuilder: widget.heroBuilder,
                onClose: _handleClose,
                onPurchase: _handlePurchase,
                onRestore: _handleRestore,
              );
            case PaywallTemplate.timeline:
              return TimelinePaywallView(
                controller: widget.controller,
                theme: widget.theme,
                links: widget.links,
                heroBuilder: widget.heroBuilder,
                onClose: _handleClose,
                onPurchase: _handlePurchase,
                onRestore: _handleRestore,
              );
            case PaywallTemplate.consumable:
              return ConsumablePaywallView(
                controller: widget.controller,
                theme: widget.theme,
                links: widget.links,
                currentBalanceText: widget.currentBalanceText,
                heroBuilder: widget.heroBuilder,
                onClose: _handleClose,
                onPurchase: _handlePurchase,
              );
            case PaywallTemplate.singlePurchase:
              return SinglePurchaseSheetView(
                controller: widget.controller,
                theme: widget.theme,
                links: widget.links,
                heroBuilder: widget.heroBuilder,
                contentBuilder: widget.contentBuilder,
                onClose: _handleClose,
                onPurchase: _handlePurchase,
                onRestore: _handleRestore,
              );
          }
        },
      ),
    );
  }
}
