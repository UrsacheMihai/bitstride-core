import 'package:flutter_test/flutter_test.dart';
import 'package:bitstride_core/services/judge/judge_service.dart';
import 'package:bitstride_core/services/judge/judge_config.dart';

void main() {
  late JudgeService judgeService;

  setUpAll(() {
    // Explicitly configure Judge to use the active local Piston server on port 2001
    JudgeConfig.setBaseUrl('http://localhost:2001');
    judgeService = JudgeService();
  });

  group('Piston Runtimes - Basic Compilations and Execution', () {
    test('Python: compiles and prints Hello World', () async {
      final result = await judgeService.submitCode(
        sourceCode: "print('Hello from Python!')",
        language: 'python',
      );

      expect(result.success, isTrue, reason: "Error: ${result.error}");
      expect(result.output.trim(), equals('Hello from Python!'));
      expect(result.compileError, isNull);
    });

    test('C++: compiles and prints Hello World', () async {
      final result = await judgeService.submitCode(
        sourceCode: '''
#include <iostream>
int main() {
    std::cout << "Hello from C++!" << std::endl;
    return 0;
}
''',
        language: 'cpp',
      );

      expect(result.success, isTrue, reason: "Error: ${result.error}");
      expect(result.output.trim(), equals('Hello from C++!'));
      expect(result.compileError, isNull);
    });
  });

  group('Piston Runtimes - Time Limit Exceeded (TLE) Tests', () {
    test('Python: TLE is correctly triggered and handled', () async {
      final result = await judgeService.submitCode(
        sourceCode: '''
import time
# Sleep/loop for 5 seconds which exceeds the 1-second limit
time.sleep(5)
print('This should not print!')
''',
        language: 'python',
        timeLimitMs: 1000,
      );

      expect(result.success, isFalse);
      expect(result.error, contains('Time Limit Exceeded'));
    });

    test('C++: TLE is correctly triggered and handled', () async {
      final result = await judgeService.submitCode(
        sourceCode: '''
#include <iostream>
#include <chrono>
#include <thread>
int main() {
    // Infinite loop or long sleep to exceed the 1-second limit
    std::this_thread::sleep_for(std::chrono::seconds(5));
    std::cout << "This should not print!" << std::endl;
    return 0;
}
''',
        language: 'cpp',
        timeLimitMs: 1000,
      );

      expect(result.success, isFalse);
      expect(result.error, contains('Time Limit Exceeded'));
    });
  });

  group('Piston Runtimes - Memory Limit Exceeded (MLE) Tests', () {
    test('Python: MLE is correctly triggered and handled', () async {
      final result = await judgeService.submitCode(
        sourceCode: '''
# Allocate 100MB of memory which exceeds the 10MB limit (with 64MB buffer)
data = bytearray(100 * 1024 * 1024)
print('Allocated:', len(data))
''',
        language: 'python',
        memoryLimitMb: 10,
      );

      expect(result.success, isFalse);
      expect(result.error, contains('Memory Limit Exceeded'));
    });

    test('C++: MLE is correctly triggered and handled', () async {
      final result = await judgeService.submitCode(
        sourceCode: '''
#include <iostream>
#include <vector>
int main() {
    // Allocate 30MB which exceeds the 10MB limit
    std::vector<char> large_vec(30 * 1024 * 1024, 0);
    std::cout << "Allocated size: " << large_vec.size() << std::endl;
    return 0;
}
''',
        language: 'cpp',
        memoryLimitMb: 10,
      );

      expect(result.success, isFalse);
      expect(result.error, contains('Memory Limit Exceeded'));
    });
  });
}
