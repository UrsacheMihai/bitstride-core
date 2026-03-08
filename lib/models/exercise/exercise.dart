import 'dart:convert';

// Test Case definition
class TestCase {
  final String input;
  final String expectedOutput;
  final bool isHidden;
  final String? inputFile;
  final String? outputFile;

  TestCase({
    required this.input,
    required this.expectedOutput,
    this.isHidden = false,
    this.inputFile,
    this.outputFile,
  });

  factory TestCase.fromJson(Map<String, dynamic> json) {
    return TestCase(
      input: json['input'] ?? '',
      expectedOutput: json['expected_output'] ?? '',
      isHidden: json['is_hidden'] ?? false,
      inputFile: json['input_file'],
      outputFile: json['output_file'],
    );
  }
}

// Exercise File definition
class ExerciseFile {
  final String name;
  final String content;

  ExerciseFile({required this.name, required this.content});

  factory ExerciseFile.fromJson(Map<String, dynamic> json) {
    return ExerciseFile(
      name: json['name'] ?? '',
      content: json['content'] ?? '',
    );
  }
}

// Represents the structure of a quiz block.
class QuizData {
  final String question;
  final List<String> options;
  // Legacy single-answer index (kept for backward compatibility).
  final int correctIndex;
  // Support multiple correct answers when isMultipleChoice is true.
  final bool isMultipleChoice;
  final List<int> correctIndices;
  final String explanation;
  final List<String> explanations;

  QuizData({
    required this.question,
    required this.options,
    required this.correctIndex,
    this.isMultipleChoice = false,
    List<int>? correctIndices,
    this.explanation = '',
    List<String>? explanations,
  }) : correctIndices = correctIndices ?? [correctIndex],
       explanations = explanations ?? [];

  factory QuizData.fromJson(Map<String, dynamic> json) {
    final correctIndex = json['correctIndex'] as int? ?? 0;
    final isMultipleChoice = json['isMultipleChoice'] as bool? ?? false;
    // Parse correctIndices list, falling back to single correctIndex for backward compatibility.
    final List<int> correctIndices = json['correctIndices'] != null
        ? List<int>.from(json['correctIndices'])
        : [correctIndex];
    final explanation = json['explanation'] as String? ?? '';
    final List<String> explanations = json['explanations'] != null
        ? List<String>.from(json['explanations'])
        : [];
    return QuizData(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctIndex: correctIndex,
      isMultipleChoice: isMultipleChoice,
      correctIndices: correctIndices,
      explanation: explanation,
      explanations: explanations,
    );
  }

  Map<String, dynamic> toJson() => {
        'question': question,
        'options': options,
        'correctIndex': correctIndex,
        'isMultipleChoice': isMultipleChoice,
        'correctIndices': correctIndices,
        'explanation': explanation,
        'explanations': explanations,
      };

  // Parse quiz JSON from a raw string.
  static QuizData? parse(String rawJson) {
    try {
      final decoded = json.decode(rawJson);
      return QuizData.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }
}

// Content Block creation and initialization
class ContentBlock {
  final String type;
  final String content;

  ContentBlock({required this.type, required this.content});

  factory ContentBlock.fromJson(Map<String, dynamic> json) {
    return ContentBlock(
      type: json['type'] ?? 'text',
      content: json['content'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'type': type, 'content': content};
}

// Exercise definition and initialization