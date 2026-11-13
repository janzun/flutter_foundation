import 'package:flutter/material.dart';

import '../model/paywall_plan.dart';
import '../model/paywall_strings.dart';
import '../model/paywall_theme.dart';

/// 独立合规页脚小组件（可单独拆出给自绘付费墙使用）。
class PaywallLegalFooter extends StatelessWidget {
  final String disclaimer;
  final PaywallStrings strings;
  final PaywallLinks links;
  final PaywallTheme theme;
  final bool showRestore;
  final bool isRestoring;
  final VoidCallback? onRestore;

  const PaywallLegalFooter({
    super.key,
    required this.disclaimer,
    required this.strings,
    required this.links,
    this.theme = const PaywallTheme(),
    this.showRestore = false,
    this.isRestoring = false,
    this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final secondaryColor = theme.resolveSecondaryText(context);
    final hasTerms = links.onOpenTerms != null ||
        (links.termsUrl != null && links.onOpenUrl != null);
    final hasPrivacy = links.onOpenPrivacy != null ||
        (links.privacyUrl != null && links.onOpenUrl != null);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          disclaimer,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            height: 1.4,
            color: secondaryColor.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: [
            if (showRestore && onRestore != null) ...[
              _FooterLink(
                label: strings.restoreText,
                color: secondaryColor,
                onTap: isRestoring ? null : onRestore,
              ),
              if (hasTerms || hasPrivacy) _DotDivider(color: secondaryColor),
            ],
            if (hasTerms) ...[
              _FooterLink(
                label: strings.termsText,
                color: secondaryColor,
                onTap: () {
                  if (links.onOpenTerms != null) {
                    links.onOpenTerms!();
                  } else if (links.termsUrl != null) {
                    links.onOpenUrl?.call(links.termsUrl!);
                  }
                },
              ),
              if (hasPrivacy) _DotDivider(color: secondaryColor),
            ],
            if (hasPrivacy)
              _FooterLink(
                label: strings.privacyText,
                color: secondaryColor,
                onTap: () {
                  if (links.onOpenPrivacy != null) {
                    links.onOpenPrivacy!();
                  } else if (links.privacyUrl != null) {
                    links.onOpenUrl?.call(links.privacyUrl!);
                  }
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _FooterLink({
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            decoration: TextDecoration.underline,
            decorationColor: color.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}

class _DotDivider extends StatelessWidget {
  final Color color;

  const _DotDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      '·',
      style: TextStyle(fontSize: 12, color: color),
    );
  }
}
