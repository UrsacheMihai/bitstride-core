// Provide the layout and logic for completing a lesson.

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/exercise/exercise.dart';
import '../../providers/app/app_state.dart';
import '../../services/judge/judge_service.dart';
import '../../widgets/practice/code_editor.dart';
import '../../widgets/common/mascot_display.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass/glass_app_bar.dart';
import 'package:bitstride_core/l10n/app_localizations.dart';
import '../../widgets/lesson/test_result_widgets.dart';
import '../../widgets/lesson/xp_award_badge.dart';
import '../../widgets/lesson/lesson_components.dart';

// Store the completion result data returned when a course lesson finishes.
class LessonCompletionResult {
  final int calculatedXp;
  final int awardedXp;
  final int totalQuizzes;
  final int correctQuizzes;
  final int totalTests;
  final int passedTests;
  final bool isPerfect;
  final String successMascot;

  const LessonCompletionResult({
    required this.calculatedXp,
    required this.awardedXp,
    required this.totalQuizzes,
    required this.correctQuizzes,
    required this.totalTests,
    required this.passedTests,
    required this.isPerfect,
    required this.successMascot,
  });
}

// Render layout and manage state for Lesson Screen.
class LessonScreen extends StatefulWidget {
  final Exercise exercise;
  final String language;
  final bool isChallenge;
  final String? difficulty;

  const LessonScreen({
    super.key,
    required this.exercise,
    required this.language,
    this.isChallenge = false,
    this.difficulty,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

// Manage state and provide providers for Lesson Screen State.
class _LessonScreenState extends State<LessonScreen> {
  final JudgeService _judge = JudgeService();
  late String _currentLanguage;
  String _currentCode = '';
  String? _codeCpp;
  String? _codePython;
  bool _isSubmitting = false;
  String? _resultMessage;
  bool? _lastSuccess;
  List<TestResultInfo> _testResults = [];
  bool _problemExpanded = true;
  int _awardedXp = 0;
  // Track selected options for quizzes as list to support multiple-choice.
  Map<int, List<int>> _selectedOptions = {};
  // Track if code has been submitted.
  bool _codeSubmittedOnce = false;

  bool get _hasContent => widget.exercise.contentBlocks.isNotEmpty;

  bool get _hasCode =>
      widget.exercise.tests.isNotEmpty ||
      widget.exercise.initialCode.trim().isNotEmpty ||
      (widget.exercise.initialCodeCpp?.trim().isNotEmpty ?? false) ||
      (widget.exercise.initialCodePython?.trim().isNotEmpty ?? false);

  bool get _isTheoryOnly => _hasContent && !_hasCode;

  bool get _isMixed => _hasContent && _hasCode;

  // Get localized lesson type badge text.
  String _getLessonTypeLabel(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (_isMixed) return l.mixedBadge;
    if (_isTheoryOnly) return l.theoryBadge;
    return l.codeBadge;
  }

  Color get _lessonTypeColor {
    if (_isMixed) return AppTheme.xpGold;
    if (_isTheoryOnly) return AppTheme.accentPurple;
    return AppTheme.primaryCyan;
  }

  IconData get _lessonTypeIcon {
    if (_isMixed) return Icons.auto_awesome_rounded;
    if (_isTheoryOnly) return Icons.menu_book_rounded;
    return Icons.code_rounded;
  }

  // Initialize lesson state and quiz selections.
  @override
  void initState() {
    super.initState();
    final hasCpp = widget.exercise.initialCodeCpp != null;
    final hasPython = widget.exercise.initialCodePython != null;
    final isDualLanguage = widget.isChallenge || (hasCpp && hasPython);

    if (!isDualLanguage) {
      if (hasCpp && !hasPython) {
        _currentLanguage = 'cpp';
      } else if (hasPython && !hasCpp) {
        _currentLanguage = 'python';
      } else {
        _currentLanguage = widget.language;
      }
    } else {
      _currentLanguage = widget.language;
    }

    _codeCpp = widget.exercise.initialCodeCpp ?? widget.exercise.initialCode;
    _codePython = widget.exercise.initialCodePython ?? widget.exercise.initialCode;
    _currentCode = (_currentLanguage == 'cpp' ? _codeCpp : _codePython) ?? '';

    // Seed initial empty selection lists for all quiz blocks.
    for (int i = 0; i < widget.exercise.contentBlocks.length; i++) {
      if (widget.exercise.contentBlocks[i].type == 'quiz') {
        _selectedOptions[i] = [];
      }
    }
  }

  // Handle language switching.
  void _switchLanguage(String newLang) {
    if (_currentLanguage == newLang) return;
    if (_currentLanguage == 'cpp') {
      _codeCpp = _currentCode;
    } else if (_currentLanguage == 'python') {
      _codePython = _currentCode;
    }
    setState(() {
      _currentLanguage = newLang;
      _currentCode = (newLang == 'cpp' ? _codeCpp : _codePython) ?? '';
      _resultMessage = null;
      _lastSuccess = null;
      _testResults = [];
    });
  }

  // Run user code and update execution status.
  Future<void> _submitCode() async {
    setState(() {
      _isSubmitting = true;
      _resultMessage = null;
      _lastSuccess = null;
      _testResults = [];
      _awardedXp = 0;
    });
    final results = await _judge.runAllTests(
      sourceCode: _currentCode,
      language: _currentLanguage,
      tests: widget.exercise.tests,
      files: widget.exercise.files,
      timeLimitMs: widget.exercise.timeLimitMs,
      memoryLimitMb: widget.exercise.memoryLimitMb,
    );
    int passed = 0;
    final total = results.length;
    final testInfos = <TestResultInfo>[];
    for (int i = 0; i < results.length; i++) {
      final r = results[i];
      final test = widget.exercise.tests[i];
      testInfos.add(TestResultInfo(
        index: i + 1,
        passed: r.success,
        isHidden: test.isHidden,
        output: r.output,
        expected: test.expectedOutput,
        error: r.error ?? r.compileError,
      ));
      if (r.success) {
        passed++;
      }
    }
    final percentage = total > 0 ? (passed * 100 ~/ total) : 0;
    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _lastSuccess = passed == total;
        _testResults = testInfos;
        _codeSubmittedOnce = true;
        // Set localized test results outcome message.
        if (mounted) {
          _resultMessage = AppLocalizations.of(context)!.testsPassed(passed, total, percentage);
        } else {
          _resultMessage = '$passed / $total tests passed ($percentage%)';
        }
      });
      // Automatically complete the challenge when all tests pass.
      if (widget.isChallenge && passed == total && total > 0) {
        await _finishLesson();
      }
    }
  }

  // Get current mascot asset according to execution outcome.
  String get _mascotAsset {
    if (_isSubmitting) return 'thinking-hard-e507f346-360.webm';
    if (_lastSuccess == null) return 'reading-a-book-f50abbdd-360.webm';
    if (_lastSuccess!) {
      return _awardedXp > 0
          ? 'happy-dance-138e71c9-360.webm'
          : 'thumbs-up-4b8ec7e7-360.webm';
    }
    final passedCount = _testResults.where((t) => t.passed).length;
    final total = _testResults.length;
    if (total > 0 && passedCount / total > 0.5) {
      return 'adjusting-glasses-2b006977-360.webm';
    }
    return 'looking-through-magnifier-661ddc92-360.webm';
  }

  // Check if all quizzes in the lesson are answered.
  bool get _allQuizzesAnswered {
    for (int i = 0; i < widget.exercise.contentBlocks.length; i++) {
      if (widget.exercise.contentBlocks[i].type == 'quiz') {
        // Consider answered if at least one option is selected.
        if (_selectedOptions[i] == null || _selectedOptions[i]!.isEmpty) return false;
      }
    }
    return true;
  }

  // Calculate total quiz count.
  int get _totalQuizzes {
    return widget.exercise.contentBlocks.where((b) => b.type == 'quiz').length;
  }

  // Calculate correct quiz count supporting both single and multiple-choice.
  int get _correctQuizzes {
    int correct = 0;
    for (int i = 0; i < widget.exercise.contentBlocks.length; i++) {
      final block = widget.exercise.contentBlocks[i];
      if (block.type == 'quiz') {
        final quiz = QuizData.parse(block.content);
        if (quiz != null) {
          final selected = _selectedOptions[i] ?? [];
          if (quiz.isMultipleChoice) {
            // Validate all correct indices are selected and no extras are selected.
            final sortedSelected = List<int>.from(selected)..sort();
            final sortedCorrect = List<int>.from(quiz.correctIndices)..sort();
            if (sortedSelected.join(',') == sortedCorrect.join(',')) correct++;
          } else {
            // Validate single selection matches the correct index.
            if (selected.isNotEmpty && selected.first == quiz.correctIndex) correct++;
          }
        }
      }
    }
    return correct;
  }

  // Calculate total test count.
  int get _totalTests => widget.exercise.tests.length;

  // Calculate passed test count.
  int get _passedTests => _testResults.where((t) => t.passed).length;

  // Calculate proportional XP reward based on quiz and test completion.
  int _calculateXp() {
    final totalQ = _totalQuizzes;
    final totalT = _totalTests;

    if (_isTheoryOnly) {
      if (totalQ == 0) {
        return 10;
      } else {
        final correctQ = _correctQuizzes;
        return ((correctQ / totalQ) * 15).round();
      }
    } else if (_isMixed) {
      final correctQ = _correctQuizzes;
      final quizPart = totalQ == 0 ? 0 : ((correctQ / totalQ) * 10).round();
      final passedT = _passedTests;
      final codePart = totalT == 0 ? 0 : ((passedT / totalT) * 15).round();
      return quizPart + codePart;
    } else {
      final passedT = _passedTests;
      final maxXP = widget.isChallenge ? 25 : 20;
      return totalT == 0 ? maxXP : ((passedT / totalT) * maxXP).round();
    }
  }

  // Evaluate quiz and code correctness and submit progress.
  Future<void> _finishLesson() async {
    if (!mounted) return;
    final appState = context.read<AppState>();
    final totalQ = _totalQuizzes;
    final totalT = _totalTests;
    final correctQ = _correctQuizzes;
    final passedT = _passedTests;
    final calculatedXp = _calculateXp();
    final bool isPerfect = (totalQ == 0 || correctQ == totalQ) && (totalT == 0 || passedT == totalT);

    int awarded = 0;
    if (widget.isChallenge) {
      awarded = await appState.completeChallenge(
        widget.exercise.id,
        calculatedXp,
        language: _currentLanguage,
        perfect: isPerfect,
      );
    } else {
      awarded = await appState.submitExerciseRun(
        widget.exercise.id,
        calculatedXp,
        true,
        language: _currentLanguage,
        perfect: isPerfect,
      );
    }

    setState(() {
      _awardedXp = awarded;
    });

    if (mounted) {
      if (widget.isChallenge) {
        // Show completion dialog popup for challenges.
        _showCompletionDialog(context, calculatedXp, awarded);
      } else {
        // Pop lesson screen and return result to learn_screen for overlay display.
        Navigator.of(context).pop(LessonCompletionResult(
          calculatedXp: calculatedXp,
          awardedXp: awarded,
          totalQuizzes: totalQ,
          correctQuizzes: correctQ,
          totalTests: totalT,
          passedTests: passedT,
          isPerfect: isPerfect,
          successMascot: widget.exercise.successMascot,
        ));
      }
    }
  }

  // Render completion modal dialog with score breakdown.
  void _showCompletionDialog(BuildContext context, int calculatedXp, int awardedXp) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalQ = _totalQuizzes;
    final totalT = _totalTests;
    final correctQ = _correctQuizzes;
    final passedT = _passedTests;
    final bool isPerfect = (totalQ == 0 || correctQ == totalQ) && (totalT == 0 || passedT == totalT);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? AppTheme.darkBorder : Colors.grey.withOpacity(0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MascotDisplay(
                gifAsset: isPerfect ? widget.exercise.successMascot : 'thumbs-up-4b8ec7e7-360.webm',
                size: 100,
              ),
              const SizedBox(height: 16),
              Text(
                isPerfect ? l.perfectScore : l.lessonFinished,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  ),
                ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 16),
              if (_isTheoryOnly) ...[
                if (totalQ == 0)
                  _buildBreakdownRow(l.theoryRead, '100%', '+10 XP')
                else
                  _buildBreakdownRow(l.quizScore, '$correctQ / $totalQ', '+$calculatedXp XP')
              ] else if (_isMixed) ...[
                _buildBreakdownRow(l.quizScore, '$correctQ / $totalQ', '+${totalQ == 0 ? 0 : ((correctQ / totalQ) * 10).round()} XP'),
                _buildBreakdownRow(l.codeTests, '$passedT / $totalT', '+${totalT == 0 ? 0 : ((passedT / totalT) * 15).round()} XP'),
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                _buildBreakdownRow(l.totalXpScore, '', '+$calculatedXp XP'),
              ] else ...[
                _buildBreakdownRow(l.codeTests, '$passedT / $totalT', '+$calculatedXp XP'),
              ],
              const SizedBox(height: 16),
              if (awardedXp > 0)
                Text(
                  l.gainedXp(awardedXp),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.xpGold,
                  ),
                )
              else
                Text(
                  l.redoNoXp,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    l.continueBtn,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}