import 'package:flutter/widgets.dart';
import 'paywall_enums.dart';

/// 付费墙单品视图模型（由 App 层将商店商品与 Supabase 运营配置合并后传入）。
class PaywallPlan {
  final String id;
  final PlanBillingType billingType;
  final String title;
  final String localizedPrice;
  final String? originalPrice;
  final String? badgeText;
  final String? pricePerUnitText;
  final int? trialDays;
  final String? ctaText;
  final String? description;
  final List<String>? specificPerks;
  final Map<String, dynamic>? extra;

  const PaywallPlan({
    required this.id,
    required this.billingType,
    required this.title,
    required this.localizedPrice,
    this.originalPrice,
    this.badgeText,
    this.pricePerUnitText,
    this.trialDays,
    this.ctaText,
    this.description,
    this.specificPerks,
    this.extra,
  });

  bool get hasTrial =>
      billingType == PlanBillingType.autoRenewable &&
      trialDays != null &&
      trialDays! > 0;
}

/// 权益项描述（图标 + 文案）。
class PaywallFeature {
  final IconData? icon;
  final String text;

  const PaywallFeature({
    this.icon,
    required this.text,
  });
}

/// 提审合规链接配置。
class PaywallLinks {
  final String? termsUrl;
  final String? privacyUrl;
  final VoidCallback? onOpenTerms;
  final VoidCallback? onOpenPrivacy;
  final void Function(String url)? onOpenUrl;

  const PaywallLinks({
    this.termsUrl,
    this.privacyUrl,
    this.onOpenTerms,
    this.onOpenPrivacy,
    this.onOpenUrl,
  });
}

/// 退出挽留弹窗配置（仅在全屏页未购买关闭时触发，最多拦截 1 次）。
class RetentionConfig {
  final String title;
  final String subtitle;
  final PaywallPlan? offerPlan;
  final String? acceptButtonText;
  final String dismissButtonText;

  const RetentionConfig({
    required this.title,
    required this.subtitle,
    this.offerPlan,
    this.acceptButtonText,
    this.dismissButtonText = 'No, thanks',
  });
}
