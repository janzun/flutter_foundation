import 'package:freezed_annotation/freezed_annotation.dart';

part 'pay_result.freezed.dart';
part 'pay_result.g.dart';

/// 支付与恢复动作状态
enum PayStatus {
  @JsonValue('success')
  success,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('pending')
  pending,
  @JsonValue('failed')
  failed,
}

/// 支付行为结果封装 (仅保留 App 端必要字段)
@freezed
class PayResult with _$PayResult {
  @JsonSerializable(explicitToJson: true)
  const factory PayResult({
    /// 状态枚举
    required PayStatus status,

    /// 支付渠道交易号 (如有，可用于埋点关联)
    String? channelTransactionId,

    /// 购买的商品唯一编码
    String? productCode,

    /// 错误信息 (失败时有效)
    String? errorMessage,
  }) = _PayResult;

  factory PayResult.success({
    String? channelTransactionId,
    String? productCode,
  }) =>
      PayResult(
        status: PayStatus.success,
        channelTransactionId: channelTransactionId,
        productCode: productCode,
      );

  factory PayResult.cancelled({String? productCode}) => PayResult(
        status: PayStatus.cancelled,
        productCode: productCode,
        errorMessage: 'User cancelled payment',
      );

  factory PayResult.failed(String errorMessage, {String? productCode}) =>
      PayResult(
        status: PayStatus.failed,
        productCode: productCode,
        errorMessage: errorMessage,
      );

  factory PayResult.fromJson(Map<String, dynamic> json) =>
      _$PayResultFromJson(json);
}
