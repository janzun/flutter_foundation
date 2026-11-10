import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../contract/i_llm_provider.dart';
import '../contract/llm_models.dart';

/// Structured Meeting / Audio Summary result model.
class MeetingSummaryResult {
  final String overview;
  final List<String> keyPoints;
  final List<String> actionItems;
  final String rawOutput;

  const MeetingSummaryResult({
    required this.overview,
    required this.keyPoints,
    required this.actionItems,
    this.rawOutput = '',
  });

  /// Formats this summary into a clean, markdown document.
  String toFormattedMarkdown() {
    final sb = StringBuffer();
    if (overview.isNotEmpty) {
      sb.writeln('### 💡 核心概述\n$overview\n');
    }
    if (keyPoints.isNotEmpty) {
      sb.writeln('### 📌 讨论要点');
      for (final p in keyPoints) {
        sb.writeln('- $p');
      }
      sb.writeln();
    }
    if (actionItems.isNotEmpty) {
      sb.writeln('### ✅ 待办事项');
      for (final a in actionItems) {
        sb.writeln('- [ ] $a');
      }
    }
    return sb.toString().trim();
  }

  Map<String, dynamic> toJson() => {
        'overview': overview,
        'keyPoints': keyPoints,
        'actionItems': actionItems,
      };

  factory MeetingSummaryResult.fromJson(Map<String, dynamic> json, {String raw = ''}) {
    final overview = json['overview'] as String? ?? '';
    final keyPoints = (json['keyPoints'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final actionItems = (json['actionItems'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return MeetingSummaryResult(
      overview: overview,
      keyPoints: keyPoints,
      actionItems: actionItems,
      rawOutput: raw,
    );
  }
}

/// Helper utility to generate structured summaries using an [ILlmProvider].
class SummaryHelper {
  final ILlmProvider provider;

  const SummaryHelper(this.provider);

  /// Generates a Markdown formatted summary for the given [transcript] and [template].
  Future<String> generateMarkdownSummary(String transcript, {String template = 'meeting'}) async {
    if (transcript.trim().isEmpty) {
      return '### 提示\n暂无转写文本可提炼。';
    }

    final lang = _detectLanguage(transcript);
    final templateInstruction = _getTemplateInstruction(template, lang);

    final String langRule;
    if (lang == 'zh') {
      langRule = '全文必须使用规范的纯简体中文。所有标题、正文、待办事项均只能使用中文，严禁在标题或内容中包含英文翻译、中英双语或斜杠混杂（例如严禁出现 "核心概述 / Executive Summary" 这种格式）。';
    } else if (lang == 'ja') {
      langRule = '全文必须使用规范的纯日文。所有标题、正文、待办事项均只能使用日文，严禁包含中英文混杂。';
    } else if (lang == 'ko') {
      langRule = '全文必须使用规范的纯韩文。所有标题、正文、待办事项均只能使用韩文，严禁包含中英文混杂。';
    } else {
      langRule = 'The entire document MUST be written in professional business English. All headings, body paragraphs, and action items must be 100% in English without any Chinese or other language characters.';
    }

    final systemPrompt = '''
你是一名资深的文档与会议纪要整理专家。请对用户提供的【转写全文内容】进行结构化提炼与总结。
【严格遵循以下格式与规则】：
1. 【首行一级标题】：输出的第一行必须是一个精炼、准确概括转写核心主题的 Markdown 一级标题（格式为 `# 主题标题`，15字或6个英文单词以内，不带多余符号与Emoji）。
2. 【单一语言原则】：$langRule
3. 【无 Emoji 原则】：严禁输出任何 Emoji 图标（如 💡、📌、🎓、🚀 等），保证商业公文级排版。
4. 【格式纯净原则】：直接输出排版优雅的标准 Markdown 文档，不要使用 ```markdown 包装，也不要输出任何多余的前缀寒暄文本。
5. 参考以下结构模块进行提炼（二级标题使用 ## 开头）：
$templateInstruction
''';

    final request = LlmRequest.prompt(
      '【转写全文内容】：\n$transcript',
      systemPrompt: systemPrompt,
      temperature: 0.2,
      maxTokens: 2048,
    );

    final response = await provider.generateText(request);
    var text = response.text.trim();
    if (text.startsWith('```markdown')) {
      text = text.replaceFirst(RegExp(r'^```markdown\s*'), '');
      if (text.endsWith('```')) {
        text = text.substring(0, text.length - 3).trim();
      }
    } else if (text.startsWith('```')) {
      text = text.replaceFirst(RegExp(r'^```\s*'), '');
      if (text.endsWith('```')) {
        text = text.substring(0, text.length - 3).trim();
      }
    }
    return text.trim();
  }

  /// 语言探测
  static String _detectLanguage(String text) {
    if (text.isEmpty) return 'en';
    final zhCount = RegExp(r'[\u4e00-\u9fa5]').allMatches(text).length;
    final jaCount = RegExp(r'[\u3040-\u30ff]').allMatches(text).length;
    final koCount = RegExp(r'[\uac00-\ud7af]').allMatches(text).length;

    if (zhCount > 0 && zhCount >= jaCount && zhCount >= koCount) return 'zh';
    if (jaCount > 0 && jaCount > zhCount) return 'ja';
    if (koCount > 0 && koCount > zhCount) return 'ko';
    return 'en';
  }

  /// 获取纯单语结构的模板规范
  static String _getTemplateInstruction(String template, String lang) {
    if (lang == 'zh') {
      switch (template) {
        case 'study':
          return '''
# [提炼学习主题与核心课程名称]

## 知识框架
（简述本次学习/讲座的核心主题与知识体系）

## 核心概念与重点
- **概念1**：详细解析与说明
- **概念2**：详细解析与说明

## 课后复习与思考
- [ ] 复习要点与练习1
- [ ] 关键思考题2
''';
        case 'brainstorm':
          return '''
# [提炼头脑风暴核心议题]

## 创意与灵感亮点
（提炼总结本次头脑风暴提出的核心创意点子）

## 核心点子与可行性分析
- **创意点1**：优势、潜在风险与落地分析
- **创意点2**：优势、潜在风险与落地分析

## 下一步推进计划
- [ ] 优先推进项1
- [ ] 验证项2
''';
        case 'interview':
          return '''
# [提炼访谈核心主题]

## 访谈背景与核心结论
（客观总结受访者背景及本次访谈的核心结论）

## 关键问答与观点归纳
- **议题1**：受访者核心观点与论据
- **议题2**：受访者核心观点与论据

## 深度洞察与启示
- [ ] 核心发现与洞察1
- [ ] 待验证事项2
''';
        case 'meeting':
        default:
          return '''
# [提炼会议核心主题]

## 核心概述
（客观简练概括本次会议的核心主旨与达成的共识）

## 讨论要点与决策
- **决策/议题1**：详细讨论背景与最终结论
- **决策/议题2**：详细讨论背景与最终结论

## 待办事项
- [ ] 责任人与待办事项1
- [ ] 责任人与待办事项2
''';
      }
    } else if (lang == 'ja') {
      switch (template) {
        case 'study':
          return '''
# [学習テーマ・講義名]

## 知識の全体像
（本講義・学習の全体テーマと体系的なまとめ）

## 重要概念と要点
- **概念1**：詳細な解説と説明
- **概念2**：詳細な解説と説明

## 復習と今後の課題
- [ ] 復習ポイント1
- [ ] 検討事項2
''';
        case 'brainstorm':
          return '''
# [ブレインストーミングのテーマ]

## アイデア・ハイライト
（今回出された主要なアイデアの要約）

## 主要アイデアと実現可能性
- **アイデア1**：強み・リスク・実行可能性
- **アイデア2**：强み・リスク・実行可能性

## 今後のアクション
- [ ] 優先対応項目1
- [ ] 検証項目2
''';
        case 'interview':
          return '''
# [インタビューテーマ]

## 背景と全体結論
（インタビューの背景と得られた主な結論）

## 主な質疑応答と意見
- **トピック1**：回答者の見解と論拠
- **トピック2**：回答者の見解と論拠

## インサイトと学び
- [ ] 得られた発見1
- [ ] 今後の確認事項2
''';
        case 'meeting':
        default:
          return '''
# [会議の主要テーマ]

## エグゼクティブサマリー
（会議の目的と決定事項の簡潔な要約）

## 主な議論と決定事項
- **議題1**：背景と結論
- **議題2**：背景と結論

## アクションアイテム
- [ ] 担当者とタスク1
- [ ] 担当者とタスク2
''';
      }
    } else if (lang == 'ko') {
      switch (template) {
        case 'study':
          return '''
# [학습 주제 및 강의명]

## 지식 프레임워크
（강의 및 학습의 핵심 주제와 지식 체계 요약）

## 핵심 개념 및 요점
- **개념 1**：상세 설명
- **개념 2**：상세 설명

## 복습 및 실행 과제
- [ ] 복습 포인트 1
- [ ] 생각할 과제 2
''';
        case 'brainstorm':
          return '''
# [브레인스토밍 핵심 주제]

## 아이디어 하이라이트
（제안된 주요 아이디어 요약）

## 핵심 아이디어 및 타당성 분석
- **아이디어 1**：장점, 리스크 및 실행 방안
- **아이디어 2**：장점, 리스크 및 실행 방안

## 향후 추진 계획
- [ ] 우선 추진 항목 1
- [ ] 검증 항목 2
''';
        case 'interview':
          return '''
# [인터뷰 핵심 주제]

## 인터뷰 배경 및 주요 결론
（인터뷰 대상 배경 및 핵심 결론 요약）

## 주요 질의응답 및 의견 정리
- **주제 1**：핵심 견해 및 근거
- **주제 2**：핵심 견해 및 근거

## 인사이트 및 시사점
- [ ] 주요 발견점 1
- [ ] 추가 확인 사항 2
''';
        case 'meeting':
        default:
          return '''
# [회의 핵심 주제]

## 개요
（회의 목적 및 주요 합의 사항 요약）

## 주요 논의 및 결정 사항
- **안건 1**：논의 배경 및 최종 결정
- **안건 2**：논의 배경 및 최종 결정

## 실행 과제
- [ ] 담당자 및 실행 과제 1
- [ ] 담당자 및 실행 과제 2
''';
      }
    } else {
      // English
      switch (template) {
        case 'study':
          return '''
# [Subject / Lecture Topic]

## Knowledge Framework
(Overview of the core subject and conceptual framework)

## Key Concepts & Highlights
- **Concept 1**: Detailed explanation and analysis
- **Concept 2**: Detailed explanation and analysis

## Review & Action Items
- [ ] Review task 1
- [ ] Critical question 2
''';
        case 'brainstorm':
          return '''
# [Brainstorming Subject]

## Creative Highlights
(Summary of top creative ideas generated)

## Idea Evaluation & Feasibility
- **Idea 1**: Strengths, potential risks, and execution path
- **Idea 2**: Strengths, potential risks, and execution path

## Next Steps
- [ ] Priority item 1
- [ ] Validation item 2
''';
        case 'interview':
          return '''
# [Interview Subject]

## Background & Executive Summary
(Overview of interviewee background and key takeaways)

## Key Q&A & Perspectives
- **Topic 1**: Core arguments and insights
- **Topic 2**: Core arguments and insights

## Key Insights
- [ ] Insight 1
- [ ] Verification item 2
''';
        case 'meeting':
        default:
          return '''
# [Meeting Subject]

## Executive Summary
(Objective summary of the meeting purpose and agreements)

## Key Discussions & Decisions
- **Decision 1**: Background context and conclusion
- **Decision 2**: Background context and conclusion

## Action Items
- [ ] Assignee and task 1
- [ ] Assignee and task 2
''';
      }
    }
  }

  /// Generates a structured summary for the given [transcript].
  Future<MeetingSummaryResult> generateSummary(String transcript, {String template = 'meeting'}) async {
    if (transcript.trim().isEmpty) {
      return const MeetingSummaryResult(
        overview: '无转写内容',
        keyPoints: [],
        actionItems: [],
      );
    }

    final markdown = await generateMarkdownSummary(transcript, template: template);
    return parseSummaryResponse(markdown);
  }

  /// Parses JSON response with robust cleanup.
  static MeetingSummaryResult parseSummaryResponse(String rawText) {
    try {
      var cleaned = rawText.trim();
      // 清除 ```json 和 ``` 标记
      if (cleaned.startsWith('```')) {
        cleaned = cleaned.replaceFirst(RegExp(r'^```(json)?\s*'), '');
        if (cleaned.endsWith('```')) {
          cleaned = cleaned.substring(0, cleaned.length - 3).trim();
        }
      }

      final dynamic decoded = jsonDecode(cleaned);
      if (decoded is Map<String, dynamic>) {
        return MeetingSummaryResult.fromJson(decoded, raw: rawText);
      }
    } catch (e, stack) {
      debugPrint('SummaryHelper.parseSummaryResponse failed. Error: $e\n$stack\nRaw: $rawText');
    }

    // 容错降级：如果不是标准 JSON，将全文作为 overview
    return MeetingSummaryResult(
      overview: rawText.trim(),
      keyPoints: const [],
      actionItems: const [],
      rawOutput: rawText,
    );
  }
}
