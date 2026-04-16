import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/page_transitions.dart';
import '../../widgets/glass/glass_app_bar.dart';
import './badges_screen.dart';
import 'package:bitstride_core/l10n/app_localizations.dart';

// Render layout and manage state for Settings Screen.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final progress = appState.userProgress;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: GlassAppBar(title: Text(l10n.settings)),
      body: Container(
        decoration: AppTheme.meshBackground(isDark: isDark),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryCyan.withOpacity(0.30),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.35), width: 2),
                      ),
                      child: Center(
                        child: Text(
                          (progress.displayName.isNotEmpty
                                  ? progress.displayName[0]
                                  : '?')
                              .toUpperCase(),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      progress.displayName.isEmpty
                          ? 'User'
                          : progress.displayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      progress.email,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.72),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.level(progress.level)} • ${l10n.xpTotal(progress.xp)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.check_circle_rounded,
                      color: AppTheme.successGreen,
                      value: '${progress.completedExercises.length}',
                      label: l10n.exercisesCompleted,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.fitness_center_rounded,
                      color: AppTheme.accentPurple,
                      value: '${progress.completedChallenges.length}',
                      label: l10n.challengesSolved,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.local_fire_department_rounded,
                      color: Colors.orange,
                      value: '${progress.streak}',
                      label: l10n.currentStreak,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _SectionCard(
                isDark: isDark,
                children: [
                  _SettingsTile(
                    icon: Icons.dark_mode_outlined,
                    iconColor: AppTheme.accentPurple,
                    title: l10n.darkMode,
                    trailing: Switch(
                      value: appState.isDarkMode,
                      onChanged: (_) => appState.toggleDarkMode(),
                    ),
                    isDark: isDark,
                  ),
                  _SettingsTile(
                    icon: Icons.animation_rounded,
                    iconColor: AppTheme.warningOrange,
                    title: l10n.disableMotion,
                    subtitle: l10n.disableMotionSubtitle,
                    trailing: Switch(
                      value: appState.motionDisabled,
                      onChanged: (_) => appState.toggleMotion(),
                    ),
                    isDark: isDark,
                  ),
                  _SettingsTile(
                    icon: Icons.translate_rounded,
                    iconColor: AppTheme.primaryTeal,
                    title: l10n.language,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkCard2 : AppTheme.lightCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? AppTheme.darkBorder
                              : AppTheme.lightBorder,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: appState.language,
                          isDense: true,
                          borderRadius: BorderRadius.circular(14),
                          dropdownColor:
                              isDark ? AppTheme.darkCard2 : Colors.white,
                          items: const [
                            DropdownMenuItem(
                                value: 'en', child: Text('English')),
                            DropdownMenuItem(
                                value: 'ro', child: Text('Română')),
                            DropdownMenuItem(
                                value: 'es', child: Text('Español')),
                            DropdownMenuItem(
                                value: 'fr', child: Text('Français')),
                            DropdownMenuItem(
                                value: 'pt', child: Text('Português')),
                          ],
                          onChanged: (v) {
                            if (v != null) appState.setLanguage(v);
                          },
                        ),
                      ),
                    ),
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _SectionCard(
                isDark: isDark,
                children: [
                  _SettingsTile(
                    icon: Icons.person_outline_rounded,
                    iconColor: AppTheme.primaryCyan,
                    title: l10n.changeName,
                    onTap: () => _showChangeNameDialog(context, appState),
                    isDark: isDark,
                  ),
                  _SettingsTile(
                    icon: Icons.emoji_events_rounded,
                    iconColor: AppTheme.xpGold,
                    title: l10n.badges,
                    subtitle: l10n.earnedBadges(progress.earnedBadges.length),
                    onTap: () {
                      Navigator.push(
                          context, SlidePageRoute(page: const BadgesScreen()));
                    },
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _SectionCard(
                isDark: isDark,
                children: [
                  _SettingsTile(
                    icon: Icons.logout_rounded,
                    iconColor: AppTheme.errorRed,
                    title: l10n.signOut,
                    onTap: () => _showSignOutDialog(context, appState),
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}