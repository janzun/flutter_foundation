import 'package:flutter/material.dart';

import '../controller/paywall_controller.dart';
import '../model/paywall_plan.dart';
import '../model/paywall_theme.dart';
import '../widgets/paywall_legal_footer.dart';
import '../widgets/paywall_shared_parts.dart';

/// Free vs. Pro 极简权益对比模板（不玩文字游戏，直观展示免费与 Pro 差异）。
class ComparisonPaywallView extends StatelessWidget {
  final PaywallController controller;
  final PaywallTheme theme;
  final PaywallLinks links;
  final List<PaywallFeature> features;
  final WidgetBuilder? heroBuilder;
  final VoidCallback onClose;
  final VoidCallback onPurchase;
  final VoidCallback onRestore;

  const ComparisonPaywallView({
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
                      Text(
                        controller.strings.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      if (controller.strings.subtitle != null &&
                          controller.strings.subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          controller.strings.subtitle!,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: secondaryColor),
                        ),
                      ],
                      const SizedBox(height: 20),
                    ],
                    if (features.isNotEmpty) ...[
                      _ComparisonTable(
                        features: features,
                        primary: primary,
                        textColor: textColor,
                        secondaryColor: secondaryColor,
                        cardColor: theme.resolveCard(context),
                        borderColor: Theme.of(context).dividerColor,
                        cardRadius: theme.cardRadius,
                      ),
                      const SizedBox(height: 20),
                    ],
                    if (controller.isLoadingPlans)
                      PaywallPlansSkeleton(theme: theme)
                    else
                      for (final plan in controller.plans) ...[
                        _ComparisonPlanTile(
                          plan: plan,
                          selected: selected?.id == plan.id,
                          theme: theme,
                          onTap: () => controller.selectPlan(plan),
                        ),
                        const SizedBox(height: 10),
                      ],
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
                    enabled: selected != null && !controller.isRestoring,
                    theme: theme,
                    onPressed: onPurchase,
                  ),
                  const SizedBox(height: 10),
                  PaywallLegalFooter(
                    disclaimer: controller.resolvedLegalDisclaimer,
                    strings: controller.strings,
                    links: links,
                    theme: theme,
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

class _ComparisonTable extends StatelessWidget {
  final List<PaywallFeature> features;
  final Color primary;
  final Color textColor;
  final Color secondaryColor;
  final Color cardColor;
  final Color borderColor;
  final double cardRadius;

  const _ComparisonTable({
    required this.features,
    required this.primary,
    required this.textColor,
    required this.secondaryColor,
    required this.cardColor,
    required this.borderColor,
    required this.cardRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                const Expanded(child: SizedBox.shrink()),
                SizedBox(
                  width: 56,
                  child: Text(
                    'Free',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: secondaryColor,
                    ),
                  ),
                ),
                SizedBox(
                  width: 56,
                  child: Text(
                    'Pro',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: borderColor),
          for (int i = 0; i < features.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      features[i].text,
                      style: TextStyle(fontSize: 13, color: textColor),
                    ),
                  ),
                  SizedBox(
                    width: 56,
                    child: Center(
                      child: features[i].includedInFree
                          ? Icon(Icons.check_rounded, size: 18, color: secondaryColor)
                          : Text(
                              '—',
                              style: TextStyle(fontSize: 14, color: secondaryColor),
                            ),
                    ),
                  ),
                  SizedBox(
                    width: 56,
                    child: Center(
                      child: Icon(Icons.check_circle_rounded, size: 18, color: primary),
                    ),
                  ),
                ],
              ),
            ),
            if (i < features.length - 1) Divider(height: 1, color: borderColor),
          ],
        ],
      ),
    );
  }
}

class _ComparisonPlanTile extends StatelessWidget {
  final PaywallPlan plan;
  final bool selected;
  final PaywallTheme theme;
  final VoidCallback onTap;

  const _ComparisonPlanTile({
    required this.plan,
    required this.selected,
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? primary.withValues(alpha: 0.08)
              : theme.resolveCard(context),
          borderRadius: BorderRadius.circular(theme.cardRadius),
          border: Border.all(
            color: selected ? primary : Theme.of(context).dividerColor,
            width: selected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? primary : secondaryColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          plan.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                      if (plan.badgeText != null && plan.badgeText!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: primary,
                            borderRadius: BorderRadius.circular(6),
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
                      ],
                    ],
                  ),
                  if (plan.description != null && plan.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        plan.description!,
                        style: TextStyle(fontSize: 12, color: secondaryColor),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  plan.localizedPrice,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                if (plan.originalPrice != null && plan.originalPrice!.isNotEmpty)
                  Text(
                    plan.originalPrice!,
                    style: TextStyle(
                      fontSize: 11,
                      color: secondaryColor,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
