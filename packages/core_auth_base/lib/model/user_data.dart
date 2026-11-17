import 'package:freezed_annotation/freezed_annotation.dart';
import 'entitlement_info.dart';

part 'user_data.freezed.dart';
part 'user_data.g.dart';

/// 统一业务用户档案模型 (仅保留 App 端必要字段，不可变模型)
@freezed
class UserData with _$UserData {
  const UserData._();

  @JsonSerializable(explicitToJson: true)
  const factory UserData({
    /// common.users.id (业务系统统一 UUID)
    required String id,

    /// 是否为匿名访客
    @JsonKey(name: 'is_anonymous') @Default(false) bool isAnonymous,

    /// 标识当前登录是否为刚刚注册的新用户
    @JsonKey(name: 'is_new_user') @Default(false) bool isNewUser,

    /// 用户展示昵称
    @JsonKey(name: 'display_name') required String displayName,

    /// 绑定邮箱
    String? email,

    /// 用户头像 URL
    @JsonKey(name: 'avatar_url') String? avatarUrl,

    /// 用户全量资产与权益列表 (统一承载会员、积分、额度)
    @Default(<EntitlementInfo>[]) List<EntitlementInfo> entitlements,
  }) = _UserData;

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);

  /// 便捷属性：当前是否为有效 VIP (检索有效且未过期的 membership 权益)
  bool get isVip => entitlements.any(
        (e) =>
            e.type == 'membership' &&
            e.status == 'active' &&
            e.tier != 'free' &&
            (e.expireAt == null || e.expireAt!.isAfter(DateTime.now())),
      );

  /// 便捷属性：当前有效 VIP 会员等级 (如 'pro', 'svip')
  String? get vipTier {
    final validVips = entitlements.where(
      (e) =>
          e.type == 'membership' &&
          e.status == 'active' &&
          e.tier != 'free' &&
          (e.expireAt == null || e.expireAt!.isAfter(DateTime.now())),
    );
    return validVips.isEmpty ? null : validVips.first.tier;
  }

  /// 便捷属性：VIP 到期截止时间
  DateTime? get vipExpireAt {
    final validVips = entitlements.where(
      (e) =>
          e.type == 'membership' &&
          e.status == 'active' &&
          e.tier != 'free' &&
          (e.expireAt == null || e.expireAt!.isAfter(DateTime.now())),
    );
    return validVips.isEmpty ? null : validVips.first.expireAt;
  }

  /// 便捷属性：当前标准积分余额
  int get pointsBalance {
    final pointEnt = entitlements.where(
      (e) => e.type == 'points' && e.code == 'standard_point',
    );
    return pointEnt.isEmpty ? 0 : pointEnt.first.balance.toInt();
  }

  /// 便捷方法：获取指定资产/额度的余额
  double getBalance(String code, {String type = 'quota'}) {
    final matched = entitlements.where(
      (e) => e.type == type && e.code == code && e.status == 'active',
    );
    return matched.isEmpty ? 0.0 : matched.first.balance;
  }
}
