// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entitlement_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EntitlementInfoImpl _$$EntitlementInfoImplFromJson(
  Map<String, dynamic> json,
) => _$EntitlementInfoImpl(
  id: json['id'] as String,
  type: json['type'] as String,
  code: json['code'] as String,
  status: json['status'] as String? ?? 'active',
  tier: json['tier'] as String?,
  billingCycle: json['billingCycle'] as String?,
  balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
  expireAt:
      json['expireAt'] == null
          ? null
          : DateTime.parse(json['expireAt'] as String),
  allowedPlatforms:
      (json['allowedPlatforms'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>['android', 'ios', 'web', 'macos', 'windows'],
);

Map<String, dynamic> _$$EntitlementInfoImplToJson(
  _$EntitlementInfoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'code': instance.code,
  'status': instance.status,
  'tier': instance.tier,
  'billingCycle': instance.billingCycle,
  'balance': instance.balance,
  'expireAt': instance.expireAt?.toIso8601String(),
  'allowedPlatforms': instance.allowedPlatforms,
};
