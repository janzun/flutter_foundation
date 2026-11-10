# core_arch

为 Flutter 移动端项目提供核心架构与底层开发框架封装，支持跨项目复用。

## 目录与功能支持

目前已集成的架构设计模式：

### 1. MVI / MVVM 架构基础

基于 `Provider` + `Stream` 设计模式构建的单向数据流 (Unidirectional Data Flow, UDF) 框架，包含以下底层基类：

- **`BaseUiState`**：页面状态基类，推荐搭配 `freezed` 实现不可变状态管理。
- **`BaseUiEvent`**：一次性瞬时副作用事件基类（例如：Toast 提示、跳转路由、弹窗等），避免页面因 Widget 树重建造成副作用重复执行。
- **`BaseViewModel<S, E>`**：视图模型基类，生命周期与 Widget 树绑定，包含统一的 `uiState` 状态分发与 `uiEvent` 广播事件流。

#### 核心使用约定

详细设计及编码范式，请查阅 `lib/mvvm/demo/` 目录下的实现。

1. **单向数据源**：UI 只能通过调用 ViewModel 的 Intent 方法去触发状态更新或发出事件，不能直接修改状态。
2. **生命周期自托管**：ViewModel 内部生命周期销毁时，自动关闭事件广播流和清理事件订阅。

---

## 后续规划

- 添加基础网络请求库封装 (`core_network`)。
- 添加通用基础组件与常用工具类封装 (`core_util`)。
