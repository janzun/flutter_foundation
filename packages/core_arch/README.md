# core_arch

跨项目复用的**纯 Dart / 官方无原生权限污染核心架构与基础工具底座**。严禁引入任何涉及相机、相册、定位、通知等需要 iOS/Android 敏感系统权限的原生插件，保证多端 100% 纯净与快速通过应用商店合规审查。

---

## 模块能力概览

- **MVVM 核心规范**：
  - `BaseViewModel`、`BaseUiState`、`BaseUiEvent`
  - `ViewState`：标准视图五态（`idle`, `loading`, `empty`, `error`, `success`）
  - `Result<T>`：Dart 3 密封类（`Ok(value)` / `Err(AppException)`），全面采用 `await` 异步模式与模式匹配
- **工业级网络层**：
  - `DioClient`：拦截器、动态 Token 注入、401 会话失效回调、`DioClient.guard` 通用异常保护罩
  - `BaseRepository`：业务仓储抽象基类，配合 Retrofit 使用，提供 `safeCall` / `safeCallApi` 自动抹平异常并返回 `Result<T>`
  - `ApiResponse<T>`：后端标准 `{code, message, data}` 业务通用封包定义
  - `R2Uploader`：Cloudflare R2 / S3 兼容对象存储预签名 URL 二进制直传（零中转服务器出网带宽成本，支持进度监听）
- **本地存储 (Storage)**：
  - `SpUtil`：基于官方 `shared_preferences` 的内存同步极速读 + 后台异步落盘工具（含常用业务标记）
- **交互与提示 (Utils)**：
  - `ToastUtil`：免 `BuildContext` 的悬浮轻提示与全屏阻塞式 Loading，内置轻量触觉反馈与防重叠堆积
- **通用组件 (Widgets)**：
  - `StateLoadWidget`：配合 `ViewState` 的标准四态容器（加载中 / 空数据 / 错误重试 / 正常内容）
  - `DebounceTap` / `DebounceButton`：防快速连点与轻量触觉反馈包装组件

---

## 依赖配置

在各业务 App 或子包的 `pubspec.yaml` 中引入：

```yaml
dependencies:
  core_arch:
    path: ../core_arch # 或 packages/core_arch
```

统一入口引用：

```dart
import 'package:core_arch/core_arch.dart';
```

---

## 核心 API 与快速使用指南

### 1. 结果模型与模式匹配 (`Result<T>` & `ViewState`)

采用现代 Dart 3 `sealed class` 配合 `await` 模式：

```dart
// 1. 获取异步结果
final Result<String> result = await someAsyncOperation();

// 2. 方式 A：模式匹配解构 (switch 表达式)
final message = switch (result) {
  Ok(value: final text) => '成功: $text',
  Err(error: final err) => '失败: [${err.code}] ${err.message}',
};

// 3. 方式 B：使用 when 辅助方法
result.when(
  ok: (val) => print('Data: $val'),
  err: (e) => print('Error: ${e.message}'),
);

// 4. 驱动 ViewState
if (result.isOk) {
  viewState = result.valueOrNull!.isEmpty ? ViewState.empty : ViewState.success;
} else {
  viewState = ViewState.error;
}
```

---

### 2. 网络层与 Retrofit 仓储调用 (`DioClient` & `BaseRepository`)

网络层完全尊重 Retrofit 的原生编译期代码生成机制，不做侵入式数据篡改。

#### 步骤 1：初始化网络客户端
```dart
final dioClient = DioClient(
  baseUrl: 'https://api.example.com',
  tokenProvider: () async {
    return await SpUtil.getString('user_token');
  },
  onUnauthorized: () {
    // 监听到 401，通知退出登录或弹出登录弹窗
    ToastUtil.error('登录已过期，请重新登录');
  },
);
```

#### 步骤 2：定义 Retrofit 接口
```dart
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'user_api_service.g.dart';

@RestApi()
abstract class UserApiService {
  factory UserApiService(Dio dio, {String baseUrl}) = _UserApiService;

  // 场景 A：标准 RESTful 接口（HTTP 状态码驱动）
  @GET('/api/v1/users/{id}')
  Future<UserModel> getUser(@Path('id') String id);

  // 场景 B：业务包裹结构接口（{code, message, data}）
  @GET('/api/v1/orders/{id}')
  Future<ApiResponse<OrderModel>> getOrder(@Path('id') String id);
}
```

#### 步骤 3：编写 Repository（零 try-catch 样板代码）
```dart
class UserRepository extends BaseRepository {
  final UserApiService _api;
  UserRepository(this._api);

  // 标准 RESTful 调用：Retrofit 自动解析 UserModel，safeCall 自动抹平异常并输出 Result<UserModel>
  Future<Result<UserModel>> fetchUser(String id) async {
    return await safeCall(() async => await _api.getUser(id));
  }

  // 业务包裹接口调用：safeCallApi 自动校验 code == 200，并提取 data
  Future<Result<OrderModel>> fetchOrder(String id) async {
    return await safeCallApi(() async => await _api.getOrder(id));
  }
}
```

---

### 3. Cloudflare R2 / S3 预签名 URL 直传 (`R2Uploader`)

无需经过业务服务器中转，前端直传对象存储，零流出带宽账单：

```dart
final result = await R2Uploader.uploadBytes(
  presignedPutUrl: 'https://r2.example.com/uploads/photo.jpg?signature=...',
  bytes: imageBytes,
  contentType: 'image/jpeg',
  onSendProgress: (sent, total) {
    final progress = sent / total;
    print('上传进度: ${(progress * 100).toStringAsFixed(1)}%');
  },
);

if (result.isOk) {
  ToastUtil.success('图片上传成功');
} else {
  ToastUtil.error('上传失败: ${result.errorOrNull?.message}');
}
```

---

### 4. 本地键值极速存储 (`SpUtil`)

在应用初始化时一次性挂载，之后读取完全同步、写入异步落盘：

```dart
// 1. 初始化（建议在 main.dart 或 SplashViewModel 中）
await SpUtil.init();

// 2. 同步极速读（零 await，零 UI 卡顿）
final bool agreed = SpUtil.isPrivacyAgreed;
final String token = SpUtil.getString('auth_token', defaultValue: '');
final int themeIndex = SpUtil.getInt('theme_mode', defaultValue: 0);

// 3. 异步持久化写入
await SpUtil.setPrivacyAgreed(true);
await SpUtil.setString('auth_token', 'token_xyz');
```

---

### 5. 全局免 Context 提示与全屏遮罩 (`ToastUtil`)

#### 步骤 1：在 App 根组件挂载 Key
```dart
MaterialApp.router(
  scaffoldMessengerKey: ToastUtil.messengerKey, // 用于悬浮轻提示
  navigatorKey: ToastUtil.navigatorKey,         // 用于全屏阻塞遮罩
  // ...
);
```

#### 步骤 2：在任何 ViewModel / 工具类中随时唤起
```dart
// 浮动 SnackBar 轻提示（防重叠堆积，附带轻微震动反馈）
ToastUtil.success('操作已成功');
ToastUtil.error('网络连接中断');

// 全屏阻塞式 Loading（防用户重复点击操作）
ToastUtil.showLoading(message: '正在处理中...');
await Future.delayed(const Duration(seconds: 1));
ToastUtil.hideLoading();
```

---

### 6. 标准状态容器与防抖组件 (`StateLoadWidget` & `DebounceTap`)

#### 四态标准容器：
```dart
Widget buildBody(MyViewModel vm) {
  return StateLoadWidget(
    viewState: vm.state.viewState,
    onRetry: () async {
      await vm.loadData();
    },
    contentBuilder: (context) {
      return ListView.builder(
        itemCount: vm.state.items.length,
        itemBuilder: (context, index) => Text(vm.state.items[index]),
      );
    },
  );
}
```

#### 防快速重复连击：
```dart
DebounceTap(
  duration: const Duration(milliseconds: 600),
  onTap: () async {
    await submitOrder();
  },
  child: Container(
    padding: const EdgeInsets.all(12),
    child: const Text('立即结算'),
  ),
);
```
