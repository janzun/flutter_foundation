import 'package:flutter_test/flutter_test.dart';
import 'package:core_llm/core_llm.dart';

class MockLlmProvider implements ILlmProvider {
  @override
  String get providerId => 'mock';

  @override
  Future<LlmResponse> generateText(LlmRequest request) async {
    return LlmResponse(
      text: 'Mock response for: ${request.messages.first.content}',
      promptTokens: 10,
      completionTokens: 20,
    );
  }

  @override
  Stream<String> generateStream(LlmRequest request) async* {
    yield 'Hello ';
    yield 'world!';
  }
}

void main() {
  group('CoreLlm Models & Client Tests', () {
    test('LlmChatMessage and LlmRequest helpers work', () {
      final userMsg = LlmChatMessage.user('Hi');
      expect(userMsg.role, LlmRole.user);
      expect(userMsg.content, 'Hi');
      expect(userMsg.toJson()['role'], 'user');

      final req = LlmRequest.prompt('Test prompt', systemPrompt: 'System rule');
      expect(req.messages.length, 1);
      expect(req.messages.first.content, 'Test prompt');
      expect(req.systemPrompt, 'System rule');
    });

    test('CoreLlmClient delegates to provider correctly', () async {
      final client = CoreLlmClient(MockLlmProvider());
      final res = await client.generate(LlmRequest.prompt('Ping'));
      expect(res.text, 'Mock response for: Ping');
      expect(res.promptTokens, 10);

      final chunks = await client.generateStream(LlmRequest.prompt('Stream')).toList();
      expect(chunks.join(), 'Hello world!');
    });

    test('MeetingSummaryResult markdown and json', () {
      const summary = MeetingSummaryResult(
        overview: 'Overview test',
        keyPoints: ['Point 1', 'Point 2'],
        actionItems: ['Item 1'],
      );
      final md = summary.toFormattedMarkdown();
      expect(md.contains('Overview test'), isTrue);
      expect(md.contains('Point 1'), isTrue);
      expect(md.contains('- [ ] Item 1'), isTrue);

      final json = summary.toJson();
      final restored = MeetingSummaryResult.fromJson(json);
      expect(restored.overview, 'Overview test');
      expect(restored.keyPoints.length, 2);
    });
  });
}
