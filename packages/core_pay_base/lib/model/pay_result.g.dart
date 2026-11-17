// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pay_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PayResultImpl _$$PayResultImplFromJson(Map<String, dynamic> json) =>
    _$PayResultImpl(
      status: $enumDecode(_$PayStatusEnumMap, json['status']),
      channelTransactionId: json['channelTransactionId'] as String?,
      productCode: json['productCode'] as String?,
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$$PayResultImplToJson(_$PayResultImpl instance) =>
    <String, dynamic>{
      'status': _$PayStatusEnumMap[instance.status]!,
      'channelTransactionId': instance.channelTransactionId,
      'productCode': instance.productCode,
      'errorMessage': instance.errorMessage,
    };

const _$PayStatusEnumMap = {
  PayStatus.success: 'success',
  PayStatus.cancelled: 'cancelled',
  PayStatus.pending: 'pending',
  PayStatus.failed: 'failed',
};
