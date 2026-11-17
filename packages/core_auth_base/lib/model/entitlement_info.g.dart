// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entitlement_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EntitlementInfoImpl _$$EntitlementInfoImplFromJson(
  Map<String, dynamic> json,
) => _$EntitlementInfoImpl(
  type: json['type'] as String,
  code: json['code'] as String,
  status: json['status'] as String? ?? 'active',
  tier: json['tier'] as String?,
  billingCycle: json['billing_cycle'] as String?,
  balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
  expireAt:
      json['expire_at'] == null
          ? null
          : DateTime.parse(json['expire_at'] as String),
);

Map<String, dynamic> _$$EntitlementInfoImplToJson(
  _$EntitlementInfoImpl instance,
) => <String, dynamic>{
  'type': instance.type,
  'code': instance.code,
  'status': instance.status,
  'tier': instance.tier,
  'billing_cycle': instance.billingCycle,
  'balance': instance.balance,
  'expire_at': instance.expireAt?.toIso8601String(),
};
