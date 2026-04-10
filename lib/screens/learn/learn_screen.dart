import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app/app_state.dart';
import '../../theme/app_theme.dart';
import '../../models/exercise/exercise.dart';
import '../../widgets/common/animated_list_item.dart';
import '../../widgets/common/page_transitions.dart';
import '../../widgets/learn/course_map_painter.dart';
import '../../widgets/common/mascot_display.dart';
import './lesson_screen.dart';
import 'package:bitstride_core/l10n/app_localizations.dart';

// Render layout and manage state for Learn Screen.
class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

// Manage state and provide providers for Learn Screen State.
class _LearnScreenState extends State<LearnScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _showList = false;
  late AnimationController _pathAnimController;
// Store the completion result data used for the overlay display after a course lesson finishes.
  LessonCompletionResult? _activeCompletionResult;

  @override
  void initState() {
    super.initState();
    _pathAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _pathAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final courses = appState.courses;
    if (courses.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noCourses));
    }
    if (_selectedIndex >= courses.length) _selectedIndex = 0;
    final selectedCourse = courses[_selectedIndex];

    int activeIndex = 0;
    bool allCompleted = true;
    for (int i = 0; i < selectedCourse.lessons.length; i++) {
      if (!appState.isExerciseCompleted(selectedCourse.lessons[i].id)) {
        activeIndex = i;
        allCompleted = false;
        break;
      }
    }
    if (allCompleted && selectedCourse.lessons.isNotEmpty) {
      activeIndex = selectedCourse.lessons.length - 1;
    }

    final List<bool> completionStatuses = selectedCourse.lessons
        .map((l) => appState.isExerciseCompleted(l.id))
        .toList();

    final Color langColor = selectedCourse.language == 'cpp'
        ? const Color(0xFF00599C)
        : const Color(0xFF3776AB);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  ...courses.asMap().entries.map((e) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _CourseBanner(
                          course: e.value,
                          isSelected: _selectedIndex == e.key,
                          onTap: () => setState(() => _selectedIndex = e.key),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(width: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        _showList ? Icons.map_rounded : Icons.list_rounded,
                        size: 20,
                        color: isDark ? Colors.white70 : Colors.grey[700],
                      ),
                      tooltip: _showList ? 'Map View' : 'List View',
                      onPressed: () => setState(() => _showList = !_showList),
                      padding: const EdgeInsets.all(10),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _showList
                  ? _buildListView(selectedCourse, completionStatuses, activeIndex,
                      langColor, isDark, allCompleted)
                  : _buildMapView(selectedCourse, completionStatuses, activeIndex,
                      langColor, isDark, allCompleted),
            ),
          ],
        ),
        // Show floating completion overlay over roadmap for course lessons.
        if (_activeCompletionResult != null)
          _buildCompletionOverlay(_activeCompletionResult!, isDark, AppLocalizations.of(context)!),
      ],
    );
  }

  // Render semi-transparent floating card showing course lesson completion details.
  Widget _buildCompletionOverlay(LessonCompletionResult result, bool isDark, AppLocalizations l) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          color: Colors.black.withOpacity(0.45),
          alignment: Alignment.center,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
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
                  color: Colors.black.withOpacity(isDark ? 0.4 : 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MascotDisplay(
                  gifAsset: result.isPerfect ? result.successMascot : 'thumbs-up-4b8ec7e7-360.webm',
                  size: 100,
                ),
                const SizedBox(height: 16),
                Text(
                  result.isPerfect ? l.perfectScore : l.lessonFinished,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 16),
                // Render XP breakdown rows for quizzes and tests.
                if (result.totalQuizzes > 0)
                  _buildOverlayRow(l.quizScore, '${result.correctQuizzes} / ${result.totalQuizzes}',
                      '+${result.totalQuizzes == 0 ? 0 : ((result.correctQuizzes / result.totalQuizzes) * 10).round()} XP', isDark),
                if (result.totalTests > 0)
                  _buildOverlayRow(l.codeTests, '${result.passedTests} / ${result.totalTests}',
                      '+${result.totalTests == 0 ? 0 : ((result.passedTests / result.totalTests) * 15).round()} XP', isDark),
                if (result.totalQuizzes == 0 && result.totalTests == 0)
                  _buildOverlayRow(l.theoryRead, '100%', '+10 XP', isDark),
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                if (result.awardedXp > 0)
                  Text(
                    l.gainedXp(result.awardedXp),
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
                      // Dismiss overlay and return to roadmap.
                      setState(() => _activeCompletionResult = null);
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
      ),
    );
  }

  // Render a single row in the completion overlay score breakdown.
  Widget _buildOverlayRow(String label, String ratio, String xp, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          Row(
            children: [
              Text(ratio, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[500])),
              const SizedBox(width: 12),
              Text(xp, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primaryCyan)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapView(Course selectedCourse, List<bool> completionStatuses,
      int activeIndex, Color langColor, bool isDark, bool allCompleted) {
    return RefreshIndicator(
      onRefresh: context.read<AppState>().refreshContent,
      color: Theme.of(context).colorScheme.primary,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double centerX = constraints.maxWidth / 2;
          final double amplitude =
              (constraints.maxWidth * 0.22).clamp(50.0, 110.0);
          const double spacingY = 150.0;
          final double totalHeight =
              spacingY * selectedCourse.lessons.length + 100.0;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: SizedBox(
              width: constraints.maxWidth,
              height: totalHeight,
              child: AnimatedBuilder(
                animation: _pathAnimController,
                builder: (context, child) {
                  final bool motionDisabled =
                      context.read<AppState>().motionDisabled;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: CourseMapPainter(
                            lessonCount: selectedCourse.lessons.length,
                            completionStatuses: completionStatuses,
                            activeIndex: activeIndex,
                            primaryColor: Theme.of(context).colorScheme.primary,
                            accentColor:
                                Theme.of(context).colorScheme.secondary,
                            completedColor: AppTheme.successGreen,
                            lockedColor: isDark
                                ? AppTheme.darkBorder
                                : AppTheme.lightBorder,
                            spacingY: spacingY,
                            amplitude: amplitude,
                            animationValue: motionDisabled
                                ? 0.0
                                : _pathAnimController.value,
                          ),
                        ),
                      ),
                      ...selectedCourse.lessons.asMap().entries.map((entry) {
                        final i = entry.key;
                        final lesson = entry.value;
                        final isDone = completionStatuses[i];
                        final isActive = i == activeIndex;
                        final isLocked = !allCompleted && i > activeIndex;

                        final double xNode = centerX +
                            (i % 2 == 0 ? -amplitude : amplitude) *
                                (i == 0 ? 0.0 : 1.0);
                        final double yNode = spacingY / 2 + i * spacingY;

                        final double swayX = motionDisabled
                            ? 0.0
                            : (math.cos(
                                    (_pathAnimController.value * 2 * math.pi) +
                                        (i * 1.5)) *
                                3.5);
                        final double swayY = motionDisabled
                            ? 0.0
                            : (math.sin(
                                    (_pathAnimController.value * 2 * math.pi) +
                                        (i * 1.5)) *
                                3.5);

                        final double xPosNode = xNode + swayX;
                        final double yPosNode = yNode + swayY;

                        final VoidCallback handleTap = () async {
                          // Await result from lesson and show overlay if lesson was completed.
                          final result = await Navigator.push<LessonCompletionResult>(
                            context,
                            SlidePageRoute(
                              page: LessonScreen(
                                exercise: lesson,
                                language: selectedCourse.language,
                                isChallenge: false,
                              ),
                            ),
                          );
                          if (result != null && mounted) {
                            setState(() => _activeCompletionResult = result);
                          }
                        };

                        return Stack(
                          key: ValueKey('map_stack_${lesson.id}'),
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: i % 2 == 0 ? (xPosNode + 32) : 12,
                              right: i % 2 == 0
                                  ? 12
                                  : (constraints.maxWidth - xPosNode + 32),
                              top: yPosNode - 34,
                              child: _MapTitleCard(
                                key: ValueKey('map_title_${lesson.id}'),
                                lesson: lesson,
                                index: i,
                                language: selectedCourse.language,
                                langColor: langColor,
                                isDone: isDone,
                                isActive: isActive,
                                isLocked: isLocked,
                                onTap: handleTap,
                              ),
                            ),
                            Positioned(
                              left: xPosNode - 38,
                              top: yPosNode - 38,
                              child: _MapNode(
                                key: ValueKey('map_node_${lesson.id}'),
                                lesson: lesson,
                                index: i,
                                isDone: isDone,
                                isActive: isActive,
                                isLocked: isLocked,
                                langColor: langColor,
                                onTap: handleTap,
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListView(Course selectedCourse, List<bool> completionStatuses,
}