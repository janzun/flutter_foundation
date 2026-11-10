import '../contract/i_llm_provider.dart';
import '../contract/llm_models.dart';
import '../helpers/summary_helper.dart';
import '../providers/gemini_provider.dart';
import '../providers/openai_compat_provider.dart';

/// Facade entry-point for the `core_llm` package.
class CoreLlmClient {
  final ILlmProvider provider;

  CoreLlmClient(this.provider);

  /// Creates a [CoreLlmClient] configured for Google Gemini.
  factory CoreLlmClient.gemini({
    required String apiKey,
    String modelName = 'gemini-1.5-flash',
  }) {
    return CoreLlmClient(GeminiProvider(
      apiKey: apiKey,
      modelName: modelName,
    ));
  }

  /// Creates a [CoreLlmClient] configured for OpenAI compatible endpoints (DeepSeek, ChatGPT, etc.)
  factory CoreLlmClient.openAiCompat({
    required String apiKey,
    required String baseUrl,
    String modelName = 'gpt-4o-mini',
    String? providerId,
  }) {
    return CoreLlmClient(OpenAiCompatProvider(
      apiKey: apiKey,
      baseUrl: baseUrl,
      modelName: modelName,
      providerId: providerId,
    ));
  }

  /// Generates non-streaming text completion.
  Future<LlmResponse> generate(LlmRequest request) =>
      provider.generateText(request);

  /// Generates streaming tokens/chunks.
  Stream<String> generateStream(LlmRequest request) =>
      provider.generateStream(request);

  /// Convenience accessor for meeting & transcription summarization.
  SummaryHelper get summary => SummaryHelper(provider);
}
