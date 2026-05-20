import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/animated_list_item.dart';
import '../../widgets/glass/glass_app_bar.dart';
import 'package:bitstride_core/l10n/app_localizations.dart';

// Render layout and manage state for Badges Screen.
class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  static const _allBadges = <_BadgeDef>[
    _BadgeDef('first_stride', 'First Stride', 'Complete your first exercise',
        Icons.rocket_launch_rounded, [Color(0xFF00E5FF), Color(0xFF00BFA5)]),
    _BadgeDef(
        'challenge_accepted',
        'Challenge Accepted',
        'Solve a practice challenge',
        Icons.military_tech_rounded,
        [Color(0xFFFF6D00), Color(0xFFFFAB40)]),
    _BadgeDef('five_stages', 'Getting Warmed Up', 'Complete 5 exercises',
        Icons.whatshot_rounded, [Color(0xFFFF4081), Color(0xFFFF80AB)]),
    _BadgeDef('ten_down', 'Ten Down', 'Complete 10 exercises',
        Icons.trending_up_rounded, [Color(0xFF7C4DFF), Color(0xFFB388FF)]),
    _BadgeDef('twenty_five', 'Quarter Century', 'Complete 25 exercises',
        Icons.diamond_rounded, [Color(0xFFFFD740), Color(0xFFFFAB00)]),
    _BadgeDef('level_5', 'Dedicated Scholar', 'Reach level 5',
        Icons.school_rounded, [Color(0xFF00E676), Color(0xFF69F0AE)]),
    _BadgeDef(
        'level_10',
        'Master Scholar',
        'Reach level 10',
        Icons.workspace_premium_rounded,
        [Color(0xFF2196F3), Color(0xFF64B5F6)]),
    _BadgeDef('level_15', 'Grandmaster', 'Reach level 15', Icons.stars_rounded,
        [Color(0xFFE040FB), Color(0xFFF48FB1)]),
    _BadgeDef(
        'streak_3',
        '3-Day Streak',
        'Practice 3 days in a row',
        Icons.local_fire_department_rounded,
        [Color(0xFFFF9800), Color(0xFFFFCC80)]),
    _BadgeDef(
        'streak_7',
        '7-Day Streak',
        'Practice 7 days in a row',
        Icons.local_fire_department_rounded,
        [Color(0xFFFF5722), Color(0xFFFF8A65)]),
    _BadgeDef(
        'streak_15',
        '15-Day Streak',
        'Practice 15 days in a row',
        Icons.local_fire_department_rounded,
        [Color(0xFFFF3D00), Color(0xFFFF9100)]),
    _BadgeDef(
        'streak_30',
        '30-Day Streak',
        'Practice 30 days in a row',
        Icons.local_fire_department_rounded,
        [Color(0xFFD32F2F), Color(0xFFE57373)]),
    _BadgeDef('night_owl', 'Night Owl', 'Practice between 10 PM and 4 AM',
        Icons.nightlight_round, [Color(0xFF3F51B5), Color(0xFF7986CB)]),
    _BadgeDef('early_bird', 'Early Bird', 'Practice between 5 AM and 8 AM',
        Icons.wb_sunny_rounded, [Color(0xFFFFB300), Color(0xFFFFF176)]),
    _BadgeDef('weekend_warrior', 'Weekend Warrior', 'Practice on a weekend',
        Icons.weekend_rounded, [Color(0xFF26A69A), Color(0xFF80CBC4)]),
    _BadgeDef('perfectionist', 'Perfectionist', 'Pass all tests on first try',
        Icons.verified_rounded, [Color(0xFF00BCD4), Color(0xFF80DEEA)]),
    _BadgeDef('cpp_novice', 'C++ Novice', 'Complete a C++ exercise',
        Icons.memory_rounded, [Color(0xFF1565C0), Color(0xFF42A5F5)]),
    _BadgeDef('cpp_pro', 'C++ Pro', 'Complete 5 C++ exercises',
        Icons.memory_rounded, [Color(0xFF0D47A1), Color(0xFF1976D2)]),
    _BadgeDef('python_novice', 'Python Novice', 'Complete a Python exercise',
        Icons.data_object_rounded, [Color(0xFF1B5E20), Color(0xFF66BB6A)]),
    _BadgeDef('python_pro', 'Python Pro', 'Complete 5 Python exercises',
        Icons.data_object_rounded, [Color(0xFF004D40), Color(0xFF26A69A)]),
    _BadgeDef(
        'algo_master',
        'Algorithm Master',
        'Solve 5 practice challenges',
        Icons.auto_awesome_motion_rounded,
        [Color(0xFFE040FB), Color(0xFF651FFF)]),
    _BadgeDef('theory_titan', 'Theory Titan', 'Solve 3 theory-only lessons',
        Icons.menu_book_rounded, [Color(0xFF00E5FF), Color(0xFF2979FF)]),
    _BadgeDef('perfect_five', 'Flawless Five', 'Solve 5 exercises on first try',
        Icons.verified_user_rounded, [Color(0xFF00E676), Color(0xFF00B0FF)]),
    _BadgeDef('polyglot', 'Polyglot Coder', 'Unlock C++ & Python badges',
        Icons.translate_rounded, [Color(0xFF3F51B5), Color(0xFFE91E63)]),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final earned = appState.userProgress.earnedBadges;
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final earnedIds = earned.keys.toSet();
    final crossCount = MediaQuery.of(context).size.width > 600 ? 4 : 2;

    return Scaffold(
      appBar: GlassAppBar(
        title: Text(l10n.badges),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.xpGold.withOpacity(isDark ? 0.14 : 0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.xpGold.withOpacity(0.35)),
                ),
                child: Text(
                  '${earnedIds.length}/${_allBadges.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppTheme.xpGold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: AppTheme.meshBackground(isDark: isDark),
        child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: _allBadges.length,
          itemBuilder: (ctx, i) {
            return AnimatedListItem(
              index: i,
              child: _BadgeCard(
                badge: _allBadges[i],
                unlocked: earnedIds.contains(_allBadges[i].id),
                isDark: isDark,
              ),
            );
          },
        ),
      ),
    );
  }
}

// Provide interface component for Badge Def.
class _BadgeDef {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final List<Color> gradient;

  const _BadgeDef(
      this.id, this.name, this.description, this.icon, this.gradient);
}

// Provide interface component for Badge Card.
class _BadgeCard extends StatelessWidget {
  final _BadgeDef badge;
  final bool unlocked;
  final bool isDark;

  const _BadgeCard({
    required this.badge,
    required this.unlocked,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? (unlocked ? AppTheme.darkCard2 : AppTheme.darkCard)
            : (unlocked ? AppTheme.lightSurface : AppTheme.lightCard),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: unlocked
              ? badge.gradient[0].withOpacity(0.45)
              : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
          width: unlocked ? 1.5 : 1.0,
        ),
        boxShadow: unlocked
            ? [
                BoxShadow(
                  color: badge.gradient[0].withOpacity(0.20),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.20 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: unlocked
                    ? LinearGradient(
                        colors: badge.gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: unlocked
                    ? null
                    : (isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.grey.withOpacity(0.08)),
                shape: BoxShape.circle,
                boxShadow: unlocked
                    ? [
                        BoxShadow(
                          color: badge.gradient[0].withOpacity(0.4),
                          blurRadius: 16,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                badge.icon,
                size: 26,
                color: unlocked
                    ? Colors.white
                    : (isDark ? Colors.grey[700] : Colors.grey[400]),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              badge.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: unlocked
                    ? (isDark ? Colors.white : const Color(0xFF0D1420))
                    : (isDark ? Colors.grey[600] : Colors.grey[500]),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              badge.description,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey[600] : Colors.grey[500],
              ),
            ),
            if (!unlocked)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 16,
                  color: isDark ? Colors.grey[700] : Colors.grey[400],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
