import 'package:flutter/material.dart';

import '../controller/paywall_controller.dart';
import '../model/paywall_plan.dart';
import '../model/paywall_theme.dart';
import '../widgets/paywall_legal_footer.dart';
import '../widgets/paywall_shared_parts.dart';

/// 单品直购紧凑弹窗模板（支持 `contentBuilder` / `heroBuilder` 外部自定义内容插槽）。
class SinglePurchaseSheetView extends StatelessWidget {
  final PaywallController controller;
  final PaywallTheme theme;
  final PaywallLinks links;
  final WidgetBuilder? heroBuilder;
  final WidgetBuilder? contentBuilder;
  final VoidCallback onClose;
  final VoidCallback onPurchase;
  final VoidCallback onRestore;

  const SinglePurchaseSheetView({
    super.key,
    required this.controller,
    required this.theme,
    required this.links,
    this.heroBuilder,
    this.contentBuilder,
    required this.onClose,
    required this.onPurchase,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = theme.resolveText(context);
    final secondaryColor = theme.resolveSecondaryText(context);
    final primary = theme.resolvePrimary(context);
    final plan = controller.selectedPlan;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (heroBuilder != null)
                  heroBuilder!(context)
                else
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.bolt_rounded, color: primary, size: 26),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan?.title ?? controller.strings.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      if (plan?.description != null ||
                          controller.strings.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          plan?.description ?? controller.strings.subtitle!,
                          style: TextStyle(
                            fontSize: 13,
                            color: secondaryColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: controller.isBusy ? null : onClose,
                  icon: Icon(Icons.close_rounded, color: secondaryColor),
                ),
              ],
            ),
            if (contentBuilder != null) ...[
              const SizedBox(height: 16),
              contentBuilder!(context),
            ] else if (plan?.specificPerks != null &&
                plan!.specificPerks!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.resolveCard(context),
                  borderRadius: BorderRadius.circular(theme.cardRadius),
                ),
                child: Column(
                  children: plan.specificPerks!
                      .map(
                        (perk) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Icon(Icons.check_rounded, size: 18, color: primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  perk,
                                  style: TextStyle(fontSize: 13, color: textColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
            const SizedBox(height: 18),
            PaywallErrorBanner(message: controller.errorMessage),
            PaywallCtaButton(
              label: controller.resolvedCtaText,
              isLoading: controller.isPurchasing,
              enabled: plan != null,
              theme: theme,
              onPressed: onPurchase,
            ),
            const SizedBox(height: 10),
            PaywallLegalFooter(
              disclaimer: controller.resolvedLegalDisclaimer,
              strings: controller.strings,
              links: links,
              theme: theme,
              showRestore: controller.shouldShowRestore,
              isRestoring: controller.isRestoring,
              onRestore: onRestore,
            ),
          ],
        ),
      ),
    );
  }
}
