import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../contract/i_llm_provider.dart';
import '../contract/llm_exception.dart';
import '../contract/llm_models.dart';

/// OpenAI API Compatible Provider (Supports DeepSeek, ChatGPT, Moonshot, Ollama, etc.)
class OpenAiCompatProvider implements ILlmProvider {
  final String apiKey;
  final String baseUrl;
  final String modelName;
  final String _customProviderId;
  final Dio _dio;

  OpenAiCompatProvider({
    required this.apiKey,
    this.baseUrl = 'https://api.openai.com/v1',
    this.modelName = 'gpt-4o-mini',
    String? providerId,
    Dio? dio,
  })  : _customProviderId = providerId ?? 'openai_compat',
        _dio = dio ?? Dio();

  @override
  String get providerId => _customProviderId;

  @override
  Future<LlmResponse> generateText(LlmRequest request) async {
    try {
      final endpoint = '${baseUrl.replaceAll(RegExp(r'/+$'), '')}/chat/completions';

      final messages = <Map<String, dynamic>>[];
      if (request.systemPrompt != null && request.systemPrompt!.isNotEmpty) {
        messages.add({
          'role': 'system',
          'content': request.systemPrompt,
        });
      }

      for (final m in request.messages) {
        messages.add({
          'role': m.role.name,
          'content': m.content,
        });
      }

      final body = <String, dynamic>{
        'model': modelName,
        'messages': messages,
        'temperature': request.temperature,
        'max_tokens': request.maxTokens,
        if (request.extraParams != null) ...request.extraParams!,
      };

      final response = await _dio.post(
        endpoint,
        data: body,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            if (apiKey.isNotEmpty) 'Authorization': 'Bearer $apiKey',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw LlmAuthException(
          'OpenAI compatible auth failed: ${response.data}',
          providerId: providerId,
          statusCode: response.statusCode,
          originalError: response.data,
        );
      } else if (response.statusCode == 429) {
        throw LlmRateLimitException(
          'Rate limit exceeded: ${response.data}',
          providerId: providerId,
          statusCode: response.statusCode,
          originalError: response.data,
        );
      } else if (response.statusCode != 200) {
        throw LlmException(
          'Request failed with status ${response.statusCode}: ${response.data}',
          providerId: providerId,
          statusCode: response.statusCode,
          originalError: response.data,
        );
      }

      final data = response.data as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) {
        throw LlmException(
          'No choices returned in completion',
          providerId: providerId,
          originalError: data,
        );
      }

      final firstChoice = choices.first as Map<String, dynamic>;
      final message = firstChoice['message'] as Map<String, dynamic>?;
      final text = message?['content'] as String? ?? '';

      final usage = data['usage'] as Map<String, dynamic>?;

      return LlmResponse(
        text: text,
        promptTokens: usage?['prompt_tokens'] as int?,
        completionTokens: usage?['completion_tokens'] as int?,
        rawResponse: data,
      );
    } catch (e, stack) {
      if (e is LlmException) rethrow;
      debugPrint('OpenAiCompatProvider.generateText failed. Error: $e\n$stack');
      throw LlmException(
        'OpenAI compat request failed: $e',
        providerId: providerId,
        originalError: e,
      );
    }
  }

  @override
  Stream<String> generateStream(LlmRequest request) async* {
    final response = await generateText(request);
    yield response.text;
  }
}
