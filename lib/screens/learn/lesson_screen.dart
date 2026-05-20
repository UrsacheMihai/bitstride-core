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

  // Render individual breakdown rows inside the completion dialog.
  Widget _buildBreakdownRow(String label, String ratio, String xp) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              if (ratio.isNotEmpty) ...[
                Text(
                  ratio,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Text(
                xp,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryCyan,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Render unified bottom completion bar.
  Widget _buildBottomCompletionBar(BuildContext context, bool isDark) {
    final l = AppLocalizations.of(context)!;
    final isCompleted = context.read<AppState>().isExerciseCompleted(widget.exercise.id);
    final allQuizzesDone = _allQuizzesAnswered;
    final codeDone = !_hasCode || _codeSubmittedOnce;
    final canFinish = allQuizzesDone && codeDone;

    String? statusText;
    if (!allQuizzesDone && _totalQuizzes > 0) {
      statusText = l.answerAllQuizzes;
    } else if (!codeDone && _hasCode) {
      statusText = l.runCodeOnce;
    }

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            MascotDisplay(
              gifAsset: 'teach-1aaf24fb-360.webm',
              size: 48,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: (isCompleted || !canFinish || _isSubmitting) ? null : _finishLesson,
                      icon: Icon(
                        isCompleted
                          ? Icons.check_circle_rounded
                          : Icons.done_all_rounded,
                        size: 20,
                      ),
                      label: Text(
                        isCompleted ? l.done : l.finishLesson,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  if (statusText != null && !isCompleted) ...[
                    const SizedBox(height: 4),
                    Center(
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (_awardedXp > 0) ...[
              const SizedBox(width: 12),
              XpAwardBadge(xp: _awardedXp),
            ],
          ],
        ),
      ),
    );
  }

  // Render main screen layout with tabs and footers.
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visibleTests = widget.exercise.tests
        .where((t) => !t.isHidden && t.input.isNotEmpty)
        .toList();
    final exampleTest = visibleTests.isNotEmpty ? visibleTests.first : null;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

    if (_isTheoryOnly) {
      return Scaffold(
        appBar: GlassAppBar(
          title: Text(widget.exercise.title),
          actions: [
            // Render localized lesson type badge in app bar.
            LessonTypeBadge(
              label: _getLessonTypeLabel(context),
              icon: _lessonTypeIcon,
              color: _lessonTypeColor,
            ),
          ],
        ),
        body: Container(
          decoration: AppTheme.meshBackground(isDark: isDark),
          child: Column(
            children: [
              Expanded(
                child: LearnTab(
                  blocks: widget.exercise.contentBlocks,
                  isDark: isDark,
                  selectedOptions: _selectedOptions,
                  onOptionSelected: (blockIndex, optionIndex) {
                    setState(() {
                      // Toggle option for multiple-choice, replace for single-choice.
                      final block = widget.exercise.contentBlocks[blockIndex];
                      final quiz = block.type == 'quiz' ? QuizData.parse(block.content) : null;
                      final current = List<int>.from(_selectedOptions[blockIndex] ?? []);
                      if (quiz != null && quiz.isMultipleChoice) {
                        if (current.contains(optionIndex)) {
                          current.remove(optionIndex);
                        } else {
                          current.add(optionIndex);
                        }
                        _selectedOptions[blockIndex] = current;
                      } else {
                        _selectedOptions[blockIndex] = [optionIndex];
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: widget.isChallenge ? null : _buildBottomCompletionBar(context, isDark),
      );
    }

    final bool hasCpp = widget.exercise.initialCodeCpp != null;
    final bool hasPython = widget.exercise.initialCodePython != null;

    final bool showLangSwitcher = widget.isChallenge || (hasCpp && hasPython);

    final List<Widget> appBarActions = [
      // Render localized lesson type badge in app bar actions.
      LessonTypeBadge(
        label: _getLessonTypeLabel(context),
        icon: _lessonTypeIcon,
        color: _lessonTypeColor,
      ),
      if (showLangSwitcher)
        Padding(
          padding: const EdgeInsets.only(right: 12.0, top: 10.0, bottom: 10.0),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                LanguageTab(
                  title: 'C++',
                  isSelected: _currentLanguage == 'cpp',
                  isAvailable: true,
                  onTap: () => _switchLanguage('cpp'),
                ),
                LanguageTab(
                  title: 'Python',
                  isSelected: _currentLanguage == 'python',
                  isAvailable: true,
                  onTap: () => _switchLanguage('python'),
                ),
              ],
            ),
          ),
        ),
    ];

    if (_isMixed) {
      final mixedScaffold = Scaffold(
        appBar: GlassAppBar(
          title: Text(widget.exercise.title),
          actions: appBarActions,
        ),
        body: Container(
          decoration: AppTheme.meshBackground(isDark: isDark),
          child: SafeArea(
            top: true,
            child: Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: TabBar(
                    // Render localized tabs for theory and code views.
                    tabs: [
                      Tab(icon: const Icon(Icons.menu_book_rounded), text: AppLocalizations.of(context)!.learn),
                      Tab(icon: const Icon(Icons.code_rounded), text: AppLocalizations.of(context)!.codeBadge),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      LearnTab(
                        blocks: widget.exercise.contentBlocks,
                        isDark: isDark,
                        selectedOptions: _selectedOptions,
                        onOptionSelected: (blockIndex, optionIndex) {
                          setState(() {
                            // Toggle option for multiple-choice, replace for single-choice.
                            final block = widget.exercise.contentBlocks[blockIndex];
                            final quiz = block.type == 'quiz' ? QuizData.parse(block.content) : null;
                            final current = List<int>.from(_selectedOptions[blockIndex] ?? []);
                            if (quiz != null && quiz.isMultipleChoice) {
                              if (current.contains(optionIndex)) {
                                current.remove(optionIndex);
                              } else {
                                current.add(optionIndex);
                              }
                              _selectedOptions[blockIndex] = current;
                            } else {
                              _selectedOptions[blockIndex] = [optionIndex];
                            }
                          });
                        },
                      ),
                      isWide
                          ? _buildWideExerciseBody(isDark, exampleTest)
                          : _buildExerciseBody(isDark, exampleTest),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: widget.isChallenge ? null : _buildBottomCompletionBar(context, isDark),
      );
      return DefaultTabController(length: 2, child: mixedScaffold);
    }

    final scaffold = Scaffold(
      appBar: GlassAppBar(
        title: Text(widget.exercise.title),
        actions: appBarActions,
      ),
      body: Container(
        decoration: AppTheme.meshBackground(isDark: isDark),
        child: SafeArea(
          top: true,
          child: isWide
              ? _buildWideExerciseBody(isDark, exampleTest)
              : _buildExerciseBody(isDark, exampleTest),
        ),
      ),
      bottomNavigationBar: widget.isChallenge ? null : _buildBottomCompletionBar(context, isDark),
    );
    return scaffold;
  }

  Widget _buildWideExerciseBody(bool isDark, dynamic exampleTest) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProblemCard(isDark, exampleTest, expanded: true),
                if (_lastSuccess != null || _isSubmitting) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: MascotDisplay(gifAsset: _mascotAsset, size: 100),
                  ),
                ],
                if (_awardedXp > 0) ...[
                  const SizedBox(height: 12),
                  XpAwardBadge(xp: _awardedXp),
                ],
                if (_resultMessage != null) ...[
                  const SizedBox(height: 16),
                  ResultPanel(
                    success: _lastSuccess!,
                    message: _resultMessage!,
                    testResults: _testResults,
                  ),
                ],
              ],
            ),
          ),
        ),
        Container(
          width: 1,
          color: isDark ? AppTheme.darkBorder : Colors.grey.withOpacity(0.15),
        ),
        Expanded(
          flex: 5,
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: CodeEditor(
                        key: ValueKey(_currentLanguage),
                        initialCode: _currentCode,
                        language: _currentLanguage,
                        onChanged: (code) => _currentCode = code,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _buildSubmitButton(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseBody(bool isDark, dynamic exampleTest) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProblemAccordion(isDark, exampleTest),
          const SizedBox(height: 16),
          if (_lastSuccess != null || _isSubmitting) ...[
            Center(
              child: MascotDisplay(gifAsset: _mascotAsset, size: 80),
            ),
            const SizedBox(height: 8),
          ],
          if (_awardedXp > 0) ...[
            XpAwardBadge(xp: _awardedXp),
            const SizedBox(height: 12),
          ],
          Container(
            height: 380,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CodeEditor(
                key: ValueKey(_currentLanguage),
                initialCode: _currentCode,
                language: _currentLanguage,
                onChanged: (code) => _currentCode = code,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSubmitButton(),
          if (_resultMessage != null) ...[
            const SizedBox(height: 20),
            ResultPanel(
              success: _lastSuccess!,
              message: _resultMessage!,
              testResults: _testResults,
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _isSubmitting ? null : _submitCode,
        icon: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.play_arrow_rounded, size: 24),
        label: Text(
          _isSubmitting
              ? AppLocalizations.of(context)!.running
              : AppLocalizations.of(context)!.submitCode,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _buildProblemCard(bool isDark, dynamic exampleTest,
      {bool expanded = true}) {
    return Container(
      decoration: AppTheme.glassCard(isDark: isDark, borderRadius: 18),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.description_outlined,
                    color: Theme.of(context).colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.problemDescription,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          MarkdownBody(
            data: widget.exercise.description,
            styleSheet: _markdownStyle(context),
            onTapLink: (text, href, title) {
              if (href != null)
                launchUrl(Uri.parse(href),
                    mode: LaunchMode.externalApplication);
            },
          ),
          ..._buildConstraintsRow(isDark),
          ..._buildFileChips(isDark),
          ..._buildExampleSection(exampleTest),
        ],
      ),
    );
  }

  Widget _buildProblemAccordion(bool isDark, dynamic exampleTest) {
    return Container(
      margin: EdgeInsets.zero,
      decoration: AppTheme.glassCard(isDark: isDark, borderRadius: 18),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: ExpansionTile(
          initiallyExpanded: _problemExpanded,
          onExpansionChanged: (expanded) {
            setState(() => _problemExpanded = expanded);
          },
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          iconColor: Theme.of(context).colorScheme.primary,
          collapsedIconColor: isDark ? Colors.grey[400] : Colors.grey[700],
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.description_outlined,
                    color: Theme.of(context).colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.problemDescription,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ],
          ),
          childrenPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 16),
            MarkdownBody(
              data: widget.exercise.description,
              styleSheet: _markdownStyle(context),
              onTapLink: (text, href, title) {
                if (href != null)
                  launchUrl(Uri.parse(href),
                      mode: LaunchMode.externalApplication);
              },
            ),
            ..._buildConstraintsRow(isDark),
            ..._buildFileChips(isDark),
            ..._buildExampleSection(exampleTest),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildConstraintsRow(bool isDark) {
    final mem = widget.exercise.memoryLimitMb;
    final time = widget.exercise.timeLimitMs;
    if (mem == null && time == null) return [];
    return [
      const SizedBox(height: 16),
      Wrap(
        spacing: 10,
        runSpacing: 8,
        children: [
          if (time != null)
            ConstraintChip(
              icon: Icons.timer_outlined,
              label: '${time}ms',
              color: AppTheme.primaryCyan,
              isDark: isDark,
            ),
          if (mem != null)
            ConstraintChip(
              icon: Icons.memory_rounded,
              label: '$mem MB',
              color: AppTheme.accentPurple,
              isDark: isDark,
            ),
        ],
      ),
    ];
  }

  List<Widget> _buildFileChips(bool isDark) {
    if (widget.exercise.files.isEmpty) return [];
    return [
      const SizedBox(height: 20),
      Row(
        children: [
          Icon(Icons.folder_open_rounded, size: 16, color: Colors.grey[500]),
          const SizedBox(width: 6),
          Text(AppLocalizations.of(context)!.providedFiles,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 10,
        runSpacing: 8,
        children: widget.exercise.files
            .map((f) => ActionChip(
                  elevation: 0,
                  backgroundColor: isDark
                      ? AppTheme.darkCard
                      : Colors.grey.withOpacity(0.06),
                  side: BorderSide(
                      color: isDark
                          ? AppTheme.darkBorder
                          : Colors.grey.withOpacity(0.15)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  avatar: Icon(Icons.insert_drive_file_rounded,
                      size: 16, color: Theme.of(context).colorScheme.primary),
                  label: Text(f.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                          fontSize: 13)),
                  onPressed: () => _showFileContentDialog(context, f, isDark),
                ))
            .toList(),
      ),
    ];
  }

  List<Widget> _buildExampleSection(dynamic exampleTest) {
    if (exampleTest == null) return [];
    return [
      const SizedBox(height: 20),
      Row(
        children: [
          Icon(Icons.lightbulb_outline_rounded,
              size: 16, color: Colors.amber[700]),
          const SizedBox(width: 6),
          Text(AppLocalizations.of(context)!.example,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
      const SizedBox(height: 10),
      ExampleBlock(
          label: AppLocalizations.of(context)!.input,
          value: exampleTest.input.trim()),
      const SizedBox(height: 6),
      ExampleBlock(
          label: AppLocalizations.of(context)!.output,
          value: exampleTest.expectedOutput.trim()),
    ];
  }

  void _showFileContentDialog(
      BuildContext context, ExerciseFile file, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isDark ? AppTheme.darkBorder : Colors.grey.withOpacity(0.15),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.file_present_rounded,
                      color: Theme.of(context).colorScheme.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      file.name,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                constraints: const BoxConstraints(maxHeight: 400),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E1E1E)
                      : const Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                  ),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    file.content,
                    style: const TextStyle(
                        fontFamily: 'monospace', fontSize: 13, height: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  MarkdownStyleSheet _markdownStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MarkdownStyleSheet(
      p: const TextStyle(fontSize: 14, height: 1.6),
      strong: const TextStyle(
          fontSize: 14, height: 1.6, fontWeight: FontWeight.w700),
      em: const TextStyle(
          fontSize: 14, height: 1.6, fontStyle: FontStyle.italic),
      code: TextStyle(
        fontFamily: 'monospace',
        fontSize: 12,
        backgroundColor:
            isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0),
      ),
      codeblockDecoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
        ),
      ),
      a: TextStyle(
        color: AppTheme.primaryCyan,
        fontWeight: FontWeight.w600,
        decoration: TextDecoration.underline,
        decorationColor: AppTheme.primaryCyan.withOpacity(0.4),
      ),
      listBullet: const TextStyle(fontSize: 14, height: 1.6),
    );
  }
}
