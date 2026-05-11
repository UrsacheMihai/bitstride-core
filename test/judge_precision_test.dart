import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:bitstride_core/services/judge/judge_service.dart';
import 'package:bitstride_core/services/judge/judge_config.dart';

void main() {
  late JudgeService judgeService;
  final List<Map<String, dynamic>> testResults = [];

  setUpAll(() {
    // Configure Judge to use the active local Piston server on port 2001.
    JudgeConfig.setBaseUrl('http://localhost:2001');
    judgeService = JudgeService();
  });

  tearDownAll(() async {
    // Write all results to limit_precision_results.json in the test directory.
    final file = File('test/limit_precision_results.json');
    final encoder = const JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(testResults));
    print('--------------------------------------------------');
    print('SUCCESS: Limit precision results written to:');
    print('${file.absolute.path}');
    print('--------------------------------------------------');
  });

  group('Memory Limit Precision Testing', () {
    
    // --- PYTHON TEST SUITE ---
    group('Python Limits Precision Matrix', () {
      final pythonCases = [
        // Limit: 10MB
        {'limit': 10, 'allocate': 2, 'expectedPass': true},
        {'limit': 10, 'allocate': 8, 'expectedPass': true},
        {'limit': 10, 'allocate': 15, 'expectedPass': false},
        {'limit': 10, 'allocate': 40, 'expectedPass': false},
        // Limit: 32MB
        {'limit': 32, 'allocate': 10, 'expectedPass': true},
        {'limit': 32, 'allocate': 25, 'expectedPass': true},
        {'limit': 32, 'allocate': 50, 'expectedPass': false},
        // Limit: 64MB
        {'limit': 64, 'allocate': 20, 'expectedPass': true},
        {'limit': 64, 'allocate': 50, 'expectedPass': true},
        {'limit': 64, 'allocate': 90, 'expectedPass': false},
      ];

      for (final tc in pythonCases) {
        final limit = tc['limit'] as int;
        final allocate = tc['allocate'] as int;
        final expectedPass = tc['expectedPass'] as bool;

        test('Python: Limit ${limit}MB | Allocate ${allocate}MB (Expect Pass: $expectedPass)', () async {
          // NO TRY-EXCEPT BLOCK: Trigger real uncaught MemoryError
          final sourceCode = '''
# Allocate specific memory using bytearray
data = bytearray($allocate * 1024 * 1024)
print("Allocated successfully:", len(data))
''';

          final result = await judgeService.submitCode(
            sourceCode: sourceCode,
            language: 'python',
            memoryLimitMb: limit,
          );

          final bool actualPass = result.success;
          final isMle = result.error != null && result.error!.contains('Memory Limit Exceeded');

          testResults.add({
            'language': 'python',
            'limitMb': limit,
            'allocatedMb': allocate,
            'expectedPass': expectedPass,
            'actualPass': actualPass,
            'isMle': isMle,
            'output': result.output.trim(),
            'error': result.error,
          });

          // Verify that the judge accurately handles pass/fail boundaries
          if (!expectedPass) {
            expect(actualPass, isFalse, reason: "Allocation of ${allocate}MB should have failed under ${limit}MB limit.");
            expect(isMle, isTrue, reason: "Error should be Memory Limit Exceeded, but got: ${result.error}");
          } else {
            expect(actualPass, isTrue, reason: "Allocation of ${allocate}MB should pass under ${limit}MB limit. Error: ${result.error}");
          }
        });
      }
    });

    // --- C++ TEST SUITE ---
    group('C++ Limits Precision Matrix', () {
      final cppCases = [
        // Limit: 10MB
        {'limit': 10, 'allocate': 2, 'expectedPass': true},
        {'limit': 10, 'allocate': 8, 'expectedPass': true},
        {'limit': 10, 'allocate': 15, 'expectedPass': false},
        {'limit': 10, 'allocate': 30, 'expectedPass': false},
        // Limit: 32MB
        {'limit': 32, 'allocate': 10, 'expectedPass': true},
        {'limit': 32, 'allocate': 25, 'expectedPass': true},
        {'limit': 32, 'allocate': 50, 'expectedPass': false},
        // Limit: 64MB
        {'limit': 64, 'allocate': 20, 'expectedPass': true},
        {'limit': 64, 'allocate': 50, 'expectedPass': true},
        {'limit': 64, 'allocate': 90, 'expectedPass': false},
      ];

      for (final tc in cppCases) {
        final limit = tc['limit'] as int;
        final allocate = tc['allocate'] as int;
        final expectedPass = tc['expectedPass'] as bool;

        test('C++: Limit ${limit}MB | Allocate ${allocate}MB (Expect Pass: $expectedPass)', () async {
          // NO TRY-CATCH BLOCK: Trigger real uncaught std::bad_alloc
          final sourceCode = '''
#include <iostream>
#include <vector>
int main() {
    std::vector<char> large_vec(${allocate}ULL * 1024 * 1024, 0);
    std::cout << "Allocated size: " << large_vec.size() << std::endl;
    return 0;
}
''';

          final result = await judgeService.submitCode(
            sourceCode: sourceCode,
            language: 'cpp',
            memoryLimitMb: limit,
          );

          final bool actualPass = result.success;
          final isMle = result.error != null && result.error!.contains('Memory Limit Exceeded');

          testResults.add({
            'language': 'cpp',
            'limitMb': limit,
            'allocatedMb': allocate,
            'expectedPass': expectedPass,
            'actualPass': actualPass,
            'isMle': isMle,
            'output': result.output.trim(),
            'error': result.error,
          });

          // Verify that the judge accurately handles pass/fail boundaries
          if (!expectedPass) {
            expect(actualPass, isFalse, reason: "Allocation of ${allocate}MB should have failed under ${limit}MB limit.");
            expect(isMle, isTrue, reason: "Error should be Memory Limit Exceeded, but got: ${result.error}");
          } else {
            expect(actualPass, isTrue, reason: "Allocation of ${allocate}MB should pass under ${limit}MB limit. Error: ${result.error}");
          }
        });
      }
    });

  });
}
