// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pay_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PayResult _$PayResultFromJson(Map<String, dynamic> json) {
  return _PayResult.fromJson(json);
}

/// @nodoc
mixin _$PayResult {
  /// 状态枚举
  PayStatus get status => throw _privateConstructorUsedError;

  /// 支付渠道交易号 (如有)
  String? get channelTransactionId => throw _privateConstructorUsedError;

  /// 购买的商品唯一编码
  String? get productCode => throw _privateConstructorUsedError;

  /// 错误信息 (失败时有效)
  String? get errorMessage => throw _privateConstructorUsedError;

  /// 原始返回数据上下文
  Map<String, dynamic> get rawDetails => throw _privateConstructorUsedError;

  /// Serializes this PayResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PayResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PayResultCopyWith<PayResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PayResultCopyWith<$Res> {
  factory $PayResultCopyWith(PayResult value, $Res Function(PayResult) then) =
      _$PayResultCopyWithImpl<$Res, PayResult>;
  @useResult
  $Res call({
    PayStatus status,
    String? channelTransactionId,
    String? productCode,
    String? errorMessage,
    Map<String, dynamic> rawDetails,
  });
}

/// @nodoc
class _$PayResultCopyWithImpl<$Res, $Val extends PayResult>
    implements $PayResultCopyWith<$Res> {
  _$PayResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PayResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? channelTransactionId = freezed,
    Object? productCode = freezed,
    Object? errorMessage = freezed,
    Object? rawDetails = null,
  }) {
    return _then(
      _value.copyWith(
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as PayStatus,
            channelTransactionId:
                freezed == channelTransactionId
                    ? _value.channelTransactionId
                    : channelTransactionId // ignore: cast_nullable_to_non_nullable
                        as String?,
            productCode:
                freezed == productCode
                    ? _value.productCode
                    : productCode // ignore: cast_nullable_to_non_nullable
                        as String?,
            errorMessage:
                freezed == errorMessage
                    ? _value.errorMessage
                    : errorMessage // ignore: cast_nullable_to_non_nullable
                        as String?,
            rawDetails:
                null == rawDetails
                    ? _value.rawDetails
                    : rawDetails // ignore: cast_nullable_to_non_nullable
                        as Map<String, dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PayResultImplCopyWith<$Res>
    implements $PayResultCopyWith<$Res> {
  factory _$$PayResultImplCopyWith(
    _$PayResultImpl value,
    $Res Function(_$PayResultImpl) then,
  ) = __$$PayResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    PayStatus status,
    String? channelTransactionId,
    String? productCode,
    String? errorMessage,
    Map<String, dynamic> rawDetails,
  });
}

/// @nodoc
class __$$PayResultImplCopyWithImpl<$Res>
    extends _$PayResultCopyWithImpl<$Res, _$PayResultImpl>
    implements _$$PayResultImplCopyWith<$Res> {
  __$$PayResultImplCopyWithImpl(
    _$PayResultImpl _value,
    $Res Function(_$PayResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PayResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? channelTransactionId = freezed,
    Object? productCode = freezed,
    Object? errorMessage = freezed,
    Object? rawDetails = null,
  }) {
    return _then(
      _$PayResultImpl(
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as PayStatus,
        channelTransactionId:
            freezed == channelTransactionId
                ? _value.channelTransactionId
                : channelTransactionId // ignore: cast_nullable_to_non_nullable
                    as String?,
        productCode:
            freezed == productCode
                ? _value.productCode
                : productCode // ignore: cast_nullable_to_non_nullable
                    as String?,
        errorMessage:
            freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                    as String?,
        rawDetails:
            null == rawDetails
                ? _value._rawDetails
                : rawDetails // ignore: cast_nullable_to_non_nullable
                    as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$PayResultImpl implements _PayResult {
  const _$PayResultImpl({
    required this.status,
    this.channelTransactionId,
    this.productCode,
    this.errorMessage,
    final Map<String, dynamic> rawDetails = const <String, dynamic>{},
  }) : _rawDetails = rawDetails;

  factory _$PayResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$PayResultImplFromJson(json);

  /// 状态枚举
  @override
  final PayStatus status;

  /// 支付渠道交易号 (如有)
  @override
  final String? channelTransactionId;

  /// 购买的商品唯一编码
  @override
  final String? productCode;

  /// 错误信息 (失败时有效)
  @override
  final String? errorMessage;

  /// 原始返回数据上下文
  final Map<String, dynamic> _rawDetails;

  /// 原始返回数据上下文
  @override
  @JsonKey()
  Map<String, dynamic> get rawDetails {
    if (_rawDetails is EqualUnmodifiableMapView) return _rawDetails;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_rawDetails);
  }

  @override
  String toString() {
    return 'PayResult(status: $status, channelTransactionId: $channelTransactionId, productCode: $productCode, errorMessage: $errorMessage, rawDetails: $rawDetails)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PayResultImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.channelTransactionId, channelTransactionId) ||
                other.channelTransactionId == channelTransactionId) &&
            (identical(other.productCode, productCode) ||
                other.productCode == productCode) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            const DeepCollectionEquality().equals(
              other._rawDetails,
              _rawDetails,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    status,
    channelTransactionId,
    productCode,
    errorMessage,
    const DeepCollectionEquality().hash(_rawDetails),
  );

  /// Create a copy of PayResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PayResultImplCopyWith<_$PayResultImpl> get copyWith =>
      __$$PayResultImplCopyWithImpl<_$PayResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PayResultImplToJson(this);
  }
}

abstract class _PayResult implements PayResult {
  const factory _PayResult({
    required final PayStatus status,
    final String? channelTransactionId,
    final String? productCode,
    final String? errorMessage,
    final Map<String, dynamic> rawDetails,
  }) = _$PayResultImpl;

  factory _PayResult.fromJson(Map<String, dynamic> json) =
      _$PayResultImpl.fromJson;

  /// 状态枚举
  @override
  PayStatus get status;

  /// 支付渠道交易号 (如有)
  @override
  String? get channelTransactionId;

  /// 购买的商品唯一编码
  @override
  String? get productCode;

  /// 错误信息 (失败时有效)
  @override
  String? get errorMessage;

  /// 原始返回数据上下文
  @override
  Map<String, dynamic> get rawDetails;

  /// Create a copy of PayResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PayResultImplCopyWith<_$PayResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
