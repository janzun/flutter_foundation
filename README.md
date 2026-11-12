# Flutter Foundation

现代化 Flutter 商业级独立多模块底座代码库（Monorepo），专注于高性能、极低耦合、0 敏感权限架构与多端抹平。

---

## 📦 模块矩阵 (Packages)

| Package | 职责介绍 | 最新 Tag | 依赖与特性 |
| :--- | :--- | :--- | :--- |
| **[`core_arch`](packages/core_arch)** | 架构基建：UDF MVVM、网络防御、0 权限沙盒 I/O、流式防 OOM 聚合备份 | `arch@1.0.0` | 纯 Dart / 零敏感权限 |
| **[`core_database`](packages/core_database)** | 结构化存储：Isar NoSQL、代码优先 (Code-First)、跨表原子事务、防毁库安全快照还原 | `database@1.0.0` | 路径外部注入 / 彻底解耦 |
| **[`core_io`](packages/core_io)** | 跨端资产交互：原生相册选取/拍摄、文件另存为/下载、跨端流式 PickedFile | `io@1.0.0` | 抹平 Mobile/Desktop/Web |

---

## 🚀 外部工程接入规范 (Usage)

在具体业务 App 的 `pubspec.yaml` 中，通过 Git Path + Tag 锁定所需底座模块：

```yaml
dependencies:
  # 基础架构与网络
  core_arch:
    git:
      url: https://github.com/janzun/flutter_foundation.git
      path: packages/core_arch
      ref: arch@1.0.0

  # 本地数据库 (按需)
  core_database:
    git:
      url: https://github.com/janzun/flutter_foundation.git
      path: packages/core_database
      ref: database@1.0.0

  # 文件与媒体选取/保存 (按需)
  core_io:
    git:
      url: https://github.com/janzun/flutter_foundation.git
      path: packages/core_io
      ref: io@1.0.0
```

---

## 🤖 AI Agent 发版与维护铁律

所有在此仓库进行代码迭代的 Agent 必须严格遵循 [`.agents/rules/package_release_rules.md`](.agents/rules/package_release_rules.md) 中定义的 SOP 规范：

1. **质量门禁**：改动后必须执行 `flutter analyze` 保持 0 issues，相关单测 100% 通过。
2. **版本号递增**：改动受影响 package 的 `pubspec.yaml` 版本号（遵循 SemVer 规范）。
3. **README 同步**：更新受影响 package `README.md` 的【最新版本 Tag】。
4. **Git 打标发布**：每次版本发布必须打上 `<pkg_name>-v<version>` 格式的 Git Tag 并推送到远程。
