import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/auth_error_code.dart';
import '../model/auth_result.dart';
import '../model/user_data.dart';

/// 负责通过 PostgreSQL RPC 与中台 `common` 表安全同步与聚合业务用户档案
class UserSyncService {
  final SupabaseClient client;
  final String appId;

  const UserSyncService({
    required this.client,
    required this.appId,
  });

  /// 调用 PostgreSQL 函数一次性原子同步并返回 [UserData]
  Future<AuthResult<UserData>> fetchUserProfile() async {
    try {
      final response = await client.rpc(
        'sync_user_profile',
        params: {
          'p_app_id': appId,
        },
      );

      if (response == null) {
        return AuthResult.failure(
          AuthErrorCode.internalError,
          '未能获取服务端响应数据',
        );
      }

      final respMap = Map<String, dynamic>.from(response as Map);
      return AuthResult.fromJson(
        respMap,
        (dataMap) => UserData.fromJson(dataMap),
      );
    } catch (e, stack) {
      debugPrint('UserSyncService.fetchUserProfile(appId: $appId) failed: $e\n$stack');
      return AuthResult.failure(
        AuthErrorCode.internalError,
        '同步用户档案异常: $e',
      );
    }
  }
}
