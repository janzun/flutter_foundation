# 基础底座库开发、发版与文档维护铁律 (Agent Rules)

本规则是所有在此仓库进行代码开发、重构、发版与文档编写的 AI Agent 必须无条件严格遵循的最高指令。

---

## 一、代码修改与发版规范 (Versioning & Release SOP)

任何 Agent 在完成功能新增或缺陷修复后，提交代码前必须严格执行以下四步闭环：

1. **质量门禁核查 (Quality Gate)**:
   - 必须运行 `flutter analyze`，确保 0 errors、0 warnings。
   - 涉及核心逻辑改动的，必须执行对应包的 `flutter test`，确保测试 100% 通过。
2. **版本号递增 (SemVer Bump)**:
   - 检查本次修改涉及的 package：`packages/<pkg_name>`。
   - 必须将其 `packages/<pkg_name>/pubspec.yaml` 中的 `version` 递增：
     - Bug 修复：递增 Patch 版本（如 `1.0.0` -> `1.0.1`）。
     - 新特性增加：递增 Minor 版本（如 `1.0.0` -> `1.1.0`）。
     - 破坏性改动：递增 Major 版本（如 `1.0.0` -> `2.0.0`）。
   - 未发生代码改动的 package，严禁随意变动其版本号。
3. **README 同步更新**:
   - 必须同步更新 `packages/<pkg_name>/README.md` 中的【最新版本 Tag】为 `<pkg_name>-v<new_version>`。
4. **Git 提交与打 Tag (Commit & Tag)**:
   - Git Commit 描述必须遵循 Conventional Commits 规范，如 `fix(core_io): ...` 或 `feat(core_database): ...`。
   - 每次版本升级必须打上对应的 Git Tag：
     ```bash
     git tag <pkg_name>-v<new_version>
     git push origin main --tags
     ```

---

## 二、README 文档编写标准结构 (Documentation Rules)

为了确保既便于人类开发者快速检索，又能以最低的 Token 消耗被其他 Agent 消费，每个 package 的 `README.md` **必须且只能**严格遵循以下 5 大段落顺序编写，严禁颠倒或掺杂大段无意义的业务演示代码：

1. **介绍 (Overview)**: 
   - 1~2 句话点明模块定位、核心职责与设计原则，语言极度凝练，杜绝自嗨废话。
2. **最新版本 Tag (Latest Tag)**:
   - 显式声明最新稳定 Tag，形如 `<pkg_name>-v1.0.0`，方便外部依赖快速复制。
3. **接入方式 (Installation)**:
   - 统一给出标准的 Git Path 依赖声明代码块，锁定对应的最新 Tag `ref`。
4. **必要配置 (Configuration)**:
   - 仅列出 iOS `Info.plist` / Android `AndroidManifest.xml` / Web 的必要原生权限或基础配置；若该包为零配置，写明“纯 Dart/无需原生配置”。
5. **完整 API 列表 (API Reference)**:
   - **必须 100% 全量列出所有公开类与方法的完整签名**（含入参、默认值、返回类型），使 Agent 读取 README 即可掌握全部可用能力。
   - **严禁编写数十行冗余的完整 Widget 树或长篇业务代码**，采用“Dart 接口类签名 + 一行功能注释”的极简形式列出，必要时仅附带 1 个 3~5 行的最小调用示例。
