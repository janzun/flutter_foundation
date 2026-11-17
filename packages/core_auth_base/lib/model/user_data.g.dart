// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserDataImpl _$$UserDataImplFromJson(Map<String, dynamic> json) =>
    _$UserDataImpl(
      id: json['id'] as String,
      isAnonymous: json['is_anonymous'] as bool? ?? false,
      isNewUser: json['is_new_user'] as bool? ?? false,
      displayName: json['display_name'] as String,
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      entitlements:
          (json['entitlements'] as List<dynamic>?)
              ?.map((e) => EntitlementInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <EntitlementInfo>[],
    );

Map<String, dynamic> _$$UserDataImplToJson(_$UserDataImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'is_anonymous': instance.isAnonymous,
      'is_new_user': instance.isNewUser,
      'display_name': instance.displayName,
      'email': instance.email,
      'avatar_url': instance.avatarUrl,
      'entitlements': instance.entitlements.map((e) => e.toJson()).toList(),
    };
