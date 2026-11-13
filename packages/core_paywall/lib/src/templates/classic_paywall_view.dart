import 'package:flutter/material.dart';

import '../controller/paywall_controller.dart';
import '../model/paywall_plan.dart';
import '../model/paywall_theme.dart';
import '../widgets/paywall_legal_footer.dart';
import '../widgets/paywall_shared_parts.dart';

/// 经典多套餐高转化模板（支持混合 SKU：订阅 + 终身买断联动切换）。
class ClassicPaywallView extends StatelessWidget {
  final PaywallController controller;
  final PaywallTheme theme;
  final PaywallLinks links;
  final List<PaywallFeature> features;
  final WidgetBuilder? heroBuilder;
  final VoidCallback onClose;
  final VoidCallback onPurchase;
  final VoidCallback onRestore;

  const ClassicPaywallView({
    super.key,
    required this.controller,
    required this.theme,
    required this.links,
    required this.features,
    this.heroBuilder,
    required this.onClose,
    required this.onPurchase,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = theme.resolveText(context);
    final secondaryColor = theme.resolveSecondaryText(context);
    final primary = theme.resolvePrimary(context);
    final selected = controller.selectedPlan;

    // 优先展示单品独有权益，否则回退全局权益列表
    final List<PaywallFeature> displayFeatures =
        (selected?.specificPerks != null && selected!.specificPerks!.isNotEmpty)
            ? selected.specificPerks!
                .map((e) => PaywallFeature(icon: Icons.check_circle_rounded, text: e))
                .toList()
            : features;

    return Container(
      color: theme.resolveBackground(context),
      child: SafeArea(
        child: Column(
          children: [
            PaywallTopBar(
              controller: controller,
              theme: theme,
              onClose: onClose,
              onRestore: onRestore,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (heroBuilder != null) ...[
                      heroBuilder!(context),
                      const SizedBox(height: 16),
                    ] else ...[
                      Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.workspace_premium_rounded,
                            size: 34,
                            color: primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      controller.strings.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    if (controller.strings.subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        controller.strings.subtitle!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: secondaryColor),
                      ),
                    ],
                    if (displayFeatures.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      ...displayFeatures.map(
                        (f) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Icon(
                                f.icon ?? Icons.check_circle_rounded,
                                size: 20,
                                color: primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  f.text,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: textColor,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (controller.plans.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          controller.strings.emptyPlansText,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: secondaryColor),
                        ),
                      )
                    else
                      ...controller.plans.map(
                        (plan) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _PlanCard(
                            plan: plan,
                            isSelected: selected?.id == plan.id,
                            theme: theme,
                            onTap: () => controller.selectPlan(plan),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PaywallErrorBanner(message: controller.errorMessage),
                  PaywallCtaButton(
                    label: controller.resolvedCtaText,
                    isLoading: controller.isPurchasing,
                    enabled: selected != null,
                    theme: theme,
                    onPressed: onPurchase,
                  ),
                  const SizedBox(height: 12),
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
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final PaywallPlan plan;
  final bool isSelected;
  final PaywallTheme theme;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = theme.resolvePrimary(context);
    final textColor = theme.resolveText(context);
    final secondaryColor = theme.resolveSecondaryText(context);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.resolveSelectedCard(context)
                  : theme.resolveCard(context),
              borderRadius: BorderRadius.circular(theme.cardRadius),
              border: Border.all(
                color: isSelected
                    ? primary
                    : secondaryColor.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected ? primary : secondaryColor,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      if (plan.description != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          plan.description!,
                          style: TextStyle(fontSize: 12, color: secondaryColor),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (plan.originalPrice != null) ...[
                          Text(
                            plan.originalPrice!,
                            style: TextStyle(
                              fontSize: 12,
                              color: secondaryColor,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          plan.localizedPrice,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    if (plan.pricePerUnitText != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        plan.pricePerUnitText!,
                        style: TextStyle(fontSize: 11, color: secondaryColor),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (plan.badgeText != null)
            Positioned(
              top: -9,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.resolveBadge(context),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  plan.badgeText!,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: theme.resolveBadgeText(context),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
