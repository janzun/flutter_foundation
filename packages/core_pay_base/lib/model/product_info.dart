import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_info.freezed.dart';
part 'product_info.g.dart';

/// 官方标准交易商品类型 (对齐 Apple StoreKit 与 Google Play Billing)
enum ProductType {
  /// 自动续期订阅 (如: 连续包月/包年 VIP)
  @JsonValue('subscription')
  subscription,

  /// 消耗型商品 (如: 积分加油包、转写小时卡，随使用消耗)
  @JsonValue('consumable')
  consumable,

  /// 非消耗型商品 (如: 终身买断 VIP、永久功能解锁包，一次购买终身拥有)
  @JsonValue('non_consumable')
  nonConsumable,
}

/// 计费周期枚举
enum BillingCycle {
  @JsonValue('monthly')
  monthly,
  @JsonValue('annual')
  annual,
  @JsonValue('lifetime')
  lifetime,
  @JsonValue('one_off')
  oneOff,
}

/// 统一跨端商品描述模型 (单记录对应单商店品项)
@freezed
class ProductInfo with _$ProductInfo {
  @JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
  const factory ProductInfo({
    /// 业务唯一编码 (如: 'vip_monthly_ios')
    required String code,

    /// 关联应用唯一 UUID
    required String appId,

    /// 商品分组 (如: 'subscription', 'points', 'single_pass')
    required String group,

    /// 商品显示名称
    required String name,

    /// 商品副标题与权益描述
    @Default('') String description,

    /// 基准参考价格 (单位: 元/美元)
    required double price,

    /// 货币代码 (如: 'USD', 'CNY')
    @Default('USD') String currency,

    /// 商店本地化格式价格 (如: '$4.99', '¥30.00')
    @Default('') String localizedPrice,

    /// 官方标准交易类型
    required ProductType type,

    /// 计费周期
    @Default(BillingCycle.oneOff) BillingCycle billingCycle,

    /// 目标平台 ('ios', 'android', 'web')
    required String platform,

    /// 对应商店/支付方式 ('app_store', 'play_store', 'stripe')
    required String store,

    /// 商店中配置的真实内购产品 ID (如: 'com.rtt.vip.monthly')
    required String storeProductId,

    /// 商店专属的额外信息参数字典 (如: {"base_plan_id": "monthly-standard"})
    @Default(<String, dynamic>{}) Map<String, dynamic> storeParams,

    /// 附赠会员级别 (如: 'pro', 'svip')
    String? rewardTier,

    /// 附赠会员时长天数
    @Default(0) int rewardDurationDays,

    /// 附赠积分数值
    @Default(0.0) double rewardPoints,

    /// 附赠混合特权字典 (如: {"ai_quota": 50})
    @Default(<String, dynamic>{}) Map<String, dynamic> rewardPerks,

    /// 排序权重
    @Default(0) int sortOrder,
  }) = _ProductInfo;

  factory ProductInfo.fromJson(Map<String, dynamic> json) =>
      _$ProductInfoFromJson(json);
}
