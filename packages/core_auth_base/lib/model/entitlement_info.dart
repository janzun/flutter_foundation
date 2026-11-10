import 'package:freezed_annotation/freezed_annotation.dart';

part 'entitlement_info.freezed.dart';
part 'entitlement_info.g.dart';

/// 统一资产/权益描述模型
@freezed
class EntitlementInfo with _$EntitlementInfo {
  @JsonSerializable(explicitToJson: true)
  const factory EntitlementInfo({
    /// 资产标识
    required String id,

    /// 权益类别: 'membership', 'points', 'quota'
    required String type,

    /// 业务代码: 'vip', 'standard_point', 'ai_quota'
    required String code,

    /// 状态: 'active', 'expired', 'frozen'
    @Default('active') String status,

    /// 会员等级 (type = 'membership' 时有效)
    String? tier,

    /// 计费周期 (type = 'membership' 时有效)
    String? billingCycle,

    /// 资产余额 (type = 'points' 或 'quota' 时有效)
    @Default(0.0) double balance,

    /// 到期截止时间 (null 代表永久)
    DateTime? expireAt,

    /// 授权可使用的端白名单
    @Default(<String>['android', 'ios', 'web', 'macos', 'windows'])
    List<String> allowedPlatforms,
  }) = _EntitlementInfo;

  factory EntitlementInfo.fromJson(Map<String, dynamic> json) =>
      _$EntitlementInfoFromJson(json);
}
