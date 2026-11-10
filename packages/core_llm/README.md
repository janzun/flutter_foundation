# core_llm

通用大模型（LLM）适配器与 AI 提示词工具集，为 Flutter / Dart 应用提供统一的多模型接入抽象。支持 Google Gemini、OpenAI 兼容协议（DeepSeek、ChatGPT、Groq、Moonshot 等），涵盖非流式输出、SSE 流式打字机输出以及特定场景（如会议纪要/总结）的增强工具。

---

## 模块定位

- **统一抽象**：通过 `ILlmProvider` 屏蔽底层各供应商 API 差异。
- **开箱即用 Provider**：
  - `GeminiProvider`: 原生接入 Google Gemini API。
  - `OpenAiCompatProvider`: 适配所有遵循 OpenAI 标准 RESTful/SSE 规范的大模型（如 DeepSeek、OpenAI、本地 Ollama 等）。
- **统一门面**：`CoreLlmClient` 提供统一的工厂构造与调用接口。
- **场景助手**：内置 `SummaryHelper`，简化长文本、会议记录的摘要与行动项提取。

---

## 依赖配置

在宿主 App 的 `pubspec.yaml` 中引入：

```yaml
dependencies:
  core_llm:
    path: packages/core_llm
```

---

## 快速使用

### 1. 初始化客户端

```dart
import 'package:core_llm/core_llm.dart';

// 方式 A：接入 Google Gemini
final geminiClient = CoreLlmClient.gemini(
  apiKey: 'YOUR_GEMINI_API_KEY',
  modelName: 'gemini-1.5-flash',
);

// 方式 B：接入 DeepSeek 或其他兼容 OpenAI 接口的模型
final deepseekClient = CoreLlmClient.openAiCompat(
  apiKey: 'YOUR_DEEPSEEK_API_KEY',
  baseUrl: 'https://api.deepseek.com/v1',
  modelName: 'deepseek-chat',
  providerId: 'deepseek',
);
```

### 2. 非流式单次生成

```dart
final response = await geminiClient.generate(
  LlmRequest(
    messages: [
      LlmMessage.system('你是一个专业的 Flutter 架构专家。'),
      LlmMessage.user('请用三句话总结 Flutter 的优势。'),
    ],
    temperature: 0.7,
  ),
);

print('回答内容: ${response.text}');
print('消耗 Token: ${response.usage?.totalTokens}');
```

### 3. SSE 流式打字机输出

```dart
final stream = deepseekClient.generateStream(
  LlmRequest(
    messages: [
      LlmMessage.user('请写一段关于架构设计的短文。'),
    ],
  ),
);

// 实时响应文本流
await for (final chunk in stream) {
  // 追加渲染到 UI
  stdout.write(chunk);
}
```

### 4. 使用 SummaryHelper 进行文本摘要

```dart
final summaryHelper = geminiClient.summary;

final result = await summaryHelper.summarizeMeeting(
  transcript: '会议讨论了关于底座封装的架构设计，决议将 core_auth 和 core_pay 分离...',
  language: 'zh',
);

print('会议要点: ${result.summary}');
print('行动项列表: ${result.actionItems}');
```

---

## 核心 API

| 类 / 接口 | 核心方法 / 说明 |
| :--- | :--- |
| `CoreLlmClient` | 统一入口门面：`gemini()` / `openAiCompat()` 工厂构造，提供 `generate()` 与 `generateStream()` |
| `ILlmProvider` | 底层通用 Provider 接口：`generateText(LlmRequest)` / `generateStream(LlmRequest)` |
| `LlmRequest` | 请求参数封装：包含 `messages`、`temperature`、`maxTokens`、`model` 等 |
| `LlmMessage` | 消息结构：支持 `LlmMessage.system()`、`user()`、`assistant()` 构造 |
| `LlmResponse` | 响应数据结构：包含 `text`、`rawJson`、`usage` (Prompt/Completion/TotalTokens) |
| `SummaryHelper` | 会议纪要与长文本提炼辅助工具 |
