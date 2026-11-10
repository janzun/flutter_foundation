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

/// 支付行为结果封装
@freezed
class PayResult with _$PayResult {
  @JsonSerializable(explicitToJson: true)
  const factory PayResult({
    /// 状态枚举
    required PayStatus status,

    /// 支付渠道交易号 (如有)
    String? channelTransactionId,

    /// 购买的商品唯一编码
    String? productCode,

    /// 错误信息 (失败时有效)
    String? errorMessage,

    /// 原始返回数据上下文
    @Default(<String, dynamic>{}) Map<String, dynamic> rawDetails,
  }) = _PayResult;

  factory PayResult.success({
    String? channelTransactionId,
    String? productCode,
    Map<String, dynamic> rawDetails = const <String, dynamic>{},
  }) =>
      PayResult(
        status: PayStatus.success,
        channelTransactionId: channelTransactionId,
        productCode: productCode,
        rawDetails: rawDetails,
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
