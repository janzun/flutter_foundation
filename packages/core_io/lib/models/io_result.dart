/// IO 调用的结果状态枚举。
enum IOStatus {
  /// 调用成功，有对应的数据产出。
  success,

  /// 用户主动取消操作（例如在相册、相机或另存为弹窗中点击“取消”）。
  ///
  /// 业务层应静默处理，避免弹出失败 Toast。
  cancelled,

  /// 系统或运行时发生真实异常（如权限拒绝、磁盘写满、文件不存在等）。
  failure,
}

/// IO 异常的细分分类，用于业务层精准响应（如引导去系统设置开权限）。
enum IOErrorType {
  /// 无错误。
  none,

  /// 权限被拒绝（例如用户拒绝了相机或 iOS 仅添加相册权限）。
  permissionDenied,

  /// 找不到指定的文件或路径。
  fileNotFound,

  /// 当前平台不支持该操作。
  unsupported,

  /// 其他未知错误。
  unknown,
}

/// 统一的 IO 交互操作结果封装对象。
///
/// 遵循无异常逃逸（No Unhandled Exception）原则，抹平多端三方插件的异常分歧。
class IOResult<T> {
  /// 操作状态。
  final IOStatus status;

  /// 成功时的返回数据载荷。
  final T? data;

  /// 错误简短描述信息。
  final String? errorMessage;

  /// 错误分类枚举。
  final IOErrorType errorType;

  /// 底层原始捕获的异常对象。
  final Object? rawError;

  const IOResult._({
    required this.status,
    this.data,
    this.errorMessage,
    this.errorType = IOErrorType.none,
    this.rawError,
  });

  /// 创建成功结果。
  const IOResult.success(T data)
      : this._(
          status: IOStatus.success,
          data: data,
        );

  /// 创建用户取消结果。
  const IOResult.cancelled()
      : this._(
          status: IOStatus.cancelled,
        );

  /// 创建失败结果。
  const IOResult.failure({
    required String errorMessage,
    IOErrorType errorType = IOErrorType.unknown,
    Object? rawError,
  }) : this._(
          status: IOStatus.failure,
          errorMessage: errorMessage,
          errorType: errorType,
          rawError: rawError,
        );

  /// 是否成功。
  bool get isSuccess => status == IOStatus.success;

  /// 是否为用户主动取消。
  bool get isCancelled => status == IOStatus.cancelled;

  /// 是否发生异常失败。
  bool get isFailure => status == IOStatus.failure;

  /// 是否是因为权限拒绝导致的失败。
  bool get isPermissionDenied => errorType == IOErrorType.permissionDenied;

  @override
  String toString() {
    switch (status) {
      case IOStatus.success:
        return 'IOResult.success(data: $data)';
      case IOStatus.cancelled:
        return 'IOResult.cancelled()';
      case IOStatus.failure:
        return 'IOResult.failure(type: $errorType, message: $errorMessage)';
    }
  }
}
