# Packages Directory

本目录用于存放所有独立沉淀的可复用功能底座模块。每个模块以独立 Package 的形态维护，便于后续通过 Git Submodule、Git 依赖或发布到私有 pub 仓库被其他 App 项目直接引用。

### 示例结构建议

- `packages/foundation_core/`: 核心基础通用工具、数据结构与常量
- `packages/foundation_net/`: 网络层封装（Dio / Retrofit、Token 刷新拦截器、统一错误处理）
- `packages/foundation_storage/`: 本地存储封装（KV 缓存、安全加密存储等）
- `packages/foundation_ui/`: 通用 UI 设计规范、组件库与主题 Token
- `packages/foundation_auth/`: 认证与会话管理能力
- `packages/foundation_analytics/`: 埋点与日志追踪底座
