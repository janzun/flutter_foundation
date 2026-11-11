# core_arch

跨项目复用的**纯 Dart / 官方无原生权限污染核心架构与跨端基础工具底座**。

严禁引入任何涉及相机、相册、定位、通知等需要 iOS/Android 敏感系统权限的原生插件，保证多端 100% 纯净与快速通过海外应用商店（App Store / Google Play）合规审查。

---

## 🎯 核心 API 极简速查表（AI & 人类索引零幻觉）

| 模块分类 | 核心类 / 扩展 | 一句话核心功能与调用方式 |
| :--- | :--- | :--- |
| **MVVM 状态** | `Result<T>` | Dart 3 密封类：`Ok(value)` / `Err(AppException)`，模式匹配或 `result.when(...)` |
| **MVVM 视图** | `ViewState` | 视图五态：`idle`, `loading`, `empty`, `error`, `success`，布尔 getter：`isLoading` 等 |
| **异常治理** | `AppException` | 统一异常结构：`code`, `message`, `statusCode`, `originalError` |
| **网络请求** | `DioClient` | 工业级 Dio 封装，`DioClient.guard<T>(() => ...)` 统一抹平异常并转为 `Result<T>` |
| **业务仓储** | `BaseRepository` | 仓储抽象基类：`safeCall(() => _api.getUser())`（配合 Retrofit 零 try-catch） |
| **业务封包** | `ApiResponse<T>` | 后端常见 `{code, message, data}` 通用泛型实体 |
| **文件直传** | `R2Uploader` | `uploadBytes(...)`：通过预签名 PUT URL 直传 Cloudflare R2 / S3（0 业务服务器出网带宽） |
| **原子下载** | `FileDownloader` | `downloadFile(...)`：大文件临时隔离安全下载，完成原子重命名防损坏，支持进度与取消 |
| **网络感知** | `NetworkConnectivity`| `isConnected` 异步判定，`onConnectivityChanged` 响应式监听 WiFi/蜂窝/断网 |
| **断点识别** | `ScreenType` | 屏幕尺寸形态：`compact (<600)`，`medium (<840)`，`expanded (>=840)` |
| **响应式上下文**| `context.*` | `context.isDesktop` / `context.isMobile` / `context.responsiveValue(...)` |
| **自适应脚手架**| `AdaptiveScaffold` | 手机端底部 `NavigationBar`，平板/桌面端自动切换为左侧 `NavigationRail` |
| **双栏联动** | `ResponsiveLayout` | 自适应内容容器：手机单列流 vs 桌面 Master-Detail 左右双栏 |
| **宽屏限宽** | `ContentMaxWidth` | `ContentMaxWidth(maxWidth: 900, child: ...)` 防止超宽大屏横向拉皮变丑 |
| **路由转场** | `AppTransitions` | 配合 GoRouter：`slideHorizontal`, `slideUp`, `fade`, `adaptive`（桌面极速淡入） |
| **多方位弹窗** | `DialogUtil` | `show(position: ...)`（center/bottom/top/right/left，免 Context），`confirm(...)` |
| **轻提示/遮罩** | `ToastUtil` | 免 Context：`ToastUtil.success('...')`, `showLoading(...)`, `hideLoading()` |
| **本地缓存** | `SpUtil` | 启动 `await SpUtil.init()`，之后 `getString/getBool` **完全同步 O(1) 读**，异步写落盘 |
| **沙盒路径** | `PathUtil` | `appDocumentsDirectory`, `appCacheDirectory`, `temporaryDirectory` 0 敏感权限 |
| **事件总线** | `EventBus` | `EventBus.emit(event)` 发布，`EventBus.on<T>()` 订阅解耦通信 |
| **环境日志** | `Logger` | `Logger.d / i / w / e`：Debug 彩色带时间戳堆栈输出，Release **自动彻底静默** |
| **国际化日期** | `DateTime.*` | `date.timeAgo()` ("5m ago")，`toFormattedDate()` ("Nov 11, 2026")，Intl 标准 |
| **货币与体积** | `num.*` | `(1299.9).toCurrency(symbol: '\$')` -> `\$1,299.90`，`bytes.toByteSizeString()` |
| **合规脱敏** | `String.*` | `email.maskEmail()`，`phone.maskPhone()`，`isEmail`, `isUrl`, `isNumeric` |
| **微动效交互** | `BouncingTap` | 类似 iOS 负一屏的 0.96 微按压缩放与弹性回弹触觉手感 |
| **入场动画** | `FadeSlideTransition`| 局域元素/列表项淡入滑入动效，支持 `delay` 瀑布流交错 |
| **交互组件** | `HideKeyboardTap` | 点击页面空白处自动收起软键盘 |
| **桌面滚动** | `AppScrollBehavior`| 开启 Web / 桌面端鼠标触摸板平滑拖拽滚动 |

---

## 🚀 App 根入口黄金装配模版 (`main.dart`)

在业务 App 中，只需在入口配置以下 4 处，即可一次性挂载所有基础设施：

```dart
import 'package:flutter/material.dart';
import 'package:core_arch/core_arch.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. 预初始化内存键值缓存单例（确保之后同步极速读写）
  await SpUtil.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Global App',

      // 2. 挂载免 Context 全局 SnackBar 与 Dialog Key
      scaffoldMessengerKey: ToastUtil.messengerKey,
      navigatorKey: ToastUtil.navigatorKey,

      // 3. 挂载桌面端与 Web 端平滑拖拽滚动行为
      scrollBehavior: const AppScrollBehavior(),

      // 4. 外层包裹空白点击自动收起软键盘
      builder: (context, child) => HideKeyboardTap(child: child!),

      theme: ThemeData(useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}
```

---

## 💡 真实可运行实机样例（避免 AI 幻觉的黄金参考）

在本项目宿主工程中，已包含完整、可运行、可交互的测试样板页面：
- **实机样例文件位置**：[`lib/example/core_arch.dart`](file:///Users/alex/WorkSpace/Project/flutter_foundation/lib/example/core_arch.dart)
- **应用启动入口**：[`lib/main.dart`](file:///Users/alex/WorkSpace/Project/flutter_foundation/lib/main.dart)

AI 编写业务代码时，可直接参考该样例中的调用模式：
1. **MVVM 四态 + DioClient.guard** 模拟网络请求与异常捕获；
2. **多方位弹窗 (DialogUtil)** 底部弹窗、侧边抽屉与确认对话框；
3. **响应式断点与取值 (ResponsiveContext)** 跨端自适应布局；
4. **本地存储 (SpUtil)** 内存同步极速读取；
5. **微动效与防连点 (BouncingTap & DebounceTap)**。

---

## 依赖引入

在各业务 App 的 `pubspec.yaml` 中引入：

```yaml
dependencies:
  core_arch:
    path: ../core_arch # 或 packages/core_arch
```

统一入口引用：

```dart
import 'package:core_arch/core_arch.dart';
```
