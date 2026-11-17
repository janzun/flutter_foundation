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

/// 统一跨端商品描述模型 (仅保留 App 端必要字段；价格由商店 API 实时填充)
@freezed
class ProductInfo with _$ProductInfo {
  @JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
  const factory ProductInfo({
    /// 业务唯一编码 (前端据此做 l10n 文案与权益映射，如: 'vip_monthly_ios')
    required String code,

    /// 商品分组 (如: 'subscription', 'points', 'single_pass')
    required String group,

    /// 官方标准交易类型
    required ProductType type,

    /// 计费周期
    @Default(BillingCycle.oneOff) BillingCycle billingCycle,

    /// 商店中配置的真实内购产品 ID (如: 'com.rtt.vip.monthly')
    required String storeProductId,

    /// 商店专属的额外信息参数字典 (如: {"base_plan_id": "monthly-standard"})
    @Default(<String, dynamic>{}) Map<String, dynamic> storeParams,

    /// 商店本地化格式价格 (100% 由商店 API 实时填充，如: '$4.99', '¥30.00')
    @Default('') String localizedPrice,

    /// 商店实时参考数值 (100% 由商店 API 实时填充，便于前端计算折扣率)
    @Default(0.0) double price,

    /// 商店实时货币代码 (100% 由商店 API 实时填充，如: 'USD', 'CNY')
    @Default('') String currency,
  }) = _ProductInfo;

  factory ProductInfo.fromJson(Map<String, dynamic> json) =>
      _$ProductInfoFromJson(json);
}
