# core_llm

## 1. 介绍
跨平台通用 LLM 适配器与 AI 提示词工具包。统一封装 Google Gemini 与 OpenAI Compatible（支持 DeepSeek、OpenAI、月之暗面等任意兼容规范接口）的非流式与流式生成调用。内置会议纪要与录音转写结构化提炼工具 `SummaryHelper`，支持纯净 Markdown 导出与多语言自适应。

## 2. 最新版本 Tag
`llm@1.0.0`

## 3. 接入方式
在项目 `pubspec.yaml` 中通过 Git 形式引入：
```yaml
dependencies:
  core_llm:
    git:
      url: git@github.com:janzun/flutter_foundation.git
      path: packages/core_llm
      ref: llm@1.0.0
```

## 4. 必要配置
纯 Dart/Flutter 抽象层与网络协议实现，无原生硬件或平台权限配置要求。

## 5. 完整 API 列表

### 5.1 门面客户端 `CoreLlmClient`
```dart
class CoreLlmClient {
  final ILlmProvider provider;

  CoreLlmClient(this.provider);

  /// 快速构建 Google Gemini 客户端
  factory CoreLlmClient.gemini({
    required String apiKey,
    String modelName = 'gemini-1.5-flash',
  });

  /// 快速构建 OpenAI 兼容端点客户端（DeepSeek / ChatGPT 等）
  factory CoreLlmClient.openAiCompat({
    required String apiKey,
    required String baseUrl,
    String modelName = 'gpt-4o-mini',
    String? providerId,
  });

  /// 非流式生成
  Future<LlmResponse> generate(LlmRequest request);

  /// 流式 Token/块生成
  Stream<String> generateStream(LlmRequest request);

  /// 会议与纪要提炼助手
  SummaryHelper get summary;
}
```

### 5.2 核心模型与枚举

#### `LlmRole` 与 `LlmChatMessage`
```dart
enum LlmRole { system, user, assistant }

class LlmChatMessage {
  final LlmRole role;
  final String content;

  const LlmChatMessage({required this.role, required this.content});
  factory LlmChatMessage.user(String content);
  factory LlmChatMessage.system(String content);
  factory LlmChatMessage.assistant(String content);
  Map<String, dynamic> toJson();
}
```

#### `LlmRequest` 与 `LlmResponse`
```dart
class LlmRequest {
  final List<LlmChatMessage> messages;
  final String? systemPrompt;
  final double temperature;
  final int maxTokens;
  final Map<String, dynamic>? extraParams;

  const LlmRequest({
    required this.messages,
    this.systemPrompt,
    this.temperature = 0.3,
    this.maxTokens = 2048,
    this.extraParams,
  });

  factory LlmRequest.prompt(
    String userPrompt, {
    String? systemPrompt,
    double? temperature,
    int? maxTokens,
  });
}

class LlmResponse {
  final String text;
  final int? promptTokens;
  final int? completionTokens;
  final Map<String, dynamic>? rawResponse;

  const LlmResponse({
    required this.text,
    this.promptTokens,
    this.completionTokens,
    this.rawResponse,
  });
}
```

### 5.3 抽象接口与异常

#### `ILlmProvider`
```dart
abstract class ILlmProvider {
  String get providerId;
  Future<LlmResponse> generateText(LlmRequest request);
  Stream<String> generateStream(LlmRequest request);
}
```

#### 异常模型
```dart
class LlmException implements Exception {
  final String message;
  final String? providerId;
  final int? statusCode;
  final dynamic originalError;
}

class LlmAuthException extends LlmException {...}
class LlmRateLimitException extends LlmException {...}
```

### 5.4 结构化纪要助手 `SummaryHelper`
```dart
class SummaryHelper {
  final ILlmProvider provider;
  const SummaryHelper(this.provider);

  /// 根据长文本转写内容和模板生成精炼 Markdown 总结
  Future<String> generateMarkdownSummary(
    String transcript, {
    String template = 'meeting',
  });
}

class MeetingSummaryResult {
  final String overview;
  final List<String> keyPoints;
  final List<String> actionItems;
  final String rawOutput;

  String toFormattedMarkdown();
  Map<String, dynamic> toJson();
  factory MeetingSummaryResult.fromJson(Map<String, dynamic> json, {String raw = ''});
}
```
