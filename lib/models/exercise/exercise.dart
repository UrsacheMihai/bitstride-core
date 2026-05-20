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
class Exercise {
  final String id;
  final String title;
  final String description;
  final String type;
  final String initialCode;
  final String? initialCodeCpp;
  final String? initialCodePython;
  final String solutionCode;
  final List<TestCase> tests;
  final List<ExerciseFile> files;
  final String successMascot;
  final String failMascot;
  final List<ContentBlock> contentBlocks;
  final int? memoryLimitMb;
  final int? timeLimitMs;

  Exercise({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.initialCode,
    this.initialCodeCpp,
    this.initialCodePython,
    this.solutionCode = '',
    required this.tests,
    this.files = const [],
    required this.successMascot,
    required this.failMascot,
    this.contentBlocks = const [],
    this.memoryLimitMb,
    this.timeLimitMs,
  });

  Exercise copyWith(
      {String? title, String? description, List<ContentBlock>? contentBlocks}) {
    return Exercise(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type,
      initialCode: initialCode,
      initialCodeCpp: initialCodeCpp,
      initialCodePython: initialCodePython,
      solutionCode: solutionCode,
      tests: tests,
      files: files,
      successMascot: successMascot,
      failMascot: failMascot,
      contentBlocks: contentBlocks ?? this.contentBlocks,
      memoryLimitMb: memoryLimitMb,
      timeLimitMs: timeLimitMs,
    );
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      type: json['type'] ?? 'code',
      initialCode: json['initial_code'] ?? '',
      // Uses only dedicated initial code fields, never falls back to solution code.
      initialCodeCpp: json['initial_code_cpp'],
      initialCodePython: json['initial_code_python'],
      solutionCode: json['solution_code'] ?? '',
      tests:
          (json['tests'] as List?)?.map((t) => TestCase.fromJson(t)).toList() ??
              [],
      files: (json['files'] as List?)
              ?.map((f) => ExerciseFile.fromJson(f))
              .toList() ??
          [],
      successMascot: json['success_mascot'] ?? 'thumbs-up-4b8ec7e7-360.webm',
      failMascot: json['fail_mascot'] ?? 'thinking-hard-e507f346-360.webm',
      contentBlocks: (json['content_blocks'] as List?)
              ?.map((b) => ContentBlock.fromJson(b))
              .toList() ??
          [],
      memoryLimitMb: json['memory_limit_mb'] as int?,
      timeLimitMs: json['time_limit_ms'] as int?,
    );
  }
}

// Course definition and initialization
class Course {
  final String id;
  final String title;
  final String language;
  final List<Exercise> lessons;

  Course(
      {required this.id,
      required this.title,
      required this.language,
      required this.lessons});

  Course copyWith({String? id, String? title, List<Exercise>? lessons}) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      language: language,
      lessons: lessons ?? this.lessons,
    );
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Unknown Course',
      language: json['language'] ?? 'cpp',
      lessons: (json['lessons'] as List?)
              ?.map((l) => Exercise.fromJson(l))
              .toList() ??
          [],
    );
  }
}

// Challenge definition and initialization
class Challenge {
  final String id;
  final String title;
  final String difficulty;
  final String category;
  final String method;
  final String description;
  final String? initialCodeCpp;
  final String? initialCodePython;
  final List<TestCase> tests;
  final List<ExerciseFile> files;
  final String successMascot;
  final String failMascot;
  final String? creatorName;
  final int? memoryLimitMb;
  final int? timeLimitMs;

  Challenge({
    required this.id,
    required this.title,
    required this.difficulty,
    this.category = '',
    this.method = '',
    required this.description,
    this.initialCodeCpp,
    this.initialCodePython,
    required this.tests,
    this.files = const [],
    required this.successMascot,
    required this.failMascot,
    this.creatorName,
    this.memoryLimitMb,
    this.timeLimitMs,
  });

  Challenge copyWith({String? title, String? description}) {
    return Challenge(
      id: id,
      title: title ?? this.title,
      difficulty: difficulty,
      category: category,
      method: method,
      description: description ?? this.description,
      initialCodeCpp: initialCodeCpp,
      initialCodePython: initialCodePython,
      tests: tests,
      files: files,
      successMascot: successMascot,
      failMascot: failMascot,
      creatorName: creatorName,
      memoryLimitMb: memoryLimitMb,
      timeLimitMs: timeLimitMs,
    );
  }

  factory Challenge.fromJson(Map<String, dynamic> json) {
    // Uses only dedicated initial code fields, never falls back to solution code.
    String? cppCode = json['initial_code_cpp'];
    String? pythonCode = json['initial_code_python'];

    if (json.containsKey('language') && json.containsKey('initial_code')) {
      if (json['language'] == 'cpp') {
        cppCode ??= json['initial_code'];
      } else {
        pythonCode ??= json['initial_code'];
      }
    }

    return Challenge(
      id: json['id'],
      title: json['title'],
      difficulty: (json['difficulty'] ?? 'easy').toString().toLowerCase(),
      category: json['category'] ?? '',
      method: json['method'] ?? '',
      description: json['description'] ?? '',
      initialCodeCpp: cppCode,
      initialCodePython: pythonCode,
      tests:
          (json['tests'] as List?)?.map((t) => TestCase.fromJson(t)).toList() ??
              [],
      files: (json['files'] as List?)
              ?.map((f) => ExerciseFile.fromJson(f))
              .toList() ??
          [],
      successMascot: json['success_mascot'] ?? 'thumbs-up-4b8ec7e7-360.webm',
      failMascot: json['fail_mascot'] ?? 'thinking-hard-e507f346-360.webm',
      creatorName: json['creator_name'],
      memoryLimitMb: json['memory_limit_mb'] as int?,
      timeLimitMs: json['time_limit_ms'] as int?,
    );
  }

  bool get hasCpp => initialCodeCpp != null && initialCodeCpp!.isNotEmpty;

  bool get hasPython =>
      initialCodePython != null && initialCodePython!.isNotEmpty;

  Exercise toExercise() {
    return Exercise(
      id: id,
      title: title,
      description: description,
      type: 'exercise',
      initialCode: '',
      initialCodeCpp: initialCodeCpp,
      initialCodePython: initialCodePython,
      solutionCode: '',
      tests: tests,
      files: files,
      successMascot: successMascot,
      failMascot: failMascot,
      contentBlocks: [],
      memoryLimitMb: memoryLimitMb,
      timeLimitMs: timeLimitMs,
    );
  }
}
