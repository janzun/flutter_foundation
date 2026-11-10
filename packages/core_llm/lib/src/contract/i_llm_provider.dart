import 'llm_models.dart';

/// Universal LLM Provider Interface.
abstract class ILlmProvider {
  /// Provider unique identifier, e.g. 'gemini', 'openai', 'deepseek'.
  String get providerId;

  /// Performs a non-streaming text generation request.
  Future<LlmResponse> generateText(LlmRequest request);

  /// Performs a streaming text generation request (returns tokens/chunks as text).
  Stream<String> generateStream(LlmRequest request);
}
