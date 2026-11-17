// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProductInfo _$ProductInfoFromJson(Map<String, dynamic> json) {
  return _ProductInfo.fromJson(json);
}

/// @nodoc
mixin _$ProductInfo {
  /// 业务唯一编码 (前端据此做 l10n 文案与权益映射，如: 'vip_monthly_ios')
  String get code => throw _privateConstructorUsedError;

  /// 商品分组 (如: 'subscription', 'points', 'single_pass')
  String get group => throw _privateConstructorUsedError;

  /// 官方标准交易类型
  ProductType get type => throw _privateConstructorUsedError;

  /// 计费周期
  BillingCycle get billingCycle => throw _privateConstructorUsedError;

  /// 商店中配置的真实内购产品 ID (如: 'com.rtt.vip.monthly')
  String get storeProductId => throw _privateConstructorUsedError;

  /// 商店专属的额外信息参数字典 (如: {"base_plan_id": "monthly-standard"})
  Map<String, dynamic> get storeParams => throw _privateConstructorUsedError;

  /// 商店本地化格式价格 (100% 由商店 API 实时填充，如: '$4.99', '¥30.00')
  String get localizedPrice => throw _privateConstructorUsedError;

  /// 商店实时参考数值 (100% 由商店 API 实时填充，便于前端计算折扣率)
  double get price => throw _privateConstructorUsedError;

  /// 商店实时货币代码 (100% 由商店 API 实时填充，如: 'USD', 'CNY')
  String get currency => throw _privateConstructorUsedError;

  /// Serializes this ProductInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductInfoCopyWith<ProductInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductInfoCopyWith<$Res> {
  factory $ProductInfoCopyWith(
    ProductInfo value,
    $Res Function(ProductInfo) then,
  ) = _$ProductInfoCopyWithImpl<$Res, ProductInfo>;
  @useResult
  $Res call({
    String code,
    String group,
    ProductType type,
    BillingCycle billingCycle,
    String storeProductId,
    Map<String, dynamic> storeParams,
    String localizedPrice,
    double price,
    String currency,
  });
}

/// @nodoc
class _$ProductInfoCopyWithImpl<$Res, $Val extends ProductInfo>
    implements $ProductInfoCopyWith<$Res> {
  _$ProductInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? group = null,
    Object? type = null,
    Object? billingCycle = null,
    Object? storeProductId = null,
    Object? storeParams = null,
    Object? localizedPrice = null,
    Object? price = null,
    Object? currency = null,
  }) {
    return _then(
      _value.copyWith(
            code:
                null == code
                    ? _value.code
                    : code // ignore: cast_nullable_to_non_nullable
                        as String,
            group:
                null == group
                    ? _value.group
                    : group // ignore: cast_nullable_to_non_nullable
                        as String,
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
                        as ProductType,
            billingCycle:
                null == billingCycle
                    ? _value.billingCycle
                    : billingCycle // ignore: cast_nullable_to_non_nullable
                        as BillingCycle,
            storeProductId:
                null == storeProductId
                    ? _value.storeProductId
                    : storeProductId // ignore: cast_nullable_to_non_nullable
                        as String,
            storeParams:
                null == storeParams
                    ? _value.storeParams
                    : storeParams // ignore: cast_nullable_to_non_nullable
                        as Map<String, dynamic>,
            localizedPrice:
                null == localizedPrice
                    ? _value.localizedPrice
                    : localizedPrice // ignore: cast_nullable_to_non_nullable
                        as String,
            price:
                null == price
                    ? _value.price
                    : price // ignore: cast_nullable_to_non_nullable
                        as double,
            currency:
                null == currency
                    ? _value.currency
                    : currency // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductInfoImplCopyWith<$Res>
    implements $ProductInfoCopyWith<$Res> {
  factory _$$ProductInfoImplCopyWith(
    _$ProductInfoImpl value,
    $Res Function(_$ProductInfoImpl) then,
  ) = __$$ProductInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String code,
    String group,
    ProductType type,
    BillingCycle billingCycle,
    String storeProductId,
    Map<String, dynamic> storeParams,
    String localizedPrice,
    double price,
    String currency,
  });
}

/// @nodoc
class __$$ProductInfoImplCopyWithImpl<$Res>
    extends _$ProductInfoCopyWithImpl<$Res, _$ProductInfoImpl>
    implements _$$ProductInfoImplCopyWith<$Res> {
  __$$ProductInfoImplCopyWithImpl(
    _$ProductInfoImpl _value,
    $Res Function(_$ProductInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? group = null,
    Object? type = null,
    Object? billingCycle = null,
    Object? storeProductId = null,
    Object? storeParams = null,
    Object? localizedPrice = null,
    Object? price = null,
    Object? currency = null,
  }) {
    return _then(
      _$ProductInfoImpl(
        code:
            null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                    as String,
        group:
            null == group
                ? _value.group
                : group // ignore: cast_nullable_to_non_nullable
                    as String,
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                    as ProductType,
        billingCycle:
            null == billingCycle
                ? _value.billingCycle
                : billingCycle // ignore: cast_nullable_to_non_nullable
                    as BillingCycle,
        storeProductId:
            null == storeProductId
                ? _value.storeProductId
                : storeProductId // ignore: cast_nullable_to_non_nullable
                    as String,
        storeParams:
            null == storeParams
                ? _value._storeParams
                : storeParams // ignore: cast_nullable_to_non_nullable
                    as Map<String, dynamic>,
        localizedPrice:
            null == localizedPrice
                ? _value.localizedPrice
                : localizedPrice // ignore: cast_nullable_to_non_nullable
                    as String,
        price:
            null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                    as double,
        currency:
            null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class _$ProductInfoImpl implements _ProductInfo {
  const _$ProductInfoImpl({
    required this.code,
    required this.group,
    required this.type,
    this.billingCycle = BillingCycle.oneOff,
    required this.storeProductId,
    final Map<String, dynamic> storeParams = const <String, dynamic>{},
    this.localizedPrice = '',
    this.price = 0.0,
    this.currency = '',
  }) : _storeParams = storeParams;

  factory _$ProductInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductInfoImplFromJson(json);

  /// 业务唯一编码 (前端据此做 l10n 文案与权益映射，如: 'vip_monthly_ios')
  @override
  final String code;

  /// 商品分组 (如: 'subscription', 'points', 'single_pass')
  @override
  final String group;

  /// 官方标准交易类型
  @override
  final ProductType type;

  /// 计费周期
  @override
  @JsonKey()
  final BillingCycle billingCycle;

  /// 商店中配置的真实内购产品 ID (如: 'com.rtt.vip.monthly')
  @override
  final String storeProductId;

  /// 商店专属的额外信息参数字典 (如: {"base_plan_id": "monthly-standard"})
  final Map<String, dynamic> _storeParams;

  /// 商店专属的额外信息参数字典 (如: {"base_plan_id": "monthly-standard"})
  @override
  @JsonKey()
  Map<String, dynamic> get storeParams {
    if (_storeParams is EqualUnmodifiableMapView) return _storeParams;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_storeParams);
  }

  /// 商店本地化格式价格 (100% 由商店 API 实时填充，如: '$4.99', '¥30.00')
  @override
  @JsonKey()
  final String localizedPrice;

  /// 商店实时参考数值 (100% 由商店 API 实时填充，便于前端计算折扣率)
  @override
  @JsonKey()
  final double price;

  /// 商店实时货币代码 (100% 由商店 API 实时填充，如: 'USD', 'CNY')
  @override
  @JsonKey()
  final String currency;

  @override
  String toString() {
    return 'ProductInfo(code: $code, group: $group, type: $type, billingCycle: $billingCycle, storeProductId: $storeProductId, storeParams: $storeParams, localizedPrice: $localizedPrice, price: $price, currency: $currency)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductInfoImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.group, group) || other.group == group) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.billingCycle, billingCycle) ||
                other.billingCycle == billingCycle) &&
            (identical(other.storeProductId, storeProductId) ||
                other.storeProductId == storeProductId) &&
            const DeepCollectionEquality().equals(
              other._storeParams,
              _storeParams,
            ) &&
            (identical(other.localizedPrice, localizedPrice) ||
                other.localizedPrice == localizedPrice) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.currency, currency) ||
                other.currency == currency));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    code,
    group,
    type,
    billingCycle,
    storeProductId,
    const DeepCollectionEquality().hash(_storeParams),
    localizedPrice,
    price,
    currency,
  );

  /// Create a copy of ProductInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductInfoImplCopyWith<_$ProductInfoImpl> get copyWith =>
      __$$ProductInfoImplCopyWithImpl<_$ProductInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductInfoImplToJson(this);
  }
}

abstract class _ProductInfo implements ProductInfo {
  const factory _ProductInfo({
    required final String code,
    required final String group,
    required final ProductType type,
    final BillingCycle billingCycle,
    required final String storeProductId,
    final Map<String, dynamic> storeParams,
    final String localizedPrice,
    final double price,
    final String currency,
  }) = _$ProductInfoImpl;

  factory _ProductInfo.fromJson(Map<String, dynamic> json) =
      _$ProductInfoImpl.fromJson;

  /// 业务唯一编码 (前端据此做 l10n 文案与权益映射，如: 'vip_monthly_ios')
  @override
  String get code;

  /// 商品分组 (如: 'subscription', 'points', 'single_pass')
  @override
  String get group;

  /// 官方标准交易类型
  @override
  ProductType get type;

  /// 计费周期
  @override
  BillingCycle get billingCycle;

  /// 商店中配置的真实内购产品 ID (如: 'com.rtt.vip.monthly')
  @override
  String get storeProductId;

  /// 商店专属的额外信息参数字典 (如: {"base_plan_id": "monthly-standard"})
  @override
  Map<String, dynamic> get storeParams;

  /// 商店本地化格式价格 (100% 由商店 API 实时填充，如: '$4.99', '¥30.00')
  @override
  String get localizedPrice;

  /// 商店实时参考数值 (100% 由商店 API 实时填充，便于前端计算折扣率)
  @override
  double get price;

  /// 商店实时货币代码 (100% 由商店 API 实时填充，如: 'USD', 'CNY')
  @override
  String get currency;

  /// Create a copy of ProductInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductInfoImplCopyWith<_$ProductInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
