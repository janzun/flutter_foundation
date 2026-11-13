/// 付费墙文案与多语言配置，内置英文与中文默认构造，支持 App 全量自定义。
class PaywallStrings {
  final String title;
  final String? subtitle;
  final String restoreText;
  final String termsText;
  final String privacyText;
  final String subscribeCtaPrefix;
  final String freeTrialCtaTemplate;
  final String nonRenewingCtaPrefix;
  final String lifetimeCtaPrefix;
  final String consumableCtaPrefix;
  final String autoRenewDisclaimer;
  final String trialDisclaimerTemplate;
  final String nonRenewingDisclaimer;
  final String lifetimeDisclaimer;
  final String consumableDisclaimer;
  final String timelineStep1Title;
  final String timelineStep1Subtitle;
  final String timelineStep2Title;
  final String timelineStep2Subtitle;
  final String timelineStep3Title;
  final String timelineStep3SubtitleTemplate;
  final String balanceLabelTemplate;
  final String emptyPlansText;

  const PaywallStrings({
    required this.title,
    this.subtitle,
    required this.restoreText,
    required this.termsText,
    required this.privacyText,
    required this.subscribeCtaPrefix,
    required this.freeTrialCtaTemplate,
    required this.nonRenewingCtaPrefix,
    required this.lifetimeCtaPrefix,
    required this.consumableCtaPrefix,
    required this.autoRenewDisclaimer,
    required this.trialDisclaimerTemplate,
    required this.nonRenewingDisclaimer,
    required this.lifetimeDisclaimer,
    required this.consumableDisclaimer,
    required this.timelineStep1Title,
    required this.timelineStep1Subtitle,
    required this.timelineStep2Title,
    required this.timelineStep2Subtitle,
    required this.timelineStep3Title,
    required this.timelineStep3SubtitleTemplate,
    required this.balanceLabelTemplate,
    required this.emptyPlansText,
  });

  factory PaywallStrings.en({
    String title = 'Unlock Pro Access',
    String? subtitle,
  }) {
    return PaywallStrings(
      title: title,
      subtitle: subtitle,
      restoreText: 'Restore',
      termsText: 'Terms of Use',
      privacyText: 'Privacy Policy',
      subscribeCtaPrefix: 'Continue',
      freeTrialCtaTemplate: 'Start {days}-Day Free Trial',
      nonRenewingCtaPrefix: 'Get Access',
      lifetimeCtaPrefix: 'Unlock Forever',
      consumableCtaPrefix: 'Buy Now',
      autoRenewDisclaimer:
          'Subscription automatically renews unless canceled at least 24 hours before the end of the current period.',
      trialDisclaimerTemplate:
          'Free for {days} days, then {price}. Cancel anytime in store settings.',
      nonRenewingDisclaimer:
          'One-time purchase for the selected duration. Does not auto-renew.',
      lifetimeDisclaimer:
          'One-time purchase. Permanent access with restore support.',
      consumableDisclaimer:
          'One-time consumable purchase. Delivered immediately with no recurring charge.',
      timelineStep1Title: 'Today: Instant Full Access',
      timelineStep1Subtitle: 'Unlock all Pro features immediately at \$0.',
      timelineStep2Title: 'Before Renewal: Reminder',
      timelineStep2Subtitle: 'Cancel anytime in settings before trial ends.',
      timelineStep3Title: 'After Trial: Subscription Begins',
      timelineStep3SubtitleTemplate: 'Billed {price} unless canceled beforehand.',
      balanceLabelTemplate: 'Current Balance: {balance}',
      emptyPlansText: 'No plans available right now.',
    );
  }

  factory PaywallStrings.zh({
    String title = '解锁 Pro 全部高级权益',
    String? subtitle,
  }) {
    return PaywallStrings(
      title: title,
      subtitle: subtitle,
      restoreText: '恢复购买',
      termsText: '使用条款',
      privacyText: '隐私政策',
      subscribeCtaPrefix: '立即订阅',
      freeTrialCtaTemplate: '开启 {days} 天免费试用',
      nonRenewingCtaPrefix: '立即开通',
      lifetimeCtaPrefix: '一次付费，永久拥有',
      consumableCtaPrefix: '立即购买',
      autoRenewDisclaimer: '订阅将按周期自动续费，可随时在应用商店设置中取消。',
      trialDisclaimerTemplate: '{days} 天免费试用结束后按 {price} 自动续费，可随时取消。',
      nonRenewingDisclaimer: '一次性购买对应时长权益，到期后不会自动续费。',
      lifetimeDisclaimer: '一次性买断永久有效，支持换机后恢复购买。',
      consumableDisclaimer: '消耗型商品一经购买立即生效，不产生自动续费。',
      timelineStep1Title: '今天：立即解锁全部权益',
      timelineStep1Subtitle: '0 元立即体验全部 Pro 高级功能',
      timelineStep2Title: '续费前：系统到期提醒',
      timelineStep2Subtitle: '不满意可随时在商店设置中一键取消',
      timelineStep3Title: '试用结束：正式开启订阅',
      timelineStep3SubtitleTemplate: '若未取消，将按 {price} 自动续费',
      balanceLabelTemplate: '当前账户剩余：{balance}',
      emptyPlansText: '暂无可用商品',
    );
  }
}
