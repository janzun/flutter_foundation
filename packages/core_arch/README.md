# core_arch

跨项目复用的**纯 Dart / 官方无原生权限污染核心架构与跨端基础工具底座**。

严禁引入任何涉及相机、相册、定位、通知等需要 iOS/Android 敏感系统权限的原生插件，保证多端 100% 纯净与快速通过海外应用商店（App Store / Google Play）合规审查。

---

## 模块能力概览

1. **MVVM 核心规范**：
   - `BaseViewModel`、`BaseUiState`、`BaseUiEvent`
   - `ViewState`：标准视图五态（`idle`, `loading`, `empty`, `error`, `success`）
   - `Result<T>`：Dart 3 密封代数类型（`Ok(value)` / `Err(AppException)`），全面采用 `await` 异步模式与模式匹配
2. **工业级网络与传输层**：
   - `DioClient`：拦截器、动态 Token 注入、401 会话失效回调、`DioClient.guard` 通用异常保护罩
   - `BaseRepository`：业务仓储抽象基类，配合 Retrofit 使用，提供 `safeCall` / `safeCallApi` 自动抹平异常并返回 `Result<T>`
   - `ApiResponse<T>`：后端标准 `{code, message, data}` 业务通用封包定义
   - `R2Uploader`：Cloudflare R2 / S3 兼容对象存储预签名 URL 直传（零中转服务器出网带宽费，支持进度监听）
   - `FileDownloader`：大文件安全原子下载器（临时文件隔离、防断网损坏重命名、进度监听）
   - `NetworkConnectivity`：网络连通性感知（WiFi/蜂窝/以太网/断网响应式流）
3. **全端自适应响应式布局 (Responsive)**：
   - `ScreenType`：标准屏幕断点（`compact < 600`，`medium < 840`，`expanded >= 840`）
   - `ResponsiveContext`：`context.isDesktop` / `isMobile` / `context.responsiveValue(...)`
   - `AdaptiveScaffold`：自适应脚手架（手机底部 Tab 自动变身平板/桌面左侧 `NavigationRail`）
   - `ResponsiveLayout`：自适应内容容器（手机单列流 vs 桌面 Master-Detail 左右双栏）
   - `ContentMaxWidth`：宽屏最大舒适阅读宽度限制器（防大屏横向拉伸断裂）
4. **页面级转场动画 (Transitions)**：
   - `AppTransitions`：适配 `go_router` 的跨端转场工具（`slideHorizontal` 水平滑入、`slideUp` 底部上滑、`fade` 极速淡入、`adaptive` 跨端自适应）
5. **本地存储与路径 (Storage)**：
   - `SpUtil`：基于官方 `shared_preferences` 的内存同步极速读 + 后台异步落盘工具（含常用业务标记）
   - `PathUtil`：跨平台私有安全沙盒目录解析（`appDocumentsDirectory`、`appCacheDirectory` 等）
6. **解耦通信 (Events)**：
   - `EventBus`：纯 Dart 类型安全事件总线（发布/订阅解耦）
7. **基础工具与弹窗体系 (Utils)**：
   - `DialogUtil`：工业级多方位通用弹窗（支持 `center`, `bottom`, `top`, `right`, `left`，内置弹性动画与免 Context 弹窗，提供标准 `DialogUtil.confirm`）
   - `Logger`：生产级彩色环境隔离日志系统（Debug 详细输出，Release 自动静默防泄密）
   - `ToastUtil`：免 `BuildContext` 的悬浮轻提示与全屏阻塞式 Loading
8. **出海通用基础扩展 (Extensions)**：
   - `DateExtension`：国际化时间处理（`timeAgo`、`MMM d, yyyy`、ISO-8601，Intl 标准）
   - `NumExtension`：国际标准货币（`$1,299.99`）与文件大小换算（`2.5 MB`）
   - `StringExtension`：海外合规脱敏（`maskEmail`、`maskPhone`）、邮箱/URL/纯数字正则校验
9. **组件与UI级微动效 (Widgets & UI Animations)**：
   - `FadeSlideTransition`：声明式局部元素/列表项淡入滑入动效（支持瀑布流延时）
   - `BouncingTap`：质感微缩放弹性回弹点击组件
   - `StateLoadWidget`：配合 `ViewState` 的四态标准容器
   - `DebounceTap` / `DebounceButton`：防快速连点与轻量触觉反馈包装组件
   - `HideKeyboardTap`：点击空白处自动收起软键盘
   - `AppScrollBehavior`：桌面端与 Web 鼠标/触摸板平滑拖拽滚动行为支持

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

---

## 核心 API 与快速使用指南

### 1. 结果模型与模式匹配 (`Result<T>` & `ViewState`)

全面采用现代 Dart 3 `sealed class` 配合 `await` 异步语法：

```dart
final Result<String> result = await someAsyncOperation();

// 模式匹配解构 (switch 表达式)
final message = switch (result) {
  Ok(value: final text) => '成功: $text',
  Err(error: final err) => '失败: [${err.code}] ${err.message}',
};

// 驱动 ViewState
if (result.isOk) {
  viewState = result.valueOrNull!.isEmpty ? ViewState.empty : ViewState.success;
} else {
  viewState = ViewState.error;
}
```

---

### 2. 页面级转场动画 (`AppTransitions` 配合 `go_router`)

```dart
// 手机端滑入、桌面端/Web 自动降级为极速淡入淡出（防大屏眩晕）
GoRoute(
  path: '/settings',
  pageBuilder: (context, state) => AppTransitions.adaptive(
    context: context,
    key: state.pageKey,
    child: const SettingsScreen(),
  ),
);

// 全屏 Modal 向上滑入（适合登录、发布页）
GoRoute(
  path: '/login',
  pageBuilder: (context, state) => AppTransitions.slideUp(
    key: state.pageKey,
    child: const LoginScreen(),
  ),
);
```

---

### 3. 多方位通用弹窗与确认框 (`DialogUtil`)

免 `BuildContext`，内置物理弹性转场：

```dart
// 1. 底部弹出面板 (SlideUp)
DialogUtil.show(
  position: DialogPosition.bottom,
  builder: (ctx) => const SharePanel(),
);

// 2. 右侧抽屉面板 (适合平板/桌面端筛选侧边栏)
DialogUtil.show(
  position: DialogPosition.right,
  builder: (ctx) => const FilterDrawer(),
);

// 3. 通用确认弹窗
final confirmed = await DialogUtil.confirm(
  title: 'Delete Account',
  content: 'Are you sure you want to delete your account? This action cannot be undone.',
  confirmText: 'Delete',
  isDestructive: true,
);
```

---

### 4. 组件级微交互与动效 (`FadeSlideTransition` & `BouncingTap`)

```dart
// 1. 列表瀑布流交错入场动画
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return FadeSlideTransition(
      delay: Duration(milliseconds: index * 40), // 交错延时
      child: ItemCard(item: items[index]),
    );
  },
);

// 2. 质感卡片弹性缩放点击 (iOS 负一屏同款质感)
BouncingTap(
  onTap: () => print('Card Tapped'),
  child: const CardWidget(),
);
```

---

### 5. 全端响应式自适应布局 (Responsive)

```dart
AdaptiveScaffold(
  selectedIndex: currentIndex,
  onDestinationSelected: (index) => setState(() => currentIndex = index),
  destinations: const [
    AdaptiveDestination(icon: Icons.home, label: 'Home'),
    AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
  ],
  body: ResponsiveLayout(
    // 手机竖屏：单列列表
    compact: (context) => const UserMobileListView(),
    // 桌面/Web宽屏：左右双栏 (Master-Detail)
    expanded: (context) => Row(
      children: const [
        SizedBox(width: 320, child: UserNavList()),
        VerticalDivider(width: 1),
        Expanded(child: UserDetailContent()),
      ],
    ),
  ),
);
```

---

### 6. 网络层与大文件传输 (`DioClient`, `FileDownloader`, `R2Uploader`)

```dart
// 1. 安全原子下载文件 (防断网损坏)
final downloadResult = await FileDownloader.downloadFile(
  urlPath: 'https://example.com/files/manual.pdf',
  savePath: '${(await PathUtil.appDocumentsDirectory).path}/manual.pdf',
  onReceiveProgress: (received, total) {
    print('下载进度: ${(received / total * 100).toStringAsFixed(1)}%');
  },
);

// 2. Cloudflare R2 / S3 预签名直传 (零出网带宽费)
final uploadResult = await R2Uploader.uploadBytes(
  presignedPutUrl: 'https://r2.example.com/uploads/photo.jpg?signature=...',
  bytes: imageBytes,
  contentType: 'image/jpeg',
);
```

---

### 7. 本地存储、环境日志与出海扩展

```dart
// 1. SpUtil 极速存储：读取完全同步零等待
await SpUtil.init();
final String token = SpUtil.getString('token');

// 2. Logger：彩色日志 (Debug 详细打印，Release 自动静默)
Logger.d('正在加载用户数据: $id');
Logger.e('数据解析异常', error: e, stackTrace: stack);

// 3. 国际化友好时间与货币 (Intl 标准)
print(DateTime.now().subtract(const Duration(minutes: 5)).timeAgo()); // "5m ago"
print(1299.9.toCurrency(symbol: '\$')); // "$1,299.90"
print('alex.smith@gmail.com'.maskEmail()); // "al***h@gmail.com"
```
