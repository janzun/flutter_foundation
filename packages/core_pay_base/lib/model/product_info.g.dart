// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductInfoImpl _$$ProductInfoImplFromJson(Map<String, dynamic> json) =>
    _$ProductInfoImpl(
      code: json['code'] as String,
      group: json['group'] as String,
      type: $enumDecode(_$ProductTypeEnumMap, json['type']),
      billingCycle:
          $enumDecodeNullable(_$BillingCycleEnumMap, json['billing_cycle']) ??
          BillingCycle.oneOff,
      storeProductId: json['store_product_id'] as String,
      storeParams:
          json['store_params'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
      localizedPrice: json['localized_price'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? '',
    );

Map<String, dynamic> _$$ProductInfoImplToJson(_$ProductInfoImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'group': instance.group,
      'type': _$ProductTypeEnumMap[instance.type]!,
      'billing_cycle': _$BillingCycleEnumMap[instance.billingCycle]!,
      'store_product_id': instance.storeProductId,
      'store_params': instance.storeParams,
      'localized_price': instance.localizedPrice,
      'price': instance.price,
      'currency': instance.currency,
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
