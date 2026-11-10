import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../contract/i_llm_provider.dart';
import '../contract/llm_exception.dart';
import '../contract/llm_models.dart';

/// Google Gemini REST API Provider implementation.
class GeminiProvider implements ILlmProvider {
  final String apiKey;
  final String modelName;
  final Dio _dio;

  GeminiProvider({
    required this.apiKey,
    this.modelName = 'gemini-1.5-flash',
    Dio? dio,
  }) : _dio = dio ?? Dio();

  @override
  String get providerId => 'gemini';

  @override
  Future<LlmResponse> generateText(LlmRequest request) async {
    try {
      final url =
          'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$apiKey';

      final contents = request.messages.map((m) {
        return {
          'role': m.role == LlmRole.user ? 'user' : 'model',
          'parts': [
            {'text': m.content}
          ],
        };
      }).toList();

      final body = <String, dynamic>{
        'contents': contents,
        if (request.systemPrompt != null && request.systemPrompt!.isNotEmpty)
          'systemInstruction': {
            'parts': [
              {'text': request.systemPrompt}
            ]
          },
        'generationConfig': {
          'temperature': request.temperature,
          'maxOutputTokens': request.maxTokens,
        },
      };

      final response = await _dio.post(
        url,
        data: body,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw LlmAuthException(
          'Gemini authorization failed: ${response.data}',
          providerId: providerId,
          statusCode: response.statusCode,
          originalError: response.data,
        );
      } else if (response.statusCode == 429) {
        throw LlmRateLimitException(
          'Gemini rate limit exceeded: ${response.data}',
          providerId: providerId,
          statusCode: response.statusCode,
          originalError: response.data,
        );
      } else if (response.statusCode != 200) {
        throw LlmException(
          'Gemini request failed: ${response.data}',
          providerId: providerId,
          statusCode: response.statusCode,
          originalError: response.data,
        );
      }

      final data = response.data as Map<String, dynamic>;
      final candidates = data['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        throw LlmException(
          'Gemini returned no candidates',
          providerId: providerId,
          originalError: data,
        );
      }

      final firstCandidate = candidates.first as Map<String, dynamic>;
      final content = firstCandidate['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List<dynamic>?;
      final text = parts != null && parts.isNotEmpty
          ? (parts.first['text'] as String? ?? '')
          : '';

      final usageMetadata = data['usageMetadata'] as Map<String, dynamic>?;

      return LlmResponse(
        text: text,
        promptTokens: usageMetadata?['promptTokenCount'] as int?,
        completionTokens: usageMetadata?['candidatesTokenCount'] as int?,
        rawResponse: data,
      );
    } catch (e, stack) {
      if (e is LlmException) rethrow;
      debugPrint('GeminiProvider.generateText failed. Error: $e\n$stack');
      throw LlmException(
        'Gemini request failed: $e',
        providerId: providerId,
        originalError: e,
      );
    }
  }

  @override
  Stream<String> generateStream(LlmRequest request) async* {
    // 基础非流式降级或流式实现
    final response = await generateText(request);
    yield response.text;
  }
}
