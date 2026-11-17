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

  /// 是否为匿名访客
  @JsonKey(name: 'is_anonymous')
  bool get isAnonymous => throw _privateConstructorUsedError;

  /// 标识当前登录是否为刚刚注册的新用户
  @JsonKey(name: 'is_new_user')
  bool get isNewUser => throw _privateConstructorUsedError;

  /// 用户展示昵称
  @JsonKey(name: 'display_name')
  String get displayName => throw _privateConstructorUsedError;

  /// 绑定邮箱
  String? get email => throw _privateConstructorUsedError;

  /// 用户头像 URL
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl => throw _privateConstructorUsedError;

  /// 用户全量资产与权益列表 (统一承载会员、积分、额度)
  List<EntitlementInfo> get entitlements => throw _privateConstructorUsedError;

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
    @JsonKey(name: 'is_anonymous') bool isAnonymous,
    @JsonKey(name: 'is_new_user') bool isNewUser,
    @JsonKey(name: 'display_name') String displayName,
    String? email,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    List<EntitlementInfo> entitlements,
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
    Object? isAnonymous = null,
    Object? isNewUser = null,
    Object? displayName = null,
    Object? email = freezed,
    Object? avatarUrl = freezed,
    Object? entitlements = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            isAnonymous:
                null == isAnonymous
                    ? _value.isAnonymous
                    : isAnonymous // ignore: cast_nullable_to_non_nullable
                        as bool,
            isNewUser:
                null == isNewUser
                    ? _value.isNewUser
                    : isNewUser // ignore: cast_nullable_to_non_nullable
                        as bool,
            displayName:
                null == displayName
                    ? _value.displayName
                    : displayName // ignore: cast_nullable_to_non_nullable
                        as String,
            email:
                freezed == email
                    ? _value.email
                    : email // ignore: cast_nullable_to_non_nullable
                        as String?,
            avatarUrl:
                freezed == avatarUrl
                    ? _value.avatarUrl
                    : avatarUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
            entitlements:
                null == entitlements
                    ? _value.entitlements
                    : entitlements // ignore: cast_nullable_to_non_nullable
                        as List<EntitlementInfo>,
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
    @JsonKey(name: 'is_anonymous') bool isAnonymous,
    @JsonKey(name: 'is_new_user') bool isNewUser,
    @JsonKey(name: 'display_name') String displayName,
    String? email,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    List<EntitlementInfo> entitlements,
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
    Object? isAnonymous = null,
    Object? isNewUser = null,
    Object? displayName = null,
    Object? email = freezed,
    Object? avatarUrl = freezed,
    Object? entitlements = null,
  }) {
    return _then(
      _$UserDataImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        isAnonymous:
            null == isAnonymous
                ? _value.isAnonymous
                : isAnonymous // ignore: cast_nullable_to_non_nullable
                    as bool,
        isNewUser:
            null == isNewUser
                ? _value.isNewUser
                : isNewUser // ignore: cast_nullable_to_non_nullable
                    as bool,
        displayName:
            null == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                    as String,
        email:
            freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                    as String?,
        avatarUrl:
            freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
        entitlements:
            null == entitlements
                ? _value._entitlements
                : entitlements // ignore: cast_nullable_to_non_nullable
                    as List<EntitlementInfo>,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$UserDataImpl extends _UserData {
  const _$UserDataImpl({
    required this.id,
    @JsonKey(name: 'is_anonymous') this.isAnonymous = false,
    @JsonKey(name: 'is_new_user') this.isNewUser = false,
    @JsonKey(name: 'display_name') required this.displayName,
    this.email,
    @JsonKey(name: 'avatar_url') this.avatarUrl,
    final List<EntitlementInfo> entitlements = const <EntitlementInfo>[],
  }) : _entitlements = entitlements,
       super._();

  factory _$UserDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserDataImplFromJson(json);

  /// common.users.id (业务系统统一 UUID)
  @override
  final String id;

  /// 是否为匿名访客
  @override
  @JsonKey(name: 'is_anonymous')
  final bool isAnonymous;

  /// 标识当前登录是否为刚刚注册的新用户
  @override
  @JsonKey(name: 'is_new_user')
  final bool isNewUser;

  /// 用户展示昵称
  @override
  @JsonKey(name: 'display_name')
  final String displayName;

  /// 绑定邮箱
  @override
  final String? email;

  /// 用户头像 URL
  @override
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

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

  @override
  String toString() {
    return 'UserData(id: $id, isAnonymous: $isAnonymous, isNewUser: $isNewUser, displayName: $displayName, email: $email, avatarUrl: $avatarUrl, entitlements: $entitlements)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.isAnonymous, isAnonymous) ||
                other.isAnonymous == isAnonymous) &&
            (identical(other.isNewUser, isNewUser) ||
                other.isNewUser == isNewUser) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            const DeepCollectionEquality().equals(
              other._entitlements,
              _entitlements,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    isAnonymous,
    isNewUser,
    displayName,
    email,
    avatarUrl,
    const DeepCollectionEquality().hash(_entitlements),
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
    @JsonKey(name: 'is_anonymous') final bool isAnonymous,
    @JsonKey(name: 'is_new_user') final bool isNewUser,
    @JsonKey(name: 'display_name') required final String displayName,
    final String? email,
    @JsonKey(name: 'avatar_url') final String? avatarUrl,
    final List<EntitlementInfo> entitlements,
  }) = _$UserDataImpl;
  const _UserData._() : super._();

  factory _UserData.fromJson(Map<String, dynamic> json) =
      _$UserDataImpl.fromJson;

  /// common.users.id (业务系统统一 UUID)
  @override
  String get id;

  /// 是否为匿名访客
  @override
  @JsonKey(name: 'is_anonymous')
  bool get isAnonymous;

  /// 标识当前登录是否为刚刚注册的新用户
  @override
  @JsonKey(name: 'is_new_user')
  bool get isNewUser;

  /// 用户展示昵称
  @override
  @JsonKey(name: 'display_name')
  String get displayName;

  /// 绑定邮箱
  @override
  String? get email;

  /// 用户头像 URL
  @override
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl;

  /// 用户全量资产与权益列表 (统一承载会员、积分、额度)
  @override
  List<EntitlementInfo> get entitlements;

  /// Create a copy of UserData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserDataImplCopyWith<_$UserDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
