import 'package:flutter/material.dart';

import '../controller/paywall_controller.dart';
import '../model/paywall_theme.dart';

/// 付费墙通用 CTA 大按钮（带加载锁与圆角配置）。
class PaywallCtaButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final bool enabled;
  final PaywallTheme theme;
  final VoidCallback onPressed;

  const PaywallCtaButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.enabled,
    required this.theme,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final primary = theme.resolvePrimary(context);
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: (enabled && !isLoading) ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(theme.buttonRadius),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: theme.resolveBadgeText(context),
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.resolveBadgeText(context),
                ),
              ),
      ),
    );
  }
}

/// 顶部导航栏：关闭按钮与（可选）右上角 Restore。
class PaywallTopBar extends StatelessWidget {
  final PaywallController controller;
  final PaywallTheme theme;
  final VoidCallback onClose;
  final VoidCallback onRestore;

  const PaywallTopBar({
    super.key,
    required this.controller,
    required this.theme,
    required this.onClose,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final secondary = theme.resolveSecondaryText(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: controller.isBusy ? null : onClose,
          icon: Icon(Icons.close_rounded, color: secondary),
          tooltip: 'Close',
        ),
        if (controller.shouldShowRestore)
          TextButton(
            onPressed: controller.isBusy ? null : onRestore,
            child: controller.isRestoring
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    controller.strings.restoreText,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: secondary,
                    ),
                  ),
          )
        else
          const SizedBox(width: 48),
      ],
    );
  }
}

/// 错误提示横幅。
class PaywallErrorBanner extends StatelessWidget {
  final String? message;

  const PaywallErrorBanner({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        message!,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: colorScheme.onErrorContainer),
      ),
    );
  }
}
