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
}