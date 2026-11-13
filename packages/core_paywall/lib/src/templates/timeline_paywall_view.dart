import 'package:flutter/material.dart';

import '../controller/paywall_controller.dart';
import '../model/paywall_plan.dart';
import '../model/paywall_theme.dart';
import '../widgets/paywall_legal_footer.dart';
import '../widgets/paywall_shared_parts.dart';

/// 3 步透明试用时间轴模板（专为带试用订阅、Onboarding 结束页设计）。
class TimelinePaywallView extends StatelessWidget {
  final PaywallController controller;
  final PaywallTheme theme;
  final PaywallLinks links;
  final WidgetBuilder? heroBuilder;
  final VoidCallback onClose;
  final VoidCallback onPurchase;
  final VoidCallback onRestore;

  const TimelinePaywallView({
    super.key,
    required this.controller,
    required this.theme,
    required this.links,
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
    final strings = controller.strings;

    final step3Subtitle = strings.timelineStep3SubtitleTemplate
        .replaceAll('{price}', selected?.localizedPrice ?? '');

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
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (heroBuilder != null) ...[
                      heroBuilder!(context),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      strings.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    if (strings.subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        strings.subtitle!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: secondaryColor),
                      ),
                    ],
                    const SizedBox(height: 28),
                    _TimelineStep(
                      icon: Icons.lock_open_rounded,
                      title: strings.timelineStep1Title,
                      subtitle: strings.timelineStep1Subtitle,
                      theme: theme,
                      isFirst: true,
                    ),
                    _TimelineStep(
                      icon: Icons.notifications_active_rounded,
                      title: strings.timelineStep2Title,
                      subtitle: strings.timelineStep2Subtitle,
                      theme: theme,
                    ),
                    _TimelineStep(
                      icon: Icons.star_rounded,
                      title: strings.timelineStep3Title,
                      subtitle: step3Subtitle,
                      theme: theme,
                      isLast: true,
                    ),
                    if (controller.plans.length > 1) ...[
                      const SizedBox(height: 20),
                      Row(
                        children: controller.plans.map((plan) {
                          final isSelected = selected?.id == plan.id;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: GestureDetector(
                                onTap: () => controller.selectPlan(plan),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? theme.resolveSelectedCard(context)
                                        : theme.resolveCard(context),
                                    borderRadius:
                                        BorderRadius.circular(theme.cardRadius),
                                    border: Border.all(
                                      color: isSelected
                                          ? primary
                                          : secondaryColor.withValues(
                                              alpha: 0.2,
                                            ),
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        plan.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        plan.localizedPrice,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
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
                    enabled: selected != null,
                    theme: theme,
                    onPressed: onPurchase,
                  ),
                  const SizedBox(height: 12),
                  PaywallLegalFooter(
                    disclaimer: controller.resolvedLegalDisclaimer,
                    strings: strings,
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

class _TimelineStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final PaywallTheme theme;
  final bool isFirst;
  final bool isLast;

  const _TimelineStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.theme,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final primary = theme.resolvePrimary(context);
    final textColor = theme.resolveText(context);
    final secondaryColor = theme.resolveSecondaryText(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 17, color: primary),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: primary.withValues(alpha: 0.25),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 4 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: secondaryColor,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
