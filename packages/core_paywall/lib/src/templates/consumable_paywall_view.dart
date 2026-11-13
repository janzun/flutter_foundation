import 'package:flutter/material.dart';

import '../controller/paywall_controller.dart';
import '../model/paywall_plan.dart';
import '../model/paywall_theme.dart';
import '../widgets/paywall_legal_footer.dart';
import '../widgets/paywall_shared_parts.dart';

/// 消耗型商品（积分 / 算力 / 次数包）网格弹窗模板。
class ConsumablePaywallView extends StatelessWidget {
  final PaywallController controller;
  final PaywallTheme theme;
  final PaywallLinks links;
  final String? currentBalanceText;
  final WidgetBuilder? heroBuilder;
  final VoidCallback onClose;
  final VoidCallback onPurchase;

  const ConsumablePaywallView({
    super.key,
    required this.controller,
    required this.theme,
    required this.links,
    this.currentBalanceText,
    this.heroBuilder,
    required this.onClose,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = theme.resolveText(context);
    final secondaryColor = theme.resolveSecondaryText(context);
    final primary = theme.resolvePrimary(context);
    final selected = controller.selectedPlan;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const SizedBox(width: 40),
                Expanded(
                  child: Text(
                    controller.strings.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: controller.isBusy ? null : onClose,
                  icon: Icon(Icons.close_rounded, color: secondaryColor),
                ),
              ],
            ),
            if (currentBalanceText != null) ...[
              const SizedBox(height: 4),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    controller.strings.balanceLabelTemplate
                        .replaceAll('{balance}', currentBalanceText!),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: primary,
                    ),
                  ),
                ),
              ),
            ],
            if (heroBuilder != null) ...[
              const SizedBox(height: 12),
              heroBuilder!(context),
            ],
            const SizedBox(height: 16),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: controller.plans.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.38,
                ),
                itemBuilder: (context, index) {
                  final plan = controller.plans[index];
                  final isSelected = selected?.id == plan.id;
                  return GestureDetector(
                    onTap: () => controller.selectPlan(plan),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.resolveSelectedCard(context)
                                : theme.resolveCard(context),
                            borderRadius:
                                BorderRadius.circular(theme.cardRadius),
                            border: Border.all(
                              color: isSelected
                                  ? primary
                                  : secondaryColor.withValues(alpha: 0.2),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                plan.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                              if (plan.description != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  plan.description!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 6),
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
                        ),
                        if (plan.badgeText != null)
                          Positioned(
                            top: -8,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.resolveBadge(context),
                                borderRadius: BorderRadius.circular(16),
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
                },
              ),
            ),
            const SizedBox(height: 16),
            PaywallErrorBanner(message: controller.errorMessage),
            PaywallCtaButton(
              label: controller.resolvedCtaText,
              isLoading: controller.isPurchasing,
              enabled: selected != null,
              theme: theme,
              onPressed: onPurchase,
            ),
            const SizedBox(height: 10),
            PaywallLegalFooter(
              disclaimer: controller.resolvedLegalDisclaimer,
              strings: controller.strings,
              links: links,
              theme: theme,
              showRestore: false,
            ),
          ],
        ),
      ),
    );
  }
}
