/// Generic LLM Chat Role.
enum LlmRole {
  system,
  user,
  assistant,
}

/// Single chat message.
class LlmChatMessage {
  final LlmRole role;
  final String content;

  const LlmChatMessage({
    required this.role,
    required this.content,
  });

  Map<String, dynamic> toJson() => {
        'role': role.name,
        'content': content,
      };

  factory LlmChatMessage.user(String content) =>
      LlmChatMessage(role: LlmRole.user, content: content);

  factory LlmChatMessage.system(String content) =>
      LlmChatMessage(role: LlmRole.system, content: content);

  factory LlmChatMessage.assistant(String content) =>
      LlmChatMessage(role: LlmRole.assistant, content: content);
}

/// Generic LLM Request Configuration.
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

  /// Factory helper for simple single-turn prompt requests.
  factory LlmRequest.prompt(
    String userPrompt, {
    String? systemPrompt,
    double? temperature,
    int? maxTokens,
  }) {
    return LlmRequest(
      messages: [LlmChatMessage.user(userPrompt)],
      systemPrompt: systemPrompt,
      temperature: temperature ?? 0.3,
      maxTokens: maxTokens ?? 2048,
    );
  }
}

/// Generic LLM Response.
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
