# Packages Directory

本目录用于存放所有独立沉淀、跨项目复用的功能底座模块。每个模块以独立 Package 的形态维护，便于后续通过 Git Submodule、Git 依赖或发布到私有 pub 仓库被其他 App 项目直接引用。

---

## 现有功能底座模块一览

| Package 模块 | 说明 | 核心依赖 / 规范 |
| :--- | :--- | :--- |
| [`core_arch`](file:///Users/alex/WorkSpace/Project/flutter_foundation/packages/core_arch/README.md) | **核心架构与跨端基础底座**：MVVM（`Result<T>`、`ViewState`）、网络层（`DioClient`、`BaseRepository`、`FileDownloader`、`NetworkConnectivity`、`R2Uploader`）、跨端响应式布局（`ScreenType`、`AdaptiveScaffold`、`ResponsiveLayout`）、本地存储与沙盒（`SpUtil`、`PathUtil`）、事件总线 `EventBus`、`Logger`、出海通用扩展与交互组件。严守 **0 敏感系统权限污染**。 | Dio, Retrofit, SharedPreferences, Intl, Connectivity, PathProvider |
| [`core_auth_base`](file:///Users/alex/WorkSpace/Project/flutter_foundation/packages/core_auth_base/README.md) | **认证抽象协议与通用模型**：定义通用 `BaseAuthService`、用户数据模型 `UserData`、登录状态流与 Supabase 会话同步协议。 | Supabase Flutter |
| [`core_auth_apple`](file:///Users/alex/WorkSpace/Project/flutter_foundation/packages/core_auth_apple/README.md) | **Apple 原生渠道认证**：iOS / macOS 平台原生 Sign in with Apple 授权实现。 | Sign in with Apple, Crypto |
| [`core_auth_google`](file:///Users/alex/WorkSpace/Project/flutter_foundation/packages/core_auth_google/README.md) | **Google 原生渠道认证**：Android / 多端原生 Google Sign-In 授权实现。 | Google Sign In |
| [`core_pay_base`](file:///Users/alex/WorkSpace/Project/flutter_foundation/packages/core_pay_base/README.md) | **支付与订阅抽象核心**：统一定义商品模型 `ProductInfo`、支付结果 `PayResult`、商品类型、账期与支付服务基类 `BasePayService`。 | 跨端支付抽象 |
| [`core_pay_revenuecat`](file:///Users/alex/WorkSpace/Project/flutter_foundation/packages/core_pay_revenuecat/README.md) | **RevenueCat 跨端商业化支付实现**：支持 App Store 与 Google Play 订阅与内购，自动对齐 Supabase 商业策略与应用商店本地化货币展示。 | Purchases Flutter, Supabase |
| [`core_camera`](file:///Users/alex/WorkSpace/Project/flutter_foundation/packages/core_camera/README.md) | **高性能视觉与原生相机底座**：支持 ZSL 零快门延迟极速秒拍、原生 4:3 比例对齐、硬件级 AF/AE 原子测光对焦、原生 ML Kit / Vision 人脸与视觉分析流。 | 原生 Camera2 / AVFoundation / ML Kit |
| [`core_llm`](file:///Users/alex/WorkSpace/Project/flutter_foundation/packages/core_llm/README.md) | **通用大模型客户端与 AI 提示词工具集**：开箱支持 Google Gemini、OpenAI 协议兼容模型（DeepSeek、ChatGPT、Groq 等），支持单次生成、SSE 打字机流式输出及长文本会议总结。 | Dio |
| [`core_analytics`](file:///Users/alex/WorkSpace/Project/flutter_foundation/packages/core_analytics/README.md) | **全端事件埋点与日志追踪底座**：规范化事件模型、设备上下文采集、路由自动追踪、本地队列缓冲与批量上报。 | Supabase / PostHog 埋点规范 |

---

## 引用建议

在宿主 App 或新工程中，可通过相对路径按需引用：

```yaml
dependencies:
  # 必须引入：纯净通用基础底座
  core_arch:
    path: packages/core_arch

  # 按需引入：认证模块（选择 Apple 或 Google 渠道）
  core_auth:
    path: packages/core_auth_apple

  # 按需引入：支付与商业化订阅
  core_pay:
    path: packages/core_pay_revenuecat

  # 按需引入：AI 能力
  core_llm:
    path: packages/core_llm
```
