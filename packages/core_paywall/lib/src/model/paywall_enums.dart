/// SKU 商业计费类型，决定按钮文案、Restore 显示与合规免责声明。
enum PlanBillingType {
  /// 连续自动订阅 (月卡/季卡/年卡，可附带免费试用)
  autoRenewable,

  /// 非续期时长会员 (到期不自动续费)
  nonRenewing,

  /// 终身买断 (非消耗型)
  lifetime,

  /// 消耗型商品 (积分/次数/单次功能解锁)
  consumable,
}

/// 付费墙模板骨架类型，支持通过远程配置字符串动态解析。
enum PaywallTemplate {
  /// 经典多套餐卡片流 (适合订阅、买断或混卖)
  classic,

  /// 3步透明试用时间轴 (适合高客单价试用订阅)
  timeline,

  /// 多档位积分/算力网格 (适合消耗型商品)
  consumable,

  /// 单品直购紧凑弹窗 (适合单次付费解锁场景)
  singlePurchase;

  static PaywallTemplate fromString(
    String? value, {
    PaywallTemplate fallback = PaywallTemplate.classic,
  }) {
    if (value == null) return fallback;
    final normalized = value.trim().toLowerCase();
    for (final item in PaywallTemplate.values) {
      if (item.name.toLowerCase() == normalized) {
        return item;
      }
    }
    return fallback;
  }
}

/// 付费墙容器呈现形态。
enum PaywallPresentation {
  /// 自动匹配：classic/timeline 使用全屏；consumable/singlePurchase 使用底部弹窗
  auto,

  /// 强制全屏页面
  fullScreen,

  /// 强制底部半弹窗
  bottomSheet,
}

/// 商业渠道（当前实现 overseas，预留 domestic 扩展位）。
enum PaywallChannel {
  overseas,
  domestic,
}
