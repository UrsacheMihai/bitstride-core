import 'package:flutter/material.dart';
import 'package:bitstride_core/l10n/app_localizations.dart';
import '../../theme/app_theme.dart';

// Store the result data for a single test run, including stdout, stderr, and success status.
class TestResultInfo {
  final int index;
  final bool passed;
  final bool isHidden;
  final String output;
  final String expected;
  final String? error;

  TestResultInfo({
    required this.index,
    required this.passed,
    required this.isHidden,
    required this.output,
    required this.expected,
    this.error,
  });
}

// Render the test result panel with pass/fail status and actual output.
class ResultPanel extends StatelessWidget {
  final bool success;
  final String message;
  final List<TestResultInfo> testResults;

  const ResultPanel({
    super.key,
    required this.success,
    required this.message,
    required this.testResults,
  });

  @override
  Widget build(BuildContext context) {
    final color = success ? AppTheme.successGreen : AppTheme.errorRed;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                success ? Icons.check_circle_rounded : Icons.error_rounded,
                color: color,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          if (testResults.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...testResults.map((t) => TestRow(info: t)),
          ],
        ],
      ),
    );
  }
}

// Provide interface component for Test Row.
class TestRow extends StatelessWidget {
  final TestResultInfo info;

  const TestRow({super.key, required this.info});

  bool get _isRuntimeVerdict {
    final e = info.error;
    if (e == null) return false;
    return e.contains('Time Limit Exceeded') ||
        e.contains('Memory Limit Exceeded') ||
        e.contains('Runtime Error') ||
        e.contains('Segmentation Fault') ||
        e.contains('Division by Zero');
  }

  @override
  Widget build(BuildContext context) {
    final color = info.passed ? AppTheme.successGreen : AppTheme.errorRed;
    final hasError = info.error != null && info.error!.isNotEmpty;
    final isVerdict = _isRuntimeVerdict;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                info.passed ? Icons.check_rounded : Icons.close_rounded,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                // Set localized test index labels.
                info.isHidden
                    ? AppLocalizations.of(context)!.testHidden(info.index)
                    : AppLocalizations.of(context)!.testIndex(info.index),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          if (!info.passed && hasError && isVerdict)
            Padding(
              padding: const EdgeInsets.only(left: 22, top: 5),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFF9800).withOpacity(0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _iconForError(info.error!),
                      color: const Color(0xFFE65100),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        info.error!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE65100),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (!info.isHidden && !info.passed && hasError && !isVerdict)
            Padding(
              padding: const EdgeInsets.only(left: 22, top: 3),
              child: Text(
                info.error!,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: AppTheme.errorRed,
                ),
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (!info.isHidden && !info.passed && !hasError)
            Padding(
              padding: const EdgeInsets.only(left: 22, top: 3),
              child: Text(
                // Set localized expected/got outcome comparison.
                AppLocalizations.of(context)!.expectedAndGot(info.expected.trim(), info.output.trim()),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  IconData _iconForError(String error) {
    if (error.contains('Time Limit')) return Icons.timer_off_rounded;
    if (error.contains('Memory Limit')) return Icons.memory_rounded;
    if (error.contains('Segmentation')) return Icons.dangerous_rounded;
    if (error.contains('Division')) return Icons.warning_amber_rounded;
    return Icons.error_outline_rounded;
  }
}
