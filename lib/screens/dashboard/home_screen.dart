import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/xp_bar.dart';
import '../../widgets/glass/glass_app_bar.dart';
import '../../widgets/glass/glass_nav_bar.dart';
import '../learn/learn_screen.dart';
import '../practice/practice_screen.dart';
import '../visualizer/algorithm_visualizer_screen.dart';
import '../profile/settings_screen.dart';
import '../../widgets/common/streak_dialog.dart';
import '../../widgets/common/page_transitions.dart';
import 'package:bitstride_core/l10n/app_localizations.dart';

// Render layout and manage state for Home Screen.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Manage state and provide providers for Home Screen State.
class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  final List<Widget> _screens = const [
    LearnScreen(),
    PracticeScreen(),
    AlgorithmVisualizerScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final progress = appState.userProgress;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      appState.refreshIfStale();
    });

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: GlassAppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryCyan.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child:
                  const Icon(Icons.code_rounded, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Text('BitStride'),
            const Spacer(),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => const StreakDialog(),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(isDark ? 0.15 : 0.10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.orange.withOpacity(0.3), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_fire_department_rounded,
                        color: Colors.orange[400], size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${progress.streak}',
                      style: TextStyle(
                        color: Colors.orange[400],
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.07)
                    : Colors.grey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                ),
              ),
              child: const Icon(Icons.settings_outlined, size: 18),
            ),
            onPressed: () {
              Navigator.push(
                context,
                SlidePageRoute(page: const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Container(
        decoration: AppTheme.meshBackground(isDark: isDark),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: XpBar(
                currentXp: progress.xpInCurrentLevel,
                maxXp: progress.xpForNextLevel,
                level: progress.level,
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: child,
                ),
                child: KeyedSubtree(
                  key: ValueKey(_selectedTab),
                  child: _screens[_selectedTab],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: GlassNavBar(
        selectedIndex: _selectedTab,
        onTap: (i) => setState(() => _selectedTab = i),
        items: [
          GlassNavItem(
            icon: Icons.school_rounded,
            label: l10n.learnTab,
          ),
          GlassNavItem(
            icon: Icons.fitness_center_rounded,
            label: l10n.practiceTab,
          ),
          GlassNavItem(
            icon: Icons.bar_chart_rounded,
            label: l10n.visualizeTab,
          ),
        ],
      ),
    );
  }
}
