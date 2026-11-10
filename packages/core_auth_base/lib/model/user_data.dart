import 'package:freezed_annotation/freezed_annotation.dart';
import 'entitlement_info.dart';

part 'user_data.freezed.dart';
part 'user_data.g.dart';

/// 统一业务用户全量档案模型 (不可变模型)
@freezed
class UserData with _$UserData {
  const UserData._();

  @JsonSerializable(explicitToJson: true)
  const factory UserData({
    /// common.users.id (业务系统统一 UUID)
    required String id,

    /// common.apps.id (当前应用唯一标识)
    @JsonKey(name: 'app_id') required String appId,

    /// auth.users.id (Supabase 底层认证 UID)
    @JsonKey(name: 'supabase_uid') required String supabaseUid,

    /// 是否为匿名访客
    @JsonKey(name: 'is_anonymous') @Default(false) bool isAnonymous,

    /// 认证提供商 ('anonymous' | 'apple' | 'google' | 'email')
    @JsonKey(name: 'auth_provider') @Default('email') String authProvider,

    /// 标识当前登录是否为刚刚注册的新用户
    @JsonKey(name: 'is_new_user') @Default(false) bool isNewUser,

    /// 绑定邮箱
    String? email,

    /// 绑定手机号
    String? phone,

    /// 用户展示昵称
    @JsonKey(name: 'display_name') required String displayName,

    /// 用户头像 URL
    @JsonKey(name: 'avatar_url') String? avatarUrl,

    /// 用户风控级别 ('normal' | 'high' | 'banned')
    @JsonKey(name: 'risk_level') @Default('normal') String riskLevel,

    /// 用户全量资产与权益列表 (统一承载会员、积分、额度)
    @Default(<EntitlementInfo>[]) List<EntitlementInfo> entitlements,

    /// 最近登录活跃时间
    @JsonKey(name: 'last_login_at') DateTime? lastLoginAt,

    /// 账号注册时间
    @JsonKey(name: 'created_at') required DateTime createdAt,
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
