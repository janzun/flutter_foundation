// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'entitlement_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

EntitlementInfo _$EntitlementInfoFromJson(Map<String, dynamic> json) {
  return _EntitlementInfo.fromJson(json);
}

/// @nodoc
mixin _$EntitlementInfo {
  /// 资产标识
  String get id => throw _privateConstructorUsedError;

  /// 权益类别: 'membership', 'points', 'quota'
  String get type => throw _privateConstructorUsedError;

  /// 业务代码: 'vip', 'standard_point', 'ai_quota'
  String get code => throw _privateConstructorUsedError;

  /// 状态: 'active', 'expired', 'frozen'
  String get status => throw _privateConstructorUsedError;

  /// 会员等级 (type = 'membership' 时有效)
  String? get tier => throw _privateConstructorUsedError;

  /// 计费周期 (type = 'membership' 时有效)
  String? get billingCycle => throw _privateConstructorUsedError;

  /// 资产余额 (type = 'points' 或 'quota' 时有效)
  double get balance => throw _privateConstructorUsedError;

  /// 到期截止时间 (null 代表永久)
  DateTime? get expireAt => throw _privateConstructorUsedError;

  /// 授权可使用的端白名单
  List<String> get allowedPlatforms => throw _privateConstructorUsedError;

  /// Serializes this EntitlementInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EntitlementInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EntitlementInfoCopyWith<EntitlementInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EntitlementInfoCopyWith<$Res> {
  factory $EntitlementInfoCopyWith(
    EntitlementInfo value,
    $Res Function(EntitlementInfo) then,
  ) = _$EntitlementInfoCopyWithImpl<$Res, EntitlementInfo>;
  @useResult
  $Res call({
    String id,
    String type,
    String code,
    String status,
    String? tier,
    String? billingCycle,
    double balance,
    DateTime? expireAt,
    List<String> allowedPlatforms,
  });
}

/// @nodoc
class _$EntitlementInfoCopyWithImpl<$Res, $Val extends EntitlementInfo>
    implements $EntitlementInfoCopyWith<$Res> {
  _$EntitlementInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EntitlementInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? code = null,
    Object? status = null,
    Object? tier = freezed,
    Object? billingCycle = freezed,
    Object? balance = null,
    Object? expireAt = freezed,
    Object? allowedPlatforms = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
                        as String,
            code:
                null == code
                    ? _value.code
                    : code // ignore: cast_nullable_to_non_nullable
                        as String,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String,
            tier:
                freezed == tier
                    ? _value.tier
                    : tier // ignore: cast_nullable_to_non_nullable
                        as String?,
            billingCycle:
                freezed == billingCycle
                    ? _value.billingCycle
                    : billingCycle // ignore: cast_nullable_to_non_nullable
                        as String?,
            balance:
                null == balance
                    ? _value.balance
                    : balance // ignore: cast_nullable_to_non_nullable
                        as double,
            expireAt:
                freezed == expireAt
                    ? _value.expireAt
                    : expireAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            allowedPlatforms:
                null == allowedPlatforms
                    ? _value.allowedPlatforms
                    : allowedPlatforms // ignore: cast_nullable_to_non_nullable
                        as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EntitlementInfoImplCopyWith<$Res>
    implements $EntitlementInfoCopyWith<$Res> {
  factory _$$EntitlementInfoImplCopyWith(
    _$EntitlementInfoImpl value,
    $Res Function(_$EntitlementInfoImpl) then,
  ) = __$$EntitlementInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String type,
    String code,
    String status,
    String? tier,
    String? billingCycle,
    double balance,
    DateTime? expireAt,
    List<String> allowedPlatforms,
  });
}

/// @nodoc
class __$$EntitlementInfoImplCopyWithImpl<$Res>
    extends _$EntitlementInfoCopyWithImpl<$Res, _$EntitlementInfoImpl>
    implements _$$EntitlementInfoImplCopyWith<$Res> {
  __$$EntitlementInfoImplCopyWithImpl(
    _$EntitlementInfoImpl _value,
    $Res Function(_$EntitlementInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EntitlementInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? code = null,
    Object? status = null,
    Object? tier = freezed,
    Object? billingCycle = freezed,
    Object? balance = null,
    Object? expireAt = freezed,
    Object? allowedPlatforms = null,
  }) {
    return _then(
      _$EntitlementInfoImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                    as String,
        code:
            null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                    as String,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String,
        tier:
            freezed == tier
                ? _value.tier
                : tier // ignore: cast_nullable_to_non_nullable
                    as String?,
        billingCycle:
            freezed == billingCycle
                ? _value.billingCycle
                : billingCycle // ignore: cast_nullable_to_non_nullable
                    as String?,
        balance:
            null == balance
                ? _value.balance
                : balance // ignore: cast_nullable_to_non_nullable
                    as double,
        expireAt:
            freezed == expireAt
                ? _value.expireAt
                : expireAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        allowedPlatforms:
            null == allowedPlatforms
                ? _value._allowedPlatforms
                : allowedPlatforms // ignore: cast_nullable_to_non_nullable
                    as List<String>,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$EntitlementInfoImpl implements _EntitlementInfo {
  const _$EntitlementInfoImpl({
    required this.id,
    required this.type,
    required this.code,
    this.status = 'active',
    this.tier,
    this.billingCycle,
    this.balance = 0.0,
    this.expireAt,
    final List<String> allowedPlatforms = const <String>[
      'android',
      'ios',
      'web',
      'macos',
      'windows',
    ],
  }) : _allowedPlatforms = allowedPlatforms;

  factory _$EntitlementInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$EntitlementInfoImplFromJson(json);

  /// 资产标识
  @override
  final String id;

  /// 权益类别: 'membership', 'points', 'quota'
  @override
  final String type;

  /// 业务代码: 'vip', 'standard_point', 'ai_quota'
  @override
  final String code;

  /// 状态: 'active', 'expired', 'frozen'
  @override
  @JsonKey()
  final String status;

  /// 会员等级 (type = 'membership' 时有效)
  @override
  final String? tier;

  /// 计费周期 (type = 'membership' 时有效)
  @override
  final String? billingCycle;

  /// 资产余额 (type = 'points' 或 'quota' 时有效)
  @override
  @JsonKey()
  final double balance;

  /// 到期截止时间 (null 代表永久)
  @override
  final DateTime? expireAt;

  /// 授权可使用的端白名单
  final List<String> _allowedPlatforms;

  /// 授权可使用的端白名单
  @override
  @JsonKey()
  List<String> get allowedPlatforms {
    if (_allowedPlatforms is EqualUnmodifiableListView)
      return _allowedPlatforms;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allowedPlatforms);
  }

  @override
  String toString() {
    return 'EntitlementInfo(id: $id, type: $type, code: $code, status: $status, tier: $tier, billingCycle: $billingCycle, balance: $balance, expireAt: $expireAt, allowedPlatforms: $allowedPlatforms)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EntitlementInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.billingCycle, billingCycle) ||
                other.billingCycle == billingCycle) &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.expireAt, expireAt) ||
                other.expireAt == expireAt) &&
            const DeepCollectionEquality().equals(
              other._allowedPlatforms,
              _allowedPlatforms,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    type,
    code,
    status,
    tier,
    billingCycle,
    balance,
    expireAt,
    const DeepCollectionEquality().hash(_allowedPlatforms),
  );

  /// Create a copy of EntitlementInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EntitlementInfoImplCopyWith<_$EntitlementInfoImpl> get copyWith =>
      __$$EntitlementInfoImplCopyWithImpl<_$EntitlementInfoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$EntitlementInfoImplToJson(this);
  }
}

abstract class _EntitlementInfo implements EntitlementInfo {
  const factory _EntitlementInfo({
    required final String id,
    required final String type,
    required final String code,
    final String status,
    final String? tier,
    final String? billingCycle,
    final double balance,
    final DateTime? expireAt,
    final List<String> allowedPlatforms,
  }) = _$EntitlementInfoImpl;

  factory _EntitlementInfo.fromJson(Map<String, dynamic> json) =
      _$EntitlementInfoImpl.fromJson;

  /// 资产标识
  @override
  String get id;

  /// 权益类别: 'membership', 'points', 'quota'
  @override
  String get type;

  /// 业务代码: 'vip', 'standard_point', 'ai_quota'
  @override
  String get code;

  /// 状态: 'active', 'expired', 'frozen'
  @override
  String get status;

  /// 会员等级 (type = 'membership' 时有效)
  @override
  String? get tier;

  /// 计费周期 (type = 'membership' 时有效)
  @override
  String? get billingCycle;

  /// 资产余额 (type = 'points' 或 'quota' 时有效)
  @override
  double get balance;

  /// 到期截止时间 (null 代表永久)
  @override
  DateTime? get expireAt;

  /// 授权可使用的端白名单
  @override
  List<String> get allowedPlatforms;

  /// Create a copy of EntitlementInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EntitlementInfoImplCopyWith<_$EntitlementInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
