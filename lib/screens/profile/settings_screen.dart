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

  void _showChangeNameDialog(BuildContext context, AppState appState) {
    final controller = TextEditingController(
      text: appState.userProgress.displayName,
    );
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: AppTheme.glassDialogDecoration(isDark: isDark),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.changeName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.enterDisplayName,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final name = controller.text.trim();
                        if (name.isNotEmpty) {
                          appState.updateDisplayName(name);
                          Navigator.pop(ctx);
                        }
                      },
                      child: Text(l10n.save),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, AppState appState) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: AppTheme.glassDialogDecoration(isDark: isDark),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded,
                    color: AppTheme.errorRed, size: 32),
              ),
              const SizedBox(height: 16),
              const Text('Sign Out',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                l10n.signOutConfirm,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        appState.signOut();
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorRed,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(l10n.signOut),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Provide interface component for Section Card.
class _SectionCard extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;

  const _SectionCard({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.solidCard(isDark: isDark, borderRadius: 20),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 1,
                indent: 56,
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              ),
          ],
        ],
      ),
    );
  }
}

// Provide interface component for Settings Tile.
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDark;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (onTap != null && trailing == null)
              Icon(Icons.chevron_right_rounded,
                  color: isDark ? Colors.grey[600] : Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

// Provide interface component for Stat Card.
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: AppTheme.solidCard(isDark: isDark, borderRadius: 18),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
