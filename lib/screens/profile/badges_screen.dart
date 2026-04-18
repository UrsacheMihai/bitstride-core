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
}