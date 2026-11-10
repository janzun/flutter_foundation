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
  /// 业务唯一编码 (如: 'vip_monthly_ios')
  String get code => throw _privateConstructorUsedError;

  /// 关联应用唯一 UUID
  String get appId => throw _privateConstructorUsedError;

  /// 商品分组 (如: 'subscription', 'points', 'single_pass')
  String get group => throw _privateConstructorUsedError;

  /// 商品显示名称
  String get name => throw _privateConstructorUsedError;

  /// 商品副标题与权益描述
  String get description => throw _privateConstructorUsedError;

  /// 基准参考价格 (单位: 元/美元)
  double get price => throw _privateConstructorUsedError;

  /// 货币代码 (如: 'USD', 'CNY')
  String get currency => throw _privateConstructorUsedError;

  /// 商店本地化格式价格 (如: '$4.99', '¥30.00')
  String get localizedPrice => throw _privateConstructorUsedError;

  /// 官方标准交易类型
  ProductType get type => throw _privateConstructorUsedError;

  /// 计费周期
  BillingCycle get billingCycle => throw _privateConstructorUsedError;

  /// 目标平台 ('ios', 'android', 'web')
  String get platform => throw _privateConstructorUsedError;

  /// 对应商店/支付方式 ('app_store', 'play_store', 'stripe')
  String get store => throw _privateConstructorUsedError;

  /// 商店中配置的真实内购产品 ID (如: 'com.rtt.vip.monthly')
  String get storeProductId => throw _privateConstructorUsedError;

  /// 商店专属的额外信息参数字典 (如: {"base_plan_id": "monthly-standard"})
  Map<String, dynamic> get storeParams => throw _privateConstructorUsedError;

  /// 附赠会员级别 (如: 'pro', 'svip')
  String? get rewardTier => throw _privateConstructorUsedError;

  /// 附赠会员时长天数
  int get rewardDurationDays => throw _privateConstructorUsedError;

  /// 附赠积分数值
  double get rewardPoints => throw _privateConstructorUsedError;

  /// 附赠混合特权字典 (如: {"ai_quota": 50})
  Map<String, dynamic> get rewardPerks => throw _privateConstructorUsedError;

  /// 排序权重
  int get sortOrder => throw _privateConstructorUsedError;

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
    String appId,
    String group,
    String name,
    String description,
    double price,
    String currency,
    String localizedPrice,
    ProductType type,
    BillingCycle billingCycle,
    String platform,
    String store,
    String storeProductId,
    Map<String, dynamic> storeParams,
    String? rewardTier,
    int rewardDurationDays,
    double rewardPoints,
    Map<String, dynamic> rewardPerks,
    int sortOrder,
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
    Object? appId = null,
    Object? group = null,
    Object? name = null,
    Object? description = null,
    Object? price = null,
    Object? currency = null,
    Object? localizedPrice = null,
    Object? type = null,
    Object? billingCycle = null,
    Object? platform = null,
    Object? store = null,
    Object? storeProductId = null,
    Object? storeParams = null,
    Object? rewardTier = freezed,
    Object? rewardDurationDays = null,
    Object? rewardPoints = null,
    Object? rewardPerks = null,
    Object? sortOrder = null,
  }) {
    return _then(
      _value.copyWith(
            code:
                null == code
                    ? _value.code
                    : code // ignore: cast_nullable_to_non_nullable
                        as String,
            appId:
                null == appId
                    ? _value.appId
                    : appId // ignore: cast_nullable_to_non_nullable
                        as String,
            group:
                null == group
                    ? _value.group
                    : group // ignore: cast_nullable_to_non_nullable
                        as String,
            name:
                null == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String,
            description:
                null == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
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
            localizedPrice:
                null == localizedPrice
                    ? _value.localizedPrice
                    : localizedPrice // ignore: cast_nullable_to_non_nullable
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
            platform:
                null == platform
                    ? _value.platform
                    : platform // ignore: cast_nullable_to_non_nullable
                        as String,
            store:
                null == store
                    ? _value.store
                    : store // ignore: cast_nullable_to_non_nullable
                        as String,
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
            rewardTier:
                freezed == rewardTier
                    ? _value.rewardTier
                    : rewardTier // ignore: cast_nullable_to_non_nullable
                        as String?,
            rewardDurationDays:
                null == rewardDurationDays
                    ? _value.rewardDurationDays
                    : rewardDurationDays // ignore: cast_nullable_to_non_nullable
                        as int,
            rewardPoints:
                null == rewardPoints
                    ? _value.rewardPoints
                    : rewardPoints // ignore: cast_nullable_to_non_nullable
                        as double,
            rewardPerks:
                null == rewardPerks
                    ? _value.rewardPerks
                    : rewardPerks // ignore: cast_nullable_to_non_nullable
                        as Map<String, dynamic>,
            sortOrder:
                null == sortOrder
                    ? _value.sortOrder
                    : sortOrder // ignore: cast_nullable_to_non_nullable
                        as int,
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
    String appId,
    String group,
    String name,
    String description,
    double price,
    String currency,
    String localizedPrice,
    ProductType type,
    BillingCycle billingCycle,
    String platform,
    String store,
    String storeProductId,
    Map<String, dynamic> storeParams,
    String? rewardTier,
    int rewardDurationDays,
    double rewardPoints,
    Map<String, dynamic> rewardPerks,
    int sortOrder,
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
    Object? appId = null,
    Object? group = null,
    Object? name = null,
    Object? description = null,
    Object? price = null,
    Object? currency = null,
    Object? localizedPrice = null,
    Object? type = null,
    Object? billingCycle = null,
    Object? platform = null,
    Object? store = null,
    Object? storeProductId = null,
    Object? storeParams = null,
    Object? rewardTier = freezed,
    Object? rewardDurationDays = null,
    Object? rewardPoints = null,
    Object? rewardPerks = null,
    Object? sortOrder = null,
  }) {
    return _then(
      _$ProductInfoImpl(
        code:
            null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                    as String,
        appId:
            null == appId
                ? _value.appId
                : appId // ignore: cast_nullable_to_non_nullable
                    as String,
        group:
            null == group
                ? _value.group
                : group // ignore: cast_nullable_to_non_nullable
                    as String,
        name:
            null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String,
        description:
            null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
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
        localizedPrice:
            null == localizedPrice
                ? _value.localizedPrice
                : localizedPrice // ignore: cast_nullable_to_non_nullable
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
        platform:
            null == platform
                ? _value.platform
                : platform // ignore: cast_nullable_to_non_nullable
                    as String,
        store:
            null == store
                ? _value.store
                : store // ignore: cast_nullable_to_non_nullable
                    as String,
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
        rewardTier:
            freezed == rewardTier
                ? _value.rewardTier
                : rewardTier // ignore: cast_nullable_to_non_nullable
                    as String?,
        rewardDurationDays:
            null == rewardDurationDays
                ? _value.rewardDurationDays
                : rewardDurationDays // ignore: cast_nullable_to_non_nullable
                    as int,
        rewardPoints:
            null == rewardPoints
                ? _value.rewardPoints
                : rewardPoints // ignore: cast_nullable_to_non_nullable
                    as double,
        rewardPerks:
            null == rewardPerks
                ? _value._rewardPerks
                : rewardPerks // ignore: cast_nullable_to_non_nullable
                    as Map<String, dynamic>,
        sortOrder:
            null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                    as int,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class _$ProductInfoImpl implements _ProductInfo {
  const _$ProductInfoImpl({
    required this.code,
    required this.appId,
    required this.group,
    required this.name,
    this.description = '',
    required this.price,
    this.currency = 'USD',
    this.localizedPrice = '',
    required this.type,
    this.billingCycle = BillingCycle.oneOff,
    required this.platform,
    required this.store,
    required this.storeProductId,
    final Map<String, dynamic> storeParams = const <String, dynamic>{},
    this.rewardTier,
    this.rewardDurationDays = 0,
    this.rewardPoints = 0.0,
    final Map<String, dynamic> rewardPerks = const <String, dynamic>{},
    this.sortOrder = 0,
  }) : _storeParams = storeParams,
       _rewardPerks = rewardPerks;

  factory _$ProductInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductInfoImplFromJson(json);

  /// 业务唯一编码 (如: 'vip_monthly_ios')
  @override
  final String code;

  /// 关联应用唯一 UUID
  @override
  final String appId;

  /// 商品分组 (如: 'subscription', 'points', 'single_pass')
  @override
  final String group;

  /// 商品显示名称
  @override
  final String name;

  /// 商品副标题与权益描述
  @override
  @JsonKey()
  final String description;

  /// 基准参考价格 (单位: 元/美元)
  @override
  final double price;

  /// 货币代码 (如: 'USD', 'CNY')
  @override
  @JsonKey()
  final String currency;

  /// 商店本地化格式价格 (如: '$4.99', '¥30.00')
  @override
  @JsonKey()
  final String localizedPrice;

  /// 官方标准交易类型
  @override
  final ProductType type;

  /// 计费周期
  @override
  @JsonKey()
  final BillingCycle billingCycle;

  /// 目标平台 ('ios', 'android', 'web')
  @override
  final String platform;

  /// 对应商店/支付方式 ('app_store', 'play_store', 'stripe')
  @override
  final String store;

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

  /// 附赠会员级别 (如: 'pro', 'svip')
  @override
  final String? rewardTier;

  /// 附赠会员时长天数
  @override
  @JsonKey()
  final int rewardDurationDays;

  /// 附赠积分数值
  @override
  @JsonKey()
  final double rewardPoints;

  /// 附赠混合特权字典 (如: {"ai_quota": 50})
  final Map<String, dynamic> _rewardPerks;

  /// 附赠混合特权字典 (如: {"ai_quota": 50})
  @override
  @JsonKey()
  Map<String, dynamic> get rewardPerks {
    if (_rewardPerks is EqualUnmodifiableMapView) return _rewardPerks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_rewardPerks);
  }

  /// 排序权重
  @override
  @JsonKey()
  final int sortOrder;

  @override
  String toString() {
    return 'ProductInfo(code: $code, appId: $appId, group: $group, name: $name, description: $description, price: $price, currency: $currency, localizedPrice: $localizedPrice, type: $type, billingCycle: $billingCycle, platform: $platform, store: $store, storeProductId: $storeProductId, storeParams: $storeParams, rewardTier: $rewardTier, rewardDurationDays: $rewardDurationDays, rewardPoints: $rewardPoints, rewardPerks: $rewardPerks, sortOrder: $sortOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductInfoImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.appId, appId) || other.appId == appId) &&
            (identical(other.group, group) || other.group == group) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.localizedPrice, localizedPrice) ||
                other.localizedPrice == localizedPrice) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.billingCycle, billingCycle) ||
                other.billingCycle == billingCycle) &&
            (identical(other.platform, platform) ||
                other.platform == platform) &&
            (identical(other.store, store) || other.store == store) &&
            (identical(other.storeProductId, storeProductId) ||
                other.storeProductId == storeProductId) &&
            const DeepCollectionEquality().equals(
              other._storeParams,
              _storeParams,
            ) &&
            (identical(other.rewardTier, rewardTier) ||
                other.rewardTier == rewardTier) &&
            (identical(other.rewardDurationDays, rewardDurationDays) ||
                other.rewardDurationDays == rewardDurationDays) &&
            (identical(other.rewardPoints, rewardPoints) ||
                other.rewardPoints == rewardPoints) &&
            const DeepCollectionEquality().equals(
              other._rewardPerks,
              _rewardPerks,
            ) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    code,
    appId,
    group,
    name,
    description,
    price,
    currency,
    localizedPrice,
    type,
    billingCycle,
    platform,
    store,
    storeProductId,
    const DeepCollectionEquality().hash(_storeParams),
    rewardTier,
    rewardDurationDays,
    rewardPoints,
    const DeepCollectionEquality().hash(_rewardPerks),
    sortOrder,
  ]);

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
    required final String appId,
    required final String group,
    required final String name,
    final String description,
    required final double price,
    final String currency,
    final String localizedPrice,
    required final ProductType type,
    final BillingCycle billingCycle,
    required final String platform,
    required final String store,
    required final String storeProductId,
    final Map<String, dynamic> storeParams,
    final String? rewardTier,
    final int rewardDurationDays,
    final double rewardPoints,
    final Map<String, dynamic> rewardPerks,
    final int sortOrder,
  }) = _$ProductInfoImpl;

  factory _ProductInfo.fromJson(Map<String, dynamic> json) =
      _$ProductInfoImpl.fromJson;

  /// 业务唯一编码 (如: 'vip_monthly_ios')
  @override
  String get code;

  /// 关联应用唯一 UUID
  @override
  String get appId;

  /// 商品分组 (如: 'subscription', 'points', 'single_pass')
  @override
  String get group;

  /// 商品显示名称
  @override
  String get name;

  /// 商品副标题与权益描述
  @override
  String get description;

  /// 基准参考价格 (单位: 元/美元)
  @override
  double get price;

  /// 货币代码 (如: 'USD', 'CNY')
  @override
  String get currency;

  /// 商店本地化格式价格 (如: '$4.99', '¥30.00')
  @override
  String get localizedPrice;

  /// 官方标准交易类型
  @override
  ProductType get type;

  /// 计费周期
  @override
  BillingCycle get billingCycle;

  /// 目标平台 ('ios', 'android', 'web')
  @override
  String get platform;

  /// 对应商店/支付方式 ('app_store', 'play_store', 'stripe')
  @override
  String get store;

  /// 商店中配置的真实内购产品 ID (如: 'com.rtt.vip.monthly')
  @override
  String get storeProductId;

  /// 商店专属的额外信息参数字典 (如: {"base_plan_id": "monthly-standard"})
  @override
  Map<String, dynamic> get storeParams;

  /// 附赠会员级别 (如: 'pro', 'svip')
  @override
  String? get rewardTier;

  /// 附赠会员时长天数
  @override
  int get rewardDurationDays;

  /// 附赠积分数值
  @override
  double get rewardPoints;

  /// 附赠混合特权字典 (如: {"ai_quota": 50})
  @override
  Map<String, dynamic> get rewardPerks;

  /// 排序权重
  @override
  int get sortOrder;

  /// Create a copy of ProductInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductInfoImplCopyWith<_$ProductInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
