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
    List<ExerciseFile> extraFiles, {
    int? timeLimitMs,
    int? memoryLimitMb,
  }) async {
    final runtime = JudgeConfig.runtimes[normalized];
    if (runtime == null) {
      throw Exception('Unsupported language for Piston: $normalized');
    }

    final pistonFiles = <Map<String, String>>[
      {'content': sourceCode},
      ...extraFiles.map((f) => {'name': f.name, 'content': f.content}),
    ];

    final body = <String, dynamic>{
      'language': runtime.language,
      'version': runtime.version,
      'files': pistonFiles,
      if (stdin.isNotEmpty) 'stdin': stdin,
      'run_timeout': timeLimitMs ?? 10000,
      'compile_timeout': 30000,
      if (memoryLimitMb != null)
        'run_memory_limit': normalized == 'python'
            ? (memoryLimitMb + 128) * 1024 * 1024
            : (memoryLimitMb + 64) * 1024 * 1024,
    };

    final response = await http.post(
      Uri.parse(JudgeConfig.pistonExecuteUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Piston error ${response.statusCode}: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  String _extractStdout(Map<String, dynamic> data) {
    return (data['run'] as Map<String, dynamic>?)?['stdout'] ?? '';
  }

  String _extractStderr(Map<String, dynamic> data) {
    return (data['run'] as Map<String, dynamic>?)?['stderr'] ?? '';
  }

  String _extractCompileError(Map<String, dynamic> data) {
    return (data['compile'] as Map<String, dynamic>?)?['stderr'] ?? '';
  }

  bool _exitedClean(Map<String, dynamic> data) {
    final run = data['run'] as Map<String, dynamic>?;
    return run != null && run['code'] == 0 && run['signal'] == null;
  }

  String? _detectRuntimeError(
      Map<String, dynamic> data, int? timeLimitMs, int? memoryLimitMb) {
    final run = data['run'] as Map<String, dynamic>?;
    if (run == null) return null;

    final signal = run['signal'] as String?;
    final stderr = ((run['stderr'] as String?) ?? '').toLowerCase();
    final code = run['code'] as int?;

    if (stderr.contains('bad_alloc') ||
        stderr.contains('cannot allocate') ||
        stderr.contains('out of memory') ||
        stderr.contains('memoryerror') ||
        stderr.contains('memory allocation failed')) {
      return '\u{1F4BE} Memory Limit Exceeded${memoryLimitMb != null ? ' ($memoryLimitMb MB)' : ''}';
    }

    if (signal != null) {
      if (signal == 'SIGKILL' || signal == 'SIGXCPU') {
        return '\u23F1 Time Limit Exceeded${timeLimitMs != null ? ' ($timeLimitMs ms)' : ''}';
      }
      if (signal == 'SIGSEGV') {
        return '\u{1F6D1} Runtime Error: Segmentation Fault';
      }
      if (signal == 'SIGFPE') {
        return '\u26A0\uFE0F Runtime Error: Division by Zero';
      }
      if (signal == 'SIGABRT') {
        return '\u{1F6D1} Runtime Error: Aborted';
      }
      return '\u{1F6D1} Runtime Error ($signal)';
    }

    if (code != null && code > 128) {
      final sig = code - 128;
      if (sig == 9) {
        return '\u23F1 Time Limit Exceeded${timeLimitMs != null ? ' ($timeLimitMs ms)' : ''}';
      }
      if (sig == 11) {
        return '\u{1F6D1} Runtime Error: Segmentation Fault';
      }
      if (sig == 8) {
        return '\u26A0\uFE0F Runtime Error: Division by Zero';
      }
      if (sig == 6) {
        return '\u{1F6D1} Runtime Error: Aborted';
      }
      return '\u{1F6D1} Runtime Error (signal $sig)';
    }

    if (stderr.contains('segmentation fault') || stderr.contains('sigsegv')) {
      return '\u{1F6D1} Runtime Error: Segmentation Fault';
    }
    if (stderr.contains('floating point exception')) {
      return '\u26A0\uFE0F Runtime Error: Division by Zero';
    }

    if (code != null && code != 0) {
      return '\u{1F6D1} Runtime Error (exit code $code)';
    }

    return null;
  }

  String _injectFileCapture(
      String normalized, String outputFile, String sourceCode) {
    if (normalized == 'cpp') {
      return '#include <fstream>\n#include <iostream>\nstruct _FilePrinter {\n    ~_FilePrinter() {\n        std::ifstream ifs("$outputFile");\n        if(ifs.good()) {\n            std::cout << std::endl << "---FILE_OUTPUT_BEGIN---" << std::endl;\n            std::cout << ifs.rdbuf();\n            std::cout << std::endl << "---FILE_OUTPUT_END---" << std::endl;\n        }\n    }\n} _file_printer_instance;\n$sourceCode';
    } else if (normalized == 'python') {
      return 'import atexit, os, sys\ndef _print_file():\n    if os.path.exists(\'$outputFile\'):\n        sys.stdout.flush()\n        sys.stderr.flush()\n        print()\n        print("---FILE_OUTPUT_BEGIN---")\n        with open(\'$outputFile\', \'r\') as f:\n            print(f.read(), end="")\n        print()\n        print("---FILE_OUTPUT_END---")\natexit.register(_print_file)\n$sourceCode';
    }
    return sourceCode;
  }

  String _injectInputFile(
      String normalized, String fileName, String content, String sourceCode) {
    final escaped = content
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '');

    if (normalized == 'cpp') {
      return '#include <fstream>\n'
          '#include <string>\n'
          'namespace _bs_ifw {\n'
          '  struct W {\n'
          '    W() {\n'
          '      std::ofstream f("$fileName");\n'
          '      f << "$escaped";\n'
          '      f.close();\n'
          '    }\n'
          '  } _instance;\n'
          '}\n'
          '$sourceCode';
    } else if (normalized == 'python') {
      return 'open("$fileName", "w").write("$escaped")\n$sourceCode';
    }
    return sourceCode;
  }

  String _injectMemoryLimit(
      String normalized, int memoryLimitMb, String sourceCode) {
    if (normalized == 'cpp') {
      return '#include <sys/resource.h>\n'
          '#include <unistd.h>\n'
          '#include <fstream>\n'
          '__attribute__((constructor)) void _bs_init_mem_limit() {\n'
          '  unsigned long vsz_pages = 0;\n'
          '  unsigned long startup_bytes = 0;\n'
          '  std::ifstream ifs("/proc/self/statm");\n'
          '  if (ifs >> vsz_pages) {\n'
          '    startup_bytes = vsz_pages * sysconf(_SC_PAGESIZE);\n'
          '  }\n'
          '  if (startup_bytes == 0) {\n'
          '    startup_bytes = 16ULL * 1024 * 1024;\n'
          '  }\n'
          '  unsigned long limit_bytes = startup_bytes + (${memoryLimitMb}ULL * 1024 * 1024);\n'
          '  struct rlimit rl;\n'
          '  rl.rlim_cur = limit_bytes;\n'
          '  rl.rlim_max = limit_bytes;\n'
          '  setrlimit(RLIMIT_AS, &rl);\n'
          '}\n'
          '$sourceCode';
    } else if (normalized == 'python') {
      return 'import resource, os\n'
          'def _bs_init_mem_limit():\n'
          '    try:\n'
          '        with open("/proc/self/statm", "r") as f:\n'
          '            vsz_pages = int(f.read().split()[0])\n'
          '        startup_bytes = vsz_pages * os.sysconf("SC_PAGE_SIZE")\n'
          '        limit_bytes = startup_bytes + ($memoryLimitMb * 1024 * 1024)\n'
          '        soft, hard = resource.getrlimit(resource.RLIMIT_AS)\n'
          '        resource.setrlimit(resource.RLIMIT_AS, (limit_bytes, hard))\n'
          '    except Exception:\n'
          '        fallback = ($memoryLimitMb + 64) * 1024 * 1024\n'
          '        soft, hard = resource.getrlimit(resource.RLIMIT_AS)\n'
          '        resource.setrlimit(resource.RLIMIT_AS, (fallback, hard))\n'
          '_bs_init_mem_limit()\n'
          '$sourceCode';
    }
    return sourceCode;
  }

  bool _matchOutput(String stdout, String expected, String? outputFile) {
    if (outputFile != null) {
      final match = RegExp(
              '---FILE_OUTPUT_BEGIN---\\s+([\\s\\S]*?)\\s*---FILE_OUTPUT_END---')
          .firstMatch(stdout);
      return match != null && (match.group(1) ?? '').trim() == expected.trim();
    }
    return stdout.trim() == expected.trim();
  }

  Future<List<JudgeResult>> runAllTests({
    required String sourceCode,
    required String language,
    required List<TestCase> tests,
    List<ExerciseFile> files = const [],
    int? timeLimitMs,
    int? memoryLimitMb,
  }) async {
    final results = <JudgeResult>[];
    for (final test in tests) {
      final currentFiles = List<ExerciseFile>.from(files);
      final result = await submitCode(
        sourceCode: sourceCode,
        language: language,
        stdin: test.inputFile != null ? '' : test.input,
        expectedOutput: test.expectedOutput,
        outputFile: test.outputFile,
        inputFile: test.inputFile,
        inputContent: test.inputFile != null ? test.input : null,
        files: currentFiles,
        timeLimitMs: timeLimitMs,
        memoryLimitMb: memoryLimitMb,
      );
      results.add(result);
    }
    return results;
  }
}
