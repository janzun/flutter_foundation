import 'package:flutter/material.dart';

/// 付费墙视觉主题配置（未指定字段自动回退到宿主 ThemeData）。
class PaywallTheme {
  final Color? primaryColor;
  final Color? backgroundColor;
  final Color? cardColor;
  final Color? selectedCardColor;
  final Color? textColor;
  final Color? secondaryTextColor;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final double cardRadius;
  final double buttonRadius;

  const PaywallTheme({
    this.primaryColor,
    this.backgroundColor,
    this.cardColor,
    this.selectedCardColor,
    this.textColor,
    this.secondaryTextColor,
    this.badgeColor,
    this.badgeTextColor,
    this.cardRadius = 16.0,
    this.buttonRadius = 14.0,
  });

  Color resolvePrimary(BuildContext context) =>
      primaryColor ?? Theme.of(context).colorScheme.primary;

  Color resolveBackground(BuildContext context) =>
      backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;

  Color resolveCard(BuildContext context) =>
      cardColor ?? Theme.of(context).colorScheme.surfaceContainerLow;

  Color resolveSelectedCard(BuildContext context) {
    if (selectedCardColor != null) return selectedCardColor!;
    return resolvePrimary(context).withValues(alpha: 0.08);
  }

  Color resolveText(BuildContext context) =>
      textColor ?? Theme.of(context).colorScheme.onSurface;

  Color resolveSecondaryText(BuildContext context) =>
      secondaryTextColor ?? Theme.of(context).colorScheme.onSurfaceVariant;

  Color resolveBadge(BuildContext context) =>
      badgeColor ?? resolvePrimary(context);

  Color resolveBadgeText(BuildContext context) =>
      badgeTextColor ?? Theme.of(context).colorScheme.onPrimary;
}
