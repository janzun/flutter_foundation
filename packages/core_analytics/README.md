# Janzun Core Analytics (Flutter)

Janzun 统一数据分析与埋点 Flutter 核心客户端库（对齐 Janzun 统一网关 `POST /v1/events` 协议）。

适用于 Janzun 生态下的所有 Flutter 移动端（iOS / Android / macOS / Web / Windows）应用。

---

## 核心设计理念

1. **统一网关对齐**：零外部云厂商 SDK 依赖（无 Supabase SDK），纯标准 HTTP 数组批量上报（单批次上限 30 条，Payload < 16KB）。
2. **全自动底层托管**：
   - **4 大应用生命周期**（`app_install`, `app_launch`, `app_show`, `app_hide`）全自动触发；
   - **页面浏览与停留时长**（`page_view`，携带 `duration_sec`）依托 `AnalyticsRouteObserver` 离开页面时全自动结算并发射；
   - **全局未捕获崩溃托管**：自动拦截 `FlutterError` 与 `PlatformDispatcher.instance.onError`，截取无害堆栈直发上报。
3. **极简单一初始化**：在用户明示同意隐私政策后，一行 `Analytics.initialize(...)` 搞定配置、公共属性预置与全局异常监控。
4. **用户交互严格手动控制**：绝无杂乱无意义的垃圾点击数据，所有用户交互（Action）、卡片曝光（Impression）、商业转化（Conversion）均显式调用。
5. **绝对隐私安全与合规**：
   - 零 PII 收集（绝不采集姓名、手机号、通信录、相册等敏感信息）；
   - 不采集硬件唯一指纹（无 IMEI、MAC、IDFA，无 ATT 弹窗）；
   - 设备 ID 使用本地持久化匿名 UUID；
   - 仅在用户同意隐私政策后调用，满足 Apple App Store、Google Play 及国内应用商店极严苛审查。

---

## 依赖配置

在模块或 App 的 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  core_analytics:
    path: package/core_analytics # 或引用自公共 package 目录
```

---

## 接入步骤

### 第一步：初始化与全局异常托管（在隐私政策同意后）

对于国内合规场景，建议在用户点击《隐私政策》弹窗的“同意”之后调用；海外无弹窗场景可在 `main()` 的 `runApp()` 前调用。

```dart
import 'package:core_analytics/analytics.dart';

void onPrivacyPolicyAgreed() async {
  // 单方法搞定：初始化 + 预设公共属性 + 生命周期托管 + 崩溃拦截
  await Analytics.initialize(
    appId: '00000000-0000-0000-0000-000000000001', // common.apps 表的唯一 UUID
    endpoint: 'https://api.janzun.com/v1/events',     // 统一网关地址 (可选，默认已为此地址)
    channel: 'google_play',                          // 应用分发渠道标识
    superProperties: {
      'app_flavor': 'production',
      'user_id': currentUserId,                      // 若启动时已登录可直接传入
    },
    autoCaptureErrors: true,                         // 默认 true，自动捕获 FlutterError 与引擎未捕获异常
  );

  Navigator.of(context).pushReplacementNamed('/home');
}
```

### 第二步：挂载页面流转与停留时长监听器

在根组件 `MaterialApp` 或 `CupertinoApp` 中注入 `AnalyticsRouteObserver`：

```dart
import 'package:flutter/material.dart';
import 'package:core_analytics/analytics.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      // 注册路由观察器：离开页面时自动结算并上报 page_view 与 duration_ms
      navigatorObservers: [
        AnalyticsRouteObserver(),
      ],
      routes: {
        '/home': (context) => const HomeScreen(),
        '/paywall': (context) => const PaywallScreen(),
      },
    );
  }
}
```

---

## 完整 API 规范与使用示例

### 1. 用户状态与公共属性管理

```dart
// 1. 用户登录成功：绑定 user_id 与其他用户属性
Analytics.setSuperProperties({
  'user_id': 'usr_98a72b1c',
  'is_vip': true,
  'vip_type': 'annual',
});

// 2. 用户退出登录：仅清除 user_id（保留 channel 等基础环境属性）
Analytics.clearUserId();

// 3. 重置清空所有公共属性
Analytics.clearSuperProperties();
```

### 2. 手动业务打点

#### A. 用户交互点击 (Action)
```dart
// 建议优先使用 EventNames 常量
Analytics.trackAction(
  EventNames.clickPay,
  properties: {
    'plan': 'pro_yearly',
    'price': 29.99,
  },
);
```

#### B. 模块与卡片曝光 (Impression)
```dart
Analytics.trackImpression(
  EventNames.paywallShow,
  properties: {
    'trigger_source': 'export_high_res_button',
  },
);
```

#### C. 核心商业转化 (Conversion - 默认立即直发)
```dart
Analytics.trackConversion(
  EventNames.paymentSuccess,
  properties: {
    'order_id': 'ord_20261105001',
    'amount': 29.99,
    'currency': 'USD',
  },
);
```

#### D. 手动业务异常捕获 (Error - 默认立即直发)
```dart
try {
  await apiService.checkout();
} catch (e, stack) {
  Analytics.trackError(
    EventNames.paymentError,
    message: e.toString(),
    stackTrace: stack.toString().split('\n').take(10).join('\n'),
    properties: {
      'order_id': 'ord_20261105001',
    },
  );
}
```

#### E. 长尾特殊自定义打点 (Custom)
```dart
Analytics.trackCustom(
  'custom_feature_used',
  type: EventType.action,
  properties: {
    'custom_param': 'value',
  },
);
```

#### F. 强制清空并上报队列
```dart
await Analytics.flush();
```

---

## 自动打点事件参考

| 事件标识 (`event_name`) | 事件类型 (`event_type`) | 触发时机与附带属性 |
| :--- | :--- | :--- |
| `app_install` | `lifecycle` | App 首次启动时（本地持久化记录），属性：`{'is_first_time': true}`。 |
| `app_launch` | `lifecycle` | App 冷启动进入时，属性：`{'launch_type': 'cold'}`。 |
| `app_show` | `lifecycle` | App 从后台切回前台（`AppLifecycleState.resumed`）。 |
| `app_hide` | `lifecycle` | App 退至后台（`AppLifecycleState.paused / hidden`），**自动触发队列 flush**。 |
| `page_view` | `page_view` | 离开当前路由页面时自动触发。属性自动携带：`duration_sec`（秒）。 |
| `crash` | `error` | 未捕获的 UI / 异步异常。属性：`error_message`, `stack_trace`（前 10 行）。 |

---

## 单元测试支持

在测试用例中验证打点无需真实发起网络请求：

```bash
flutter test
```
