// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductInfoImpl _$$ProductInfoImplFromJson(Map<String, dynamic> json) =>
    _$ProductInfoImpl(
      code: json['code'] as String,
      appId: json['app_id'] as String,
      group: json['group'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      localizedPrice: json['localized_price'] as String? ?? '',
      type: $enumDecode(_$ProductTypeEnumMap, json['type']),
      billingCycle:
          $enumDecodeNullable(_$BillingCycleEnumMap, json['billing_cycle']) ??
          BillingCycle.oneOff,
      platform: json['platform'] as String,
      store: json['store'] as String,
      storeProductId: json['store_product_id'] as String,
      storeParams:
          json['store_params'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
      rewardTier: json['reward_tier'] as String?,
      rewardDurationDays: (json['reward_duration_days'] as num?)?.toInt() ?? 0,
      rewardPoints: (json['reward_points'] as num?)?.toDouble() ?? 0.0,
      rewardPerks:
          json['reward_perks'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ProductInfoImplToJson(_$ProductInfoImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'app_id': instance.appId,
      'group': instance.group,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'currency': instance.currency,
      'localized_price': instance.localizedPrice,
      'type': _$ProductTypeEnumMap[instance.type]!,
      'billing_cycle': _$BillingCycleEnumMap[instance.billingCycle]!,
      'platform': instance.platform,
      'store': instance.store,
      'store_product_id': instance.storeProductId,
      'store_params': instance.storeParams,
      'reward_tier': instance.rewardTier,
      'reward_duration_days': instance.rewardDurationDays,
      'reward_points': instance.rewardPoints,
      'reward_perks': instance.rewardPerks,
      'sort_order': instance.sortOrder,
    };

const _$ProductTypeEnumMap = {
  ProductType.subscription: 'subscription',
  ProductType.consumable: 'consumable',
  ProductType.nonConsumable: 'non_consumable',
};

const _$BillingCycleEnumMap = {
  BillingCycle.monthly: 'monthly',
  BillingCycle.annual: 'annual',
  BillingCycle.lifetime: 'lifetime',
  BillingCycle.oneOff: 'one_off',
};
