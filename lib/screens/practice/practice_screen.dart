import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app/app_state.dart';
import '../../models/exercise/exercise.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/animated_list_item.dart';
import '../../widgets/common/page_transitions.dart';
import '../../widgets/common/mascot_display.dart';
import '../learn/lesson_screen.dart';
import 'package:bitstride_core/l10n/app_localizations.dart';

// Render layout and manage state for Practice Screen.
class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

// Manage state and provide providers for Practice Screen State.
class _PracticeScreenState extends State<PracticeScreen> {
  String _selectedDifficulty = 'All';
  String _selectedStatus = 'All';
  String _selectedCategory = 'All';
  String _selectedMethod = 'All';
  final _searchNotifier = ValueNotifier<String>('');
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _searchNotifier.addListener(_onSearchChanged);
  }

  void _onSearchChanged() => setState(() {});

  @override
  void dispose() {
    _searchNotifier.removeListener(_onSearchChanged);
    _searchNotifier.dispose();
    super.dispose();
  }

  List<String> _extractUnique(
      List<Challenge> challenges, String Function(Challenge) extractor) {
    final set = <String>{};
    for (final c in challenges) {
      final v = extractor(c).trim();
      if (v.isNotEmpty) set.add(v);
    }
    final sorted = set.toList()..sort();
    return ['All', ...sorted];
  }

  void _showFilterBottomSheet(BuildContext context) {
    final appState = context.read<AppState>();
    final challenges = appState.challenges;
    final l = AppLocalizations.of(context)!;
    final categories = _extractUnique(challenges, (c) => c.category);
    final methods = _extractUnique(challenges, (c) => c.method);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ct) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Widget buildFilterChips(String title, List<String> items,
                String selected, Function(String) onSelect) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[400] : Colors.grey[600])),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: items.map((item) {
                      final isSelected = item == selected;
                      return ChoiceChip(
                        label: Text(item),
                        selected: isSelected,
                        onSelected: (_) {
                          setModalState(() => onSelect(item));
                          setState(() => onSelect(item));
                        },
                        selectedColor: AppTheme.primaryCyan.withOpacity(0.18),
                        showCheckmark: false,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard2 : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filters',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : Colors.black)),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedDifficulty = 'All';
                            _selectedCategory = 'All';
                            _selectedMethod = 'All';
                          });
                          setState(() {
                            _selectedDifficulty = 'All';
                            _selectedCategory = 'All';
                            _selectedMethod = 'All';
                          });
                        },
                        child: Text('Reset',
                            style: TextStyle(
                                color: AppTheme.errorRed,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  buildFilterChips(
                      l.difficulty,
                      ['All', 'easy', 'medium', 'hard'],
                      _selectedDifficulty,
                      (v) => _selectedDifficulty = v),
                  if (categories.length > 1)
                    buildFilterChips('Category', categories, _selectedCategory,
                        (v) => _selectedCategory = v),
                  if (methods.length > 1)
                    buildFilterChips('Method', methods, _selectedMethod,
                        (v) => _selectedMethod = v),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final challenges = appState.challenges;
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    final filtered = challenges.where((c) {
      final q = _searchNotifier.value;
      if (q.isNotEmpty) {
        final queryLower = q.toLowerCase();
        final matchTitle = c.title.toLowerCase().contains(queryLower);
        final matchCategory = c.category.toLowerCase().contains(queryLower);
        final matchMethod = c.method.toLowerCase().contains(queryLower);
        if (!matchTitle && !matchCategory && !matchMethod) {
          return false;
        }
      }
      if (_selectedDifficulty != 'All' && c.difficulty != _selectedDifficulty)
        return false;
      if (_selectedStatus == 'Completed' &&
          !appState.isChallengeCompleted(c.id)) return false;
      if (_selectedStatus == 'Incomplete' &&
          appState.isChallengeCompleted(c.id)) return false;
      if (_selectedCategory != 'All' && c.category != _selectedCategory)
        return false;
      if (_selectedMethod != 'All' && c.method != _selectedMethod) return false;
      return true;
    }).toList();

    final activeFilterCount = [
      _selectedDifficulty != 'All',
      _selectedCategory != 'All',
      _selectedMethod != 'All',
    ].where((v) => v).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: AnimatedCrossFade(
                  duration: const Duration(milliseconds: 220),
                  crossFadeState: _showSearch
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: Text(
                    l.practiceTab,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 20),
                  ),
                  secondChild: _SearchField(
                    hint: l.searchChallenges,
                    isDark: isDark,
                    primary: primary,
                    searchNotifier: _searchNotifier,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _IconPill(
                icon: _showSearch ? Icons.close_rounded : Icons.search_rounded,
                color: primary,
                isDark: isDark,
                onTap: () => setState(() {
                  _showSearch = !_showSearch;
                  if (!_showSearch) {
                    _searchNotifier.value = '';
                  }
                }),
              ),
              const SizedBox(width: 6),
              _IconPill(
                icon: Icons.filter_list_rounded,
                color: activeFilterCount > 0 ? AppTheme.accentPurple : primary,
                isDark: isDark,
                badge: activeFilterCount > 0 ? '$activeFilterCount' : null,
                onTap: () => _showFilterBottomSheet(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 38,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _StatusPill(
                  label: 'All',
                  isSelected: _selectedStatus == 'All',
                  isDark: isDark,
                  onTap: () => setState(() => _selectedStatus = 'All'),
                ),
                const SizedBox(width: 8),
                _StatusPill(
                  label: 'Completed',
                  isSelected: _selectedStatus == 'Completed',
                  isDark: isDark,
                  onTap: () => setState(() => _selectedStatus = 'Completed'),
                ),
                const SizedBox(width: 8),
                _StatusPill(
                  label: 'Incomplete',
                  isSelected: _selectedStatus == 'Incomplete',
                  isDark: isDark,
                  onTap: () => setState(() => _selectedStatus = 'Incomplete'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Builder(builder: (context) {
          final challenges = context.read<AppState>().challenges;
          final categories = _extractUnique(challenges, (c) => c.category);
          final methods = _extractUnique(challenges, (c) => c.method);
          final hasCategories = categories.length > 1;
          final hasMethods = methods.length > 1;
          if (!hasCategories && !hasMethods) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasCategories) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 0, 4),
                  child: Text('Category',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.grey[500] : Colors.grey[500])),
                ),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _QuickFilterPill(
                          label: cat,
                          isSelected: isSelected,
                          color: AppTheme.accentPurple,
                          isDark: isDark,
                          onTap: () => setState(() => _selectedCategory = cat),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 6),
              ],
              if (hasMethods) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 0, 4),
                  child: Text('Method',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.grey[500] : Colors.grey[500])),
                ),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: methods.map((m) {
                      final isSelected = _selectedMethod == m;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _QuickFilterPill(
                          label: m,
                          isSelected: isSelected,
                          color: AppTheme.primaryTeal,
                          isDark: isDark,
                          onTap: () => setState(() => _selectedMethod = m),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ],
          );
        }),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MascotDisplay(
                        gifAsset: 'looking-through-magnifier-661ddc92-360.webm',
                        size: 100,
                      ),
                      const SizedBox(height: 16),
                      Text(l.noChallenges,
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[500],
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          )),
                      if (activeFilterCount > 0) ...[
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => setState(() {
                            _selectedDifficulty = 'All';
                            _selectedStatus = 'All';
                            _selectedCategory = 'All';
                            _selectedMethod = 'All';
                            _searchNotifier.value = '';
                          }),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Clear filters'),
                        ),
                      ],
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: appState.refreshContent,
                  color: primary,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => AnimatedListItem(
                              index: i,
                              child: _ChallengeCard(
                                challenge: filtered[i],
                                completed: appState
                                    .isChallengeCompleted(filtered[i].id),
                              ),
                            ),
                            childCount: filtered.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}