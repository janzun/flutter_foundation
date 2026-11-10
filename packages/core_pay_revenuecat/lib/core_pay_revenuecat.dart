import 'package:core_pay_base/core_pay_base.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'service/revenuecat_pay_service.dart';

export 'package:core_pay_base/core_pay_base.dart';
export 'service/revenuecat_pay_service.dart';

/// 渠道工厂实现：创建基于 RevenueCat 的支付服务实例
BasePayService createPayService({
  required String appId,
  required SupabaseClient supabaseClient,
}) =>
    RevenueCatPayService(
      appId: appId,
      supabaseClient: supabaseClient,
    );
