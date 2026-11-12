# Flutter Foundation

现代化 Flutter 商业级独立多模块底座代码库（Monorepo），专注于高性能、极低耦合、0 敏感权限架构与多端抹平。

---

## 📦 模块矩阵 (Packages)

| Package | 职责介绍 | 最新 Tag | 依赖与特性 |
| :--- | :--- | :--- | :--- |
| **[`core_arch`](packages/core_arch)** | 架构基建：UDF MVVM、网络防御、0 权限沙盒 I/O、流式防 OOM 聚合备份 | `arch@1.0.0` | 纯 Dart / 零敏感权限 |
| **[`core_database`](packages/core_database)** | 结构化存储：Isar NoSQL、代码优先 (Code-First)、跨表原子事务、防毁库安全快照还原 | `database@1.0.0` | 路径外部注入 / 彻底解耦 |
| **[`core_io`](packages/core_io)** | 跨端资产交互：原生相册选取/拍摄、文件另存为/下载、跨端流式 PickedFile | `io@1.0.0` | 抹平 Mobile/Desktop/Web |
| **[`core_auth_base`](packages/core_auth_base)** | 统一身份契约：IAuthService 抽象基类、通用 AuthUser、TokenCredential 实体 | `auth_base@1.0.0` | 抽象层 / 无厂商锁死 |
| **[`core_auth_apple`](packages/core_auth_apple)** | Apple 渠道登录复用：专为 iOS/macOS 打造的渠道登录闭环，全量透传 `core_auth_base` 并默认原生 Apple 授权 | `auth_apple@1.0.0` | iOS / macOS / 原生集成 |
| **[`core_auth_google`](packages/core_auth_google)** | Google 渠道登录复用：专为 Android/Web 打造的渠道登录闭环，全量透传 `core_auth_base` 并默认原生 Google 授权 | `auth_google@1.0.0` | Android / iOS / Web 跨端 |
| **[`core_pay_base`](packages/core_pay_base)** | 支付领域抽象：IPayService 契约、Freezed 不可变订阅模型、统一 PayResult 状态机 | `pay_base@1.0.0` | 纯领域抽象 / 零云依赖 |
| **[`core_pay_revenuecat`](packages/core_pay_revenuecat)** | 支付实现：RevenueCat Purchases SDK 适配器、StoreProduct 统一转换 | `pay_revenuecat@1.0.0` | 抹平 AppStore/GooglePlay |
| **[`core_analytics`](packages/core_analytics)** | 高性能埋点：统一网关协议 POST /v1/events、全自动路由停留统计、批量异步微任务队列 | `analytics@1.0.0` | 零第三方云 SDK 依赖 |
| **[`core_camera`](packages/core_camera)** | 原生极速相机：Zero-Shutter-Lag 秒拍、4:3 画幅满帧、原子 AF/AE、零拷贝人脸实时分析流 | `camera@1.0.0` | Android CameraX + iOS AVFoundation |
| **[`core_llm`](packages/core_llm)** | 统一大模型：Gemini 与 OpenAI Compatible 双适配器、流式输出、纪要提炼 SummaryHelper | `llm@1.0.0` | 纯净 Markdown / 多语言自适应 |

---

## 🚀 外部工程接入规范 (Usage)

在具体业务 App 的 `pubspec.yaml` 中，通过 Git Path + Tag 锁定所需底座模块：

```yaml
dependencies:
  # 基础架构与网络
  core_arch:
    git:
      url: git@github.com:janzun/flutter_foundation.git
      path: packages/core_arch
      ref: arch@1.0.0

  # 本地数据库 (按需)
  core_database:
    git:
      url: git@github.com:janzun/flutter_foundation.git
      path: packages/core_database
      ref: database@1.0.0

  # 文件与媒体选取/保存 (按需)
  core_io:
    git:
      url: git@github.com:janzun/flutter_foundation.git
      path: packages/core_io
      ref: io@1.0.0

  # 埋点与数据统计 (按需)
  core_analytics:
    git:
      url: git@github.com:janzun/flutter_foundation.git
      path: packages/core_analytics
      ref: analytics@1.0.0

  # 大模型与 AI 助手 (按需)
  core_llm:
    git:
      url: git@github.com:janzun/flutter_foundation.git
      path: packages/core_llm
      ref: llm@1.0.0
```

---

## 🤖 AI Agent 发版与维护铁律

所有在此仓库进行代码迭代的 Agent 必须严格遵循 [`.agents/rules/package_release_rules.md`](.agents/rules/package_release_rules.md) 中定义的 SOP 规范：

1. **质量门禁**：改动后必须执行 `flutter analyze` 保持 0 issues，相关单测 100% 通过。
2. **版本号递增**：改动受影响 package 的 `pubspec.yaml` 版本号（遵循 SemVer 规范）。
3. **README 同步**：更新受影响 package `README.md`，严格遵循统一五段式结构（介绍、最新版本 Tag、接入方式、必要配置、完整 API 列表）。
4. **Git 打标发布**：每次版本发布必须打上 `<short_name>@<version>` 格式的 Git Tag 并推送到远程。
