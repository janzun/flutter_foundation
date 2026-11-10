// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserDataImpl _$$UserDataImplFromJson(Map<String, dynamic> json) =>
    _$UserDataImpl(
      id: json['id'] as String,
      appId: json['app_id'] as String,
      supabaseUid: json['supabase_uid'] as String,
      isAnonymous: json['is_anonymous'] as bool? ?? false,
      authProvider: json['auth_provider'] as String? ?? 'email',
      isNewUser: json['is_new_user'] as bool? ?? false,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      displayName: json['display_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      riskLevel: json['risk_level'] as String? ?? 'normal',
      entitlements:
          (json['entitlements'] as List<dynamic>?)
              ?.map((e) => EntitlementInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <EntitlementInfo>[],
      lastLoginAt:
          json['last_login_at'] == null
              ? null
              : DateTime.parse(json['last_login_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$UserDataImplToJson(_$UserDataImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'app_id': instance.appId,
      'supabase_uid': instance.supabaseUid,
      'is_anonymous': instance.isAnonymous,
      'auth_provider': instance.authProvider,
      'is_new_user': instance.isNewUser,
      'email': instance.email,
      'phone': instance.phone,
      'display_name': instance.displayName,
      'avatar_url': instance.avatarUrl,
      'risk_level': instance.riskLevel,
      'entitlements': instance.entitlements.map((e) => e.toJson()).toList(),
      'last_login_at': instance.lastLoginAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };
