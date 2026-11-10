import 'package:core_auth_base/auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'apple_auth_service.dart';

// 全量透传 core_auth_base 的所有模型、枚举与统一 Auth 门面
export 'package:core_auth_base/auth.dart' hide createAuthService;
export 'apple_auth_service.dart';

/// 覆盖顶层工厂函数：构造 Apple 渠道专有实例
BaseAuthService createAuthService({
  required SupabaseClient client,
  required String appId,
}) =>
    AppleAuthService(
      client: client,
      appId: appId,
    );
