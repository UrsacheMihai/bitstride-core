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
      int activeIndex, Color langColor, bool isDark, bool allCompleted) {
    final appState = context.watch<AppState>();
    final completed = completionStatuses.where((s) => s).length;
    final total = selectedCourse.lessons.length;

    return RefreshIndicator(
      onRefresh: appState.refreshContent,
      color: Theme.of(context).colorScheme.primary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: selectedCourse.lessons.length + 1,
        itemBuilder: (ctx, index) {
          if (index == 0) {
            final progress = total == 0 ? 0.0 : completed / total;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    langColor.withOpacity(0.12),
                    langColor.withOpacity(0.04)
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: langColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: langColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        '${(progress * 100).round()}%',
                        style: TextStyle(
                          color: langColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$completed / $total lessons completed',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color:
                                isDark ? Colors.white : const Color(0xFF0D1420),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: langColor.withOpacity(0.15),
                            valueColor: AlwaysStoppedAnimation(langColor),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          final i = index - 1;
          final lesson = selectedCourse.lessons[i];
          final isDone = completionStatuses[i];
          final isActive = i == activeIndex;
          final isLocked = !allCompleted && i > activeIndex;
          final hasContent = lesson.contentBlocks.isNotEmpty;
          final hasCode = lesson.tests.isNotEmpty ||
              lesson.initialCode.trim().isNotEmpty ||
              (lesson.initialCodeCpp?.trim().isNotEmpty ?? false) ||
              (lesson.initialCodePython?.trim().isNotEmpty ?? false);
          // Classify lesson as theory when it has content but no code exercises.
          final isTheory = !hasCode && hasContent;
          final isMixed = hasContent && hasCode;

          return AnimatedListItem(
            index: i,
            child: Opacity(
              opacity: isLocked ? 0.5 : 1.0,
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isActive
                        ? langColor.withOpacity(0.5)
                        : (isDone
                            ? AppTheme.successGreen.withOpacity(0.3)
                            : (isDark
                                ? AppTheme.darkBorder
                                : AppTheme.lightBorder)),
                    width: isActive ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    if (isActive)
                      BoxShadow(
                        color: langColor.withOpacity(0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: isLocked
                        ? null
                        : () async {
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
                          },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient:
                                  isDone ? AppTheme.successGradient : null,
                              color: isDone
                                  ? null
                                  : (isActive
                                      ? langColor.withOpacity(0.12)
                                      : (isDark
                                          ? AppTheme.darkBorder.withOpacity(0.5)
                                          : Colors.grey.withOpacity(0.08))),
                              border: Border.all(
                                color: isDone
                                    ? AppTheme.successGreen
                                    : (isActive
                                        ? langColor
                                        : Colors.transparent),
                                width: isActive ? 2 : 0,
                              ),
                            ),
                            child: Center(
                              child: isDone
                                  ? const Icon(Icons.check_rounded,
                                      color: Colors.white, size: 20)
                                  : isLocked
                                      ? Icon(Icons.lock_rounded,
                                          size: 16,
                                          color: isDark
                                              ? Colors.white30
                                              : Colors.grey)
                                      : Text(
                                          '${i + 1}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                            color: isActive
                                                ? langColor
                                                : (isDark
                                                    ? Colors.white54
                                                    : Colors.grey[600]),
                                          ),
                                        ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lesson.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF0D1420),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    _LessonTypePill(
                                      isTheory: isTheory,
                                      isMixed: isMixed,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isMixed
                                          ? '25 XP'
                                          : (isTheory ? '10 XP' : '20 XP'),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? Colors.white38
                                            : Colors.grey[500],
                                      ),
                                    ),
                                    if (lesson.description.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          lesson.description,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isDark
                                                ? Colors.white30
                                                : Colors.grey[400],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (!isLocked)
                            Icon(
                              Icons.chevron_right_rounded,
                              color: isDark ? Colors.white24 : Colors.grey[400],
                              size: 22,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Course definition and initialization
class _CourseBanner extends StatelessWidget {
  final Course course;
  final bool isSelected;
  final VoidCallback onTap;

  const _CourseBanner({
    required this.course,
    required this.isSelected,
    required this.onTap,
  });

  Color get _langColor => course.language == 'cpp'
      ? const Color(0xFF00599C)
      : const Color(0xFF3776AB);

  IconData get _langIcon =>
      course.language == 'cpp' ? Icons.memory : Icons.data_object;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final lessons = course.lessons;
    final completed =
        lessons.where((l) => appState.isExerciseCompleted(l.id)).length;
    final total = lessons.length;
    final progress = total == 0 ? 0.0 : completed / total;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? _langColor
              : (isDark ? AppTheme.darkCard : AppTheme.lightSurface),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? _langColor
                : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
            width: isSelected ? 0 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _langColor.withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.2)
                        : _langColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    _langIcon,
                    color: isSelected ? Colors.white : _langColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    course.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : const Color(0xFF0D1420)),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: isSelected
                          ? Colors.white.withOpacity(0.2)
                          : (isDark
                              ? AppTheme.darkBorder
                              : AppTheme.lightBorder),
                      valueColor: AlwaysStoppedAnimation(
                          isSelected ? Colors.white : _langColor),
                      minHeight: 4,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$completed/$total',
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.grey[500] : Colors.grey[600]),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Render a single lesson node on the learning path map.
class _MapNode extends StatefulWidget {
  final Exercise lesson;
  final int index;
  final bool isDone;
  final bool isActive;
  final bool isLocked;
  final Color langColor;
  final VoidCallback onTap;

  const _MapNode({
    super.key,
    required this.lesson,
    required this.index,
    required this.isDone,
    required this.isActive,
    required this.isLocked,
    required this.langColor,
    required this.onTap,
  });

  @override
  State<_MapNode> createState() => _MapNodeState();
}

// Manage state and provide providers for Map Node State.
class _MapNodeState extends State<_MapNode> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _entranceCtrl;
  late AnimationController _tapCtrl;
  late Animation<double> _entranceFade;
  late Animation<Offset> _entranceSlide;
  late Animation<double> _tapScale;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.isActive) _pulseController.repeat();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _entranceFade = CurvedAnimation(
      parent: _entranceCtrl,
      curve: Curves.easeOut,
    );
    _entranceSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceCtrl,
      curve: Curves.easeOutCubic,
    ));

    Future.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) _entranceCtrl.forward();
    });

    _tapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _tapScale = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.18)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.18, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticIn)),
        weight: 60,
      ),
    ]).animate(_tapCtrl);
  }

  @override
  void didUpdateWidget(covariant _MapNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_pulseController.isAnimating) {
      _pulseController.repeat();
    } else if (!widget.isActive && _pulseController.isAnimating) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _entranceCtrl.dispose();
    _tapCtrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.isLocked) return;
    _tapCtrl.forward(from: 0.0).then((_) => widget.onTap());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _entranceFade,
      child: SlideTransition(
        position: _entranceSlide,
        child: AnimatedBuilder(
          animation: _tapScale,
          builder: (context, child) => Transform.scale(
            scale: _tapScale.value,
            child: child,
          ),
          child: MouseRegion(
            onEnter: (_) {
              if (!widget.isLocked) setState(() => _isHovered = true);
            },
            onExit: (_) => setState(() => _isHovered = false),
            cursor: widget.isLocked
                ? SystemMouseCursors.basic
                : SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _handleTap,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  if (widget.isActive)
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 76 + 32 * _pulseController.value,
                              height: 76 + 32 * _pulseController.value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: widget.langColor.withOpacity(
                                      1.0 - _pulseController.value),
                                  width: 2,
                                ),
                              ),
                            ),
                            Container(
                              width: 76 + 16 * _pulseController.value,
                              height: 76 + 16 * _pulseController.value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: widget.langColor.withOpacity(
                                    0.15 * (1.0 - _pulseController.value)),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutBack,
                    width: 76,
                    height: 76,
                    transformAlignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..scale(_isHovered ? 1.08 : 1.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: widget.isDone
                          ? AppTheme.successGradient
                          : (widget.isActive
                              ? LinearGradient(
                                  colors: [
                                    widget.langColor,
                                    widget.langColor.withOpacity(0.8)
                                  ],
                                )
                              : null),
                      color: widget.isLocked
                          ? (isDark
                              ? AppTheme.darkBorder
                              : AppTheme.lightBorder)
                          : (widget.isDone || widget.isActive
                              ? null
                              : widget.langColor.withOpacity(0.12)),
                      border: Border.all(
                        color: widget.isDone
                            ? AppTheme.successGreen
                            : (widget.isActive
                                ? Colors.white
                                : (widget.isLocked
                                    ? (isDark
                                        ? Colors.white10
                                        : Colors.black.withOpacity(0.10))
                                    : widget.langColor.withOpacity(0.4))),
                        width: widget.isActive ? 3 : 2,
                      ),
                      boxShadow: _isHovered
                          ? [
                              BoxShadow(
                                color: widget.isDone
                                    ? AppTheme.successGreen.withOpacity(0.6)
                                    : widget.langColor.withOpacity(0.6),
                                blurRadius: 24,
                                spreadRadius: 2,
                              ),
                            ]
                          : (widget.isActive
                              ? [
                                  BoxShadow(
                                    color: widget.langColor.withOpacity(0.5),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : (widget.isDone
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.successGreen
                                            .withOpacity(0.3),
                                        blurRadius: 12,
                                      ),
                                    ]
                                  : [])),
                    ),
                    child: Center(
                      child: widget.isDone
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 32,
                            )
                          : widget.isLocked
                              ? Icon(
                                  Icons.lock_rounded,
                                  color: isDark
                                      ? Colors.white30
                                      : Colors.black.withOpacity(0.30),
                                  size: 26,
                                )
                              : Text(
                                  '${widget.index + 1}',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: widget.isActive
                                        ? Colors.white
                                        : widget.langColor,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                    ),
                  ),
                  if (widget.isActive) ...[
                    Positioned(
                      left: 13,
                      top: -46,
                      child: const _BouncingMascot(size: 50),
                    ),
                    Positioned(
                      top: -82,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutBack,
                          transformAlignment: Alignment.bottomCenter,
                          transform: Matrix4.identity()
                            ..scale(_isHovered ? 1.1 : 1.0),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.accentPink,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentPink.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Text(
                            'START',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Provide interface component for Map Title Card.
class _MapTitleCard extends StatefulWidget {
  final Exercise lesson;
  final int index;
  final String language;
  final Color langColor;
  final bool isDone;
  final bool isActive;
  final bool isLocked;
  final VoidCallback onTap;

  const _MapTitleCard({
    super.key,
    required this.lesson,
    required this.index,
    required this.language,
    required this.langColor,
    required this.isDone,
    required this.isActive,
    required this.isLocked,
    required this.onTap,
  });

  @override
  State<_MapTitleCard> createState() => _MapTitleCardState();
}

// Manage state and provide providers for Map Title Card State.
class _MapTitleCardState extends State<_MapTitleCard> {
  bool _isHovered = false;

  bool get _hasContent => widget.lesson.contentBlocks.isNotEmpty;

  bool get _hasCode =>
      widget.lesson.tests.isNotEmpty ||
      widget.lesson.initialCode.trim().isNotEmpty ||
      (widget.lesson.initialCodeCpp?.trim().isNotEmpty ?? false) ||
      (widget.lesson.initialCodePython?.trim().isNotEmpty ?? false);

  // Classify lesson as theory when it has content but no code exercises.
  bool get _isTheory => !_hasCode && _hasContent;

  bool get _isMixed => _hasContent && _hasCode;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context)!;

    final Color activeBorderColor = widget.isDone
        ? AppTheme.successGreen
        : (widget.isActive
            ? widget.langColor
            : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder));

    return MouseRegion(
      onEnter: (_) {
        if (!widget.isLocked) {
          setState(() => _isHovered = true);
        }
      },
      onExit: (_) {
        setState(() => _isHovered = false);
      },
      cursor:
          widget.isLocked ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.isLocked ? null : widget.onTap,
        child: Opacity(
          opacity: widget.isLocked ? 0.5 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            transform: Matrix4.identity()
              ..translate(0.0, _isHovered ? -3.0 : 0.0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isHovered
                    ? activeBorderColor
                    : (widget.isDone
                        ? AppTheme.successGreen.withOpacity(0.35)
                        : (widget.isActive
                            ? widget.langColor.withOpacity(0.5)
                            : (isDark
                                ? AppTheme.darkBorder
                                : AppTheme.lightBorder))),
                width: (widget.isActive || _isHovered) ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? activeBorderColor.withOpacity(0.2)
                      : Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                  blurRadius: _isHovered ? 12 : (widget.isActive ? 10 : 6),
                  offset: Offset(0, _isHovered ? 4 : 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.lesson.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: isDark ? Colors.white : const Color(0xFF0D1420),
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _MetaChip(
                      label: _isMixed
                          ? 'Mixed'
                          : (_isTheory ? l.theoryBadge : l.codeBadge),
                      color: _isMixed
                          ? AppTheme.xpGold
                          : (_isTheory
                              ? AppTheme.accentPurple
                              : AppTheme.primaryCyan),
                      icon: _isMixed
                          ? Icons.auto_awesome_rounded
                          : (_isTheory
                              ? Icons.menu_book_rounded
                              : Icons.code_rounded),
                    ),
                    Text(
                      _isMixed ? '25 XP' : (_isTheory ? '10 XP' : '20 XP'),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? Colors.white.withOpacity(0.50)
                            : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Provide interface component for Meta Chip.
class _MetaChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _MetaChip({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// Provide interface component for Lesson Type Pill.
class _LessonTypePill extends StatelessWidget {
  final bool isTheory;
  final bool isMixed;

  const _LessonTypePill({required this.isTheory, required this.isMixed});

  @override
  Widget build(BuildContext context) {
    final Color color = isMixed
        ? AppTheme.xpGold
        : (isTheory ? AppTheme.accentPurple : AppTheme.primaryCyan);
    final IconData icon = isMixed
        ? Icons.auto_awesome_rounded
        : (isTheory ? Icons.menu_book_rounded : Icons.code_rounded);
    final String label = isMixed ? 'Mixed' : (isTheory ? 'Theory' : 'Code');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

// Animate the mascot widget with a looping vertical bounce.
class _BouncingMascot extends StatefulWidget {
  final double size;

  const _BouncingMascot({super.key, this.size = 50});

  @override
  State<_BouncingMascot> createState() => _BouncingMascotState();
}

// Manage state and provide providers for Bouncing Mascot State.
class _BouncingMascotState extends State<_BouncingMascot>
    with TickerProviderStateMixin {
  late AnimationController _bounceCtrl;
  late AnimationController _swayCtrl;
  late AnimationController _glowCtrl;
  late Animation<double> _bounceAnim;
  late Animation<double> _swayAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: 0.0, end: -10.0).animate(
        CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOutSine));

    _swayCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat(reverse: true);
    _swayAnim = Tween<double>(begin: -3.0, end: 3.0).animate(
        CurvedAnimation(parent: _swayCtrl, curve: Curves.easeInOutSine));

    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOutSine));
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _swayCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final motionDisabled = context.watch<AppState>().motionDisabled;
    final Widget mascot = MascotDisplay(
      gifAsset: 'happy-dance-138e71c9-360.webm',
      size: widget.size,
    );

    if (motionDisabled) return mascot;

    return AnimatedBuilder(
      animation: Listenable.merge([_bounceAnim, _swayAnim, _glowAnim]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_swayAnim.value, _bounceAnim.value),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryCyan
                            .withOpacity(0.08 + _glowAnim.value * 0.14),
                        blurRadius: 16 + _glowAnim.value * 12,
                        spreadRadius: 2 + _glowAnim.value * 4,
                      ),
                    ],
                  ),
                ),
              ),
              child!,
            ],
          ),
        );
      },
      child: mascot,
    );
  }
}
