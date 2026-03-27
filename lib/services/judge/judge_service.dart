// Execute user code and run tests against test cases.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/exercise/exercise.dart';
import './judge_config.dart';
import '../db/firestore_service.dart';

// Store the outcome of a single test case execution, including the output and errors.
class JudgeResult {
  final bool success;
  final String output;
  final String? error;
  final String? compileError;

  JudgeResult({
    required this.success,
    required this.output,
    this.error,
    this.compileError,
  });
}

// Handle data operations and service integration for the Judge Service.
class JudgeService {
  final FirestoreService _firestore = FirestoreService();

  Future<void> _ensureFirestoreUrlLoaded() async {
    if (JudgeConfig.firestoreBaseUrl == null) {
      try {
        final url =
            await _firestore.getPistonUrl().timeout(const Duration(seconds: 4));
        if (url != null && url.isNotEmpty) {
          JudgeConfig.setFirestoreBaseUrl(url);
        }
      } catch (_) {}
    }
  }

  static String _normalizeLanguage(String lang) {
    switch (lang.toLowerCase().trim()) {
      case 'c++':
      case 'cpp':
      case 'c':
        return 'cpp';
      case 'python':
      case 'py':
      case 'python3':
        return 'python';
      default:
        return lang.toLowerCase();
    }
  }

  Future<JudgeResult> submitCode({
    required String sourceCode,
    required String language,
    String stdin = '',
    String? expectedOutput,
    String? outputFile,
    String? inputFile,
    String? inputContent,
    List<ExerciseFile> files = const [],
    int? timeLimitMs,
    int? memoryLimitMb,
  }) async {
    await _ensureFirestoreUrlLoaded();

    final normalized = _normalizeLanguage(language);

    String finalSourceCode = sourceCode;

    if (inputFile != null && inputFile.isNotEmpty && inputContent != null) {
      finalSourceCode = _injectInputFile(
          normalized, inputFile, inputContent, finalSourceCode);
    }

    if (outputFile != null) {
      finalSourceCode =
          _injectFileCapture(normalized, outputFile, finalSourceCode);
    }

    if (memoryLimitMb != null) {
      finalSourceCode =
          _injectMemoryLimit(normalized, memoryLimitMb, finalSourceCode);
    }

    try {
      final cleanStdin = stdin.replaceAll('\r', '');
      final data = await _executePiston(
          normalized, finalSourceCode, cleanStdin, files,
          timeLimitMs: timeLimitMs, memoryLimitMb: memoryLimitMb);

      if (data == null) {
        return JudgeResult(
            success: false, output: '', error: 'Empty response from judge');
      }

      final stdout = _extractStdout(data);
      final stderr = _extractStderr(data);
      final compileErr = _extractCompileError(data);
      final runtimeError =
          _detectRuntimeError(data, timeLimitMs, memoryLimitMb);
      bool accepted = runtimeError == null && _exitedClean(data);

      if (accepted && expectedOutput != null) {
        accepted = _matchOutput(stdout, expectedOutput, outputFile);
      }

      return JudgeResult(
        success: accepted,
        output: stdout,
        error: runtimeError != null
            ? (stderr.isNotEmpty ? '$runtimeError\n$stderr' : runtimeError)
            : (stderr.isNotEmpty ? stderr : null),
        compileError: compileErr.isNotEmpty ? compileErr : null,
      );
    } catch (e) {
      return JudgeResult(success: false, output: '', error: e.toString());
    }
  }

  Future<Map<String, dynamic>?> _executePiston(
    String normalized,
    String sourceCode,
    String stdin,
}