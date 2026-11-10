# Flutter Foundation Workspace

本项目为 Flutter 跨端通用功能底座工程，采用 Monorepo / Package-based 架构设计：

- **目标**：维护和沉淀其他 Flutter App 所需的可复用功能底座（如网络封装、存储、认证、UI组件库、日志与埋点等）。
- **根目录 App** (`lib/`, `test/`)：主要承担功能底座的集成与测试验证，提供沙盒演练场。
- **功能底座 Package** (`packages/`)：存放各个独立可拆分、可复用的子模块/插件/包。

## 支持平台

- [x] Android
- [x] iOS
- [x] macOS
- [x] Web
- [x] Windows

## 目录结构规划

```text
flutter_foundation/
├── android/               # Android 原生配置
├── ios/                   # iOS 原生配置
├── macos/                 # macOS 原生配置
├── web/                   # Web 配置
├── windows/               # Windows 原生配置
├── lib/                   # 宿主 App 代码（负责驱动测试、演示底座功能）
│   └── main.dart
├── test/                  # 集成与单元测试
├── packages/              # 存放各个具体可复用的功能底座 Package
│   └── README.md
├── pubspec.yaml           # 宿主 App 依赖配置（通过 path 依赖 packages 下的包）
└── README.md
```

## 在 packages 下创建新功能底座

推荐使用 Flutter/Dart 命令在 `packages/` 目录下创建对应类型的包：

```bash
cd packages
# 创建纯 Dart 逻辑包（如核心工具、算法模型）
dart create --template=package foundation_core

# 或创建包含 Flutter UI / 平台特性的 Flutter 包
flutter create --template=package foundation_ui
```

在根目录的 `pubspec.yaml` 中通过相对路径引用：

```yaml
dependencies:
  foundation_core:
    path: packages/foundation_core
```
