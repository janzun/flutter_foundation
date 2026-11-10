// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserData _$UserDataFromJson(Map<String, dynamic> json) {
  return _UserData.fromJson(json);
}

/// @nodoc
mixin _$UserData {
  /// common.users.id (业务系统统一 UUID)
  String get id => throw _privateConstructorUsedError;

  /// common.apps.id (当前应用唯一标识)
  @JsonKey(name: 'app_id')
  String get appId => throw _privateConstructorUsedError;

  /// auth.users.id (Supabase 底层认证 UID)
  @JsonKey(name: 'supabase_uid')
  String get supabaseUid => throw _privateConstructorUsedError;

  /// 是否为匿名访客
  @JsonKey(name: 'is_anonymous')
  bool get isAnonymous => throw _privateConstructorUsedError;

  /// 认证提供商 ('anonymous' | 'apple' | 'google' | 'email')
  @JsonKey(name: 'auth_provider')
  String get authProvider => throw _privateConstructorUsedError;

  /// 标识当前登录是否为刚刚注册的新用户
  @JsonKey(name: 'is_new_user')
  bool get isNewUser => throw _privateConstructorUsedError;

  /// 绑定邮箱
  String? get email => throw _privateConstructorUsedError;

  /// 绑定手机号
  String? get phone => throw _privateConstructorUsedError;

  /// 用户展示昵称
  @JsonKey(name: 'display_name')
  String get displayName => throw _privateConstructorUsedError;

  /// 用户头像 URL
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl => throw _privateConstructorUsedError;

  /// 用户风控级别 ('normal' | 'high' | 'banned')
  @JsonKey(name: 'risk_level')
  String get riskLevel => throw _privateConstructorUsedError;

  /// 用户全量资产与权益列表 (统一承载会员、积分、额度)
  List<EntitlementInfo> get entitlements => throw _privateConstructorUsedError;

  /// 最近登录活跃时间
  @JsonKey(name: 'last_login_at')
  DateTime? get lastLoginAt => throw _privateConstructorUsedError;

  /// 账号注册时间
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this UserData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserDataCopyWith<UserData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserDataCopyWith<$Res> {
  factory $UserDataCopyWith(UserData value, $Res Function(UserData) then) =
      _$UserDataCopyWithImpl<$Res, UserData>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'app_id') String appId,
    @JsonKey(name: 'supabase_uid') String supabaseUid,
    @JsonKey(name: 'is_anonymous') bool isAnonymous,
    @JsonKey(name: 'auth_provider') String authProvider,
    @JsonKey(name: 'is_new_user') bool isNewUser,
    String? email,
    String? phone,
    @JsonKey(name: 'display_name') String displayName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'risk_level') String riskLevel,
    List<EntitlementInfo> entitlements,
    @JsonKey(name: 'last_login_at') DateTime? lastLoginAt,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$UserDataCopyWithImpl<$Res, $Val extends UserData>
    implements $UserDataCopyWith<$Res> {
  _$UserDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? appId = null,
    Object? supabaseUid = null,
    Object? isAnonymous = null,
    Object? authProvider = null,
    Object? isNewUser = null,
    Object? email = freezed,
    Object? phone = freezed,
    Object? displayName = null,
    Object? avatarUrl = freezed,
    Object? riskLevel = null,
    Object? entitlements = null,
    Object? lastLoginAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            appId:
                null == appId
                    ? _value.appId
                    : appId // ignore: cast_nullable_to_non_nullable
                        as String,
            supabaseUid:
                null == supabaseUid
                    ? _value.supabaseUid
                    : supabaseUid // ignore: cast_nullable_to_non_nullable
                        as String,
            isAnonymous:
                null == isAnonymous
                    ? _value.isAnonymous
                    : isAnonymous // ignore: cast_nullable_to_non_nullable
                        as bool,
            authProvider:
                null == authProvider
                    ? _value.authProvider
                    : authProvider // ignore: cast_nullable_to_non_nullable
                        as String,
            isNewUser:
                null == isNewUser
                    ? _value.isNewUser
                    : isNewUser // ignore: cast_nullable_to_non_nullable
                        as bool,
            email:
                freezed == email
                    ? _value.email
                    : email // ignore: cast_nullable_to_non_nullable
                        as String?,
            phone:
                freezed == phone
                    ? _value.phone
                    : phone // ignore: cast_nullable_to_non_nullable
                        as String?,
            displayName:
                null == displayName
                    ? _value.displayName
                    : displayName // ignore: cast_nullable_to_non_nullable
                        as String,
            avatarUrl:
                freezed == avatarUrl
                    ? _value.avatarUrl
                    : avatarUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
            riskLevel:
                null == riskLevel
                    ? _value.riskLevel
                    : riskLevel // ignore: cast_nullable_to_non_nullable
                        as String,
            entitlements:
                null == entitlements
                    ? _value.entitlements
                    : entitlements // ignore: cast_nullable_to_non_nullable
                        as List<EntitlementInfo>,
            lastLoginAt:
                freezed == lastLoginAt
                    ? _value.lastLoginAt
                    : lastLoginAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserDataImplCopyWith<$Res>
    implements $UserDataCopyWith<$Res> {
  factory _$$UserDataImplCopyWith(
    _$UserDataImpl value,
    $Res Function(_$UserDataImpl) then,
  ) = __$$UserDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'app_id') String appId,
    @JsonKey(name: 'supabase_uid') String supabaseUid,
    @JsonKey(name: 'is_anonymous') bool isAnonymous,
    @JsonKey(name: 'auth_provider') String authProvider,
    @JsonKey(name: 'is_new_user') bool isNewUser,
    String? email,
    String? phone,
    @JsonKey(name: 'display_name') String displayName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'risk_level') String riskLevel,
    List<EntitlementInfo> entitlements,
    @JsonKey(name: 'last_login_at') DateTime? lastLoginAt,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$UserDataImplCopyWithImpl<$Res>
    extends _$UserDataCopyWithImpl<$Res, _$UserDataImpl>
    implements _$$UserDataImplCopyWith<$Res> {
  __$$UserDataImplCopyWithImpl(
    _$UserDataImpl _value,
    $Res Function(_$UserDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? appId = null,
    Object? supabaseUid = null,
    Object? isAnonymous = null,
    Object? authProvider = null,
    Object? isNewUser = null,
    Object? email = freezed,
    Object? phone = freezed,
    Object? displayName = null,
    Object? avatarUrl = freezed,
    Object? riskLevel = null,
    Object? entitlements = null,
    Object? lastLoginAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$UserDataImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        appId:
            null == appId
                ? _value.appId
                : appId // ignore: cast_nullable_to_non_nullable
                    as String,
        supabaseUid:
            null == supabaseUid
                ? _value.supabaseUid
                : supabaseUid // ignore: cast_nullable_to_non_nullable
                    as String,
        isAnonymous:
            null == isAnonymous
                ? _value.isAnonymous
                : isAnonymous // ignore: cast_nullable_to_non_nullable
                    as bool,
        authProvider:
            null == authProvider
                ? _value.authProvider
                : authProvider // ignore: cast_nullable_to_non_nullable
                    as String,
        isNewUser:
            null == isNewUser
                ? _value.isNewUser
                : isNewUser // ignore: cast_nullable_to_non_nullable
                    as bool,
        email:
            freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                    as String?,
        phone:
            freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                    as String?,
        displayName:
            null == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                    as String,
        avatarUrl:
            freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
        riskLevel:
            null == riskLevel
                ? _value.riskLevel
                : riskLevel // ignore: cast_nullable_to_non_nullable
                    as String,
        entitlements:
            null == entitlements
                ? _value._entitlements
                : entitlements // ignore: cast_nullable_to_non_nullable
                    as List<EntitlementInfo>,
        lastLoginAt:
            freezed == lastLoginAt
                ? _value.lastLoginAt
                : lastLoginAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$UserDataImpl extends _UserData {
  const _$UserDataImpl({
    required this.id,
    @JsonKey(name: 'app_id') required this.appId,
    @JsonKey(name: 'supabase_uid') required this.supabaseUid,
    @JsonKey(name: 'is_anonymous') this.isAnonymous = false,
    @JsonKey(name: 'auth_provider') this.authProvider = 'email',
    @JsonKey(name: 'is_new_user') this.isNewUser = false,
    this.email,
    this.phone,
    @JsonKey(name: 'display_name') required this.displayName,
    @JsonKey(name: 'avatar_url') this.avatarUrl,
    @JsonKey(name: 'risk_level') this.riskLevel = 'normal',
    final List<EntitlementInfo> entitlements = const <EntitlementInfo>[],
    @JsonKey(name: 'last_login_at') this.lastLoginAt,
    @JsonKey(name: 'created_at') required this.createdAt,
  }) : _entitlements = entitlements,
       super._();

  factory _$UserDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserDataImplFromJson(json);

  /// common.users.id (业务系统统一 UUID)
  @override
  final String id;

  /// common.apps.id (当前应用唯一标识)
  @override
  @JsonKey(name: 'app_id')
  final String appId;

  /// auth.users.id (Supabase 底层认证 UID)
  @override
  @JsonKey(name: 'supabase_uid')
  final String supabaseUid;

  /// 是否为匿名访客
  @override
  @JsonKey(name: 'is_anonymous')
  final bool isAnonymous;

  /// 认证提供商 ('anonymous' | 'apple' | 'google' | 'email')
  @override
  @JsonKey(name: 'auth_provider')
  final String authProvider;

  /// 标识当前登录是否为刚刚注册的新用户
  @override
  @JsonKey(name: 'is_new_user')
  final bool isNewUser;

  /// 绑定邮箱
  @override
  final String? email;

  /// 绑定手机号
  @override
  final String? phone;

  /// 用户展示昵称
  @override
  @JsonKey(name: 'display_name')
  final String displayName;

  /// 用户头像 URL
  @override
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  /// 用户风控级别 ('normal' | 'high' | 'banned')
  @override
  @JsonKey(name: 'risk_level')
  final String riskLevel;

  /// 用户全量资产与权益列表 (统一承载会员、积分、额度)
  final List<EntitlementInfo> _entitlements;

  /// 用户全量资产与权益列表 (统一承载会员、积分、额度)
  @override
  @JsonKey()
  List<EntitlementInfo> get entitlements {
    if (_entitlements is EqualUnmodifiableListView) return _entitlements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_entitlements);
  }

  /// 最近登录活跃时间
  @override
  @JsonKey(name: 'last_login_at')
  final DateTime? lastLoginAt;

  /// 账号注册时间
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'UserData(id: $id, appId: $appId, supabaseUid: $supabaseUid, isAnonymous: $isAnonymous, authProvider: $authProvider, isNewUser: $isNewUser, email: $email, phone: $phone, displayName: $displayName, avatarUrl: $avatarUrl, riskLevel: $riskLevel, entitlements: $entitlements, lastLoginAt: $lastLoginAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.appId, appId) || other.appId == appId) &&
            (identical(other.supabaseUid, supabaseUid) ||
                other.supabaseUid == supabaseUid) &&
            (identical(other.isAnonymous, isAnonymous) ||
                other.isAnonymous == isAnonymous) &&
            (identical(other.authProvider, authProvider) ||
                other.authProvider == authProvider) &&
            (identical(other.isNewUser, isNewUser) ||
                other.isNewUser == isNewUser) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.riskLevel, riskLevel) ||
                other.riskLevel == riskLevel) &&
            const DeepCollectionEquality().equals(
              other._entitlements,
              _entitlements,
            ) &&
            (identical(other.lastLoginAt, lastLoginAt) ||
                other.lastLoginAt == lastLoginAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    appId,
    supabaseUid,
    isAnonymous,
    authProvider,
    isNewUser,
    email,
    phone,
    displayName,
    avatarUrl,
    riskLevel,
    const DeepCollectionEquality().hash(_entitlements),
    lastLoginAt,
    createdAt,
  );

  /// Create a copy of UserData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserDataImplCopyWith<_$UserDataImpl> get copyWith =>
      __$$UserDataImplCopyWithImpl<_$UserDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserDataImplToJson(this);
  }
}

abstract class _UserData extends UserData {
  const factory _UserData({
    required final String id,
    @JsonKey(name: 'app_id') required final String appId,
    @JsonKey(name: 'supabase_uid') required final String supabaseUid,
    @JsonKey(name: 'is_anonymous') final bool isAnonymous,
    @JsonKey(name: 'auth_provider') final String authProvider,
    @JsonKey(name: 'is_new_user') final bool isNewUser,
    final String? email,
    final String? phone,
    @JsonKey(name: 'display_name') required final String displayName,
    @JsonKey(name: 'avatar_url') final String? avatarUrl,
    @JsonKey(name: 'risk_level') final String riskLevel,
    final List<EntitlementInfo> entitlements,
    @JsonKey(name: 'last_login_at') final DateTime? lastLoginAt,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$UserDataImpl;
  const _UserData._() : super._();

  factory _UserData.fromJson(Map<String, dynamic> json) =
      _$UserDataImpl.fromJson;

  /// common.users.id (业务系统统一 UUID)
  @override
  String get id;

  /// common.apps.id (当前应用唯一标识)
  @override
  @JsonKey(name: 'app_id')
  String get appId;

  /// auth.users.id (Supabase 底层认证 UID)
  @override
  @JsonKey(name: 'supabase_uid')
  String get supabaseUid;

  /// 是否为匿名访客
  @override
  @JsonKey(name: 'is_anonymous')
  bool get isAnonymous;

  /// 认证提供商 ('anonymous' | 'apple' | 'google' | 'email')
  @override
  @JsonKey(name: 'auth_provider')
  String get authProvider;

  /// 标识当前登录是否为刚刚注册的新用户
  @override
  @JsonKey(name: 'is_new_user')
  bool get isNewUser;

  /// 绑定邮箱
  @override
  String? get email;

  /// 绑定手机号
  @override
  String? get phone;

  /// 用户展示昵称
  @override
  @JsonKey(name: 'display_name')
  String get displayName;

  /// 用户头像 URL
  @override
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl;

  /// 用户风控级别 ('normal' | 'high' | 'banned')
  @override
  @JsonKey(name: 'risk_level')
  String get riskLevel;

  /// 用户全量资产与权益列表 (统一承载会员、积分、额度)
  @override
  List<EntitlementInfo> get entitlements;

  /// 最近登录活跃时间
  @override
  @JsonKey(name: 'last_login_at')
  DateTime? get lastLoginAt;

  /// 账号注册时间
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of UserData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserDataImplCopyWith<_$UserDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
