# core_paywall

## 1. 介绍
零外部包依赖、由 SKU 商业形态驱动的高转化海外付费墙与合规套件。支持动态下发 4 套黄金模板（经典多套餐、透明试用时间轴、消耗型积分网格、单品直购弹窗），内置基于计费类型自动切换的 Apple/Google 合规页脚、退出挽留拦截器、全链路漏斗事件回调以及购买前拦截钩子（支持游客转正引导）。

## 2. 最新版本 Tag
`paywall@1.0.0`

## 3. 接入方式
在项目 `pubspec.yaml` 中通过 Git 形式引入：
```yaml
dependencies:
  core_paywall:
    git:
      url: git@github.com:janzun/flutter_foundation.git
      path: packages/core_paywall
      ref: paywall@1.0.0
```

## 4. 必要配置
纯 Flutter UI 与状态逻辑层，零原生权限、零第三方支付或埋点包强依赖。由宿主 App 通过回调衔接支付执行与埋点上报。

## 5. 完整 API 列表

### 5.1 全局门面入口 `Paywall`
```dart
class Paywall {
  /// 唤起付费墙，返回关闭后的结果 (purchased / restored / dismissed)
  static Future<PaywallResult> show(
    BuildContext context, {
    required String placement,
    required List<PaywallPlan> plans,
    required PaywallLinks links,
    required PaywallPurchaseHandler onPurchase,
    PaywallRestoreHandler? onRestore,
    PaywallBeforePurchaseHook? onBeforePurchase,
    PaywallEventCallback? onEvent,
    PaywallTemplate template = PaywallTemplate.classic,
    PaywallPresentation presentation = PaywallPresentation.auto,
    PaywallChannel channel = PaywallChannel.overseas,
    PaywallStrings? strings,
    PaywallTheme theme = const PaywallTheme(),
    List<PaywallFeature> features = const [],
    String? initialSelectedPlanId,
    String? currentBalanceText,
    RetentionConfig? retentionConfig,
    WidgetBuilder? heroBuilder,
    WidgetBuilder? contentBuilder,
  });
}
```

### 5.2 逻辑与合规控制器 `PaywallController`
```dart
class PaywallController extends ChangeNotifier {
  PaywallController({
    required String placement,
    required PaywallTemplate template,
    required List<PaywallPlan> plans,
    required PaywallStrings strings,
    required PaywallPurchaseHandler onPurchase,
    PaywallRestoreHandler? onRestore,
    PaywallBeforePurchaseHook? onBeforePurchase,
    PaywallEventCallback? onEvent,
    RetentionConfig? retentionConfig,
    String? initialSelectedPlanId,
  });

  PaywallPlan? get selectedPlan;
  bool get isPurchasing;
  bool get isRestoring;
  bool get isBusy;
  String? get errorMessage;
  bool get hasRetentionShown;
  bool get shouldShowRestore;
  bool get canTriggerRetention;
  String get resolvedCtaText;
  String get resolvedLegalDisclaimer;

  void notifyShown();
  void selectPlan(PaywallPlan plan);
  void clearError();
  Future<PaywallResult?> purchase({PaywallPlan? overridePlan});
  Future<PaywallResult?> restore();
  void markRetentionShown();
  void notifyRetentionAccepted(PaywallPlan? offerPlan);
  void notifyDismissed();
}
```

### 5.3 核心枚举与数据模型
```dart
enum PlanBillingType { autoRenewable, nonRenewing, lifetime, consumable }

enum PaywallTemplate {
  classic, timeline, consumable, singlePurchase;
  static PaywallTemplate fromString(String? value, {PaywallTemplate fallback = PaywallTemplate.classic});
}

enum PaywallPresentation { auto, fullScreen, bottomSheet }
enum PaywallChannel { overseas, domestic } // domestic 预留

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
  bool get hasTrial;
}

class PaywallFeature {
  final IconData? icon;
  final String text;
}

class PaywallLinks {
  final String? termsUrl;
  final String? privacyUrl;
  final VoidCallback? onOpenTerms;
  final VoidCallback? onOpenPrivacy;
  final void Function(String url)? onOpenUrl;
}

class RetentionConfig {
  final String title;
  final String subtitle;
  final PaywallPlan? offerPlan;
  final String? acceptButtonText;
  final String dismissButtonText;
}
```

### 5.4 结果、事件与主题文案模型
```dart
enum PaywallOutcome { purchased, restored, dismissed }

class PaywallResult {
  final PaywallOutcome outcome;
  final PaywallPlan? plan;
  bool get isPurchased;
  bool get isRestored;
  bool get isDismissed;
}

class PaywallPurchaseResult {
  final bool success;
  final bool cancelled;
  final String? errorMessage;
  const PaywallPurchaseResult.success();
  const PaywallPurchaseResult.cancelled();
  const PaywallPurchaseResult.failed([String? errorMessage]);
}

enum PaywallEventType {
  paywallShown, planSelected, purchaseClicked, purchaseSucceeded, purchaseFailed,
  restoreClicked, restoreSucceeded, restoreFailed,
  retentionShown, retentionAccepted, paywallDismissed,
}

class PaywallEvent {
  final PaywallEventType type;
  final String placement;
  final PaywallTemplate template;
  final String? planId;
  final String? errorMessage;
  final Map<String, dynamic>? extra;
}

class PaywallStrings {
  factory PaywallStrings.en({String title = 'Unlock Pro Access', String? subtitle});
  factory PaywallStrings.zh({String title = '解锁 Pro 全部高级权益', String? subtitle});
}

class PaywallTheme {
  const PaywallTheme({
    Color? primaryColor, Color? backgroundColor, Color? cardColor,
    Color? selectedCardColor, Color? textColor, Color? secondaryTextColor,
    Color? badgeColor, Color? badgeTextColor,
    double cardRadius = 16.0, double buttonRadius = 14.0,
  });
}
```

### 5.5 独立合规与挽留组件
```dart
/// 可单独嵌入自绘付费墙的合规页脚
class PaywallLegalFooter extends StatelessWidget { ... }

/// 退出挽留弹窗
class PaywallRetentionDialog extends StatelessWidget {
  static Future<bool> show(BuildContext context, {required RetentionConfig config, PaywallTheme theme});
}
```
