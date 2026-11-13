import 'package:flutter/material.dart';

import '../model/paywall_plan.dart';
import '../model/paywall_theme.dart';

/// 退出挽留弹窗，返回 `true` 表示用户接受挽留方案，返回 `false`/null 表示确认关闭离开。
class PaywallRetentionDialog extends StatelessWidget {
  final RetentionConfig config;
  final PaywallTheme theme;

  const PaywallRetentionDialog({
    super.key,
    required this.config,
    this.theme = const PaywallTheme(),
  });

  static Future<bool> show(
    BuildContext context, {
    required RetentionConfig config,
    PaywallTheme theme = const PaywallTheme(),
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PaywallRetentionDialog(config: config, theme: theme),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final primary = theme.resolvePrimary(context);
    final textColor = theme.resolveText(context);
    final secondaryColor = theme.resolveSecondaryText(context);
    final offer = config.offerPlan;

    final acceptLabel = config.acceptButtonText ??
        (offer != null
            ? '${offer.title} · ${offer.localizedPrice}'
            : 'Continue');

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(theme.cardRadius),
      ),
      title: Text(
        config.title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            config.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: secondaryColor, height: 1.4),
          ),
          if (offer != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primary),
              ),
              child: Column(
                children: [
                  if (offer.badgeText != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.resolveBadge(context),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        offer.badgeText!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: theme.resolveBadgeText(context),
                        ),
                      ),
                    ),
                  Text(
                    offer.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (offer.originalPrice != null) ...[
                        Text(
                          offer.originalPrice!,
                          style: TextStyle(
                            fontSize: 13,
                            color: secondaryColor,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        offer.localizedPrice,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(theme.buttonRadius),
                ),
              ),
              child: Text(
                acceptLabel,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                config.dismissButtonText,
                style: TextStyle(color: secondaryColor, fontSize: 13),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
