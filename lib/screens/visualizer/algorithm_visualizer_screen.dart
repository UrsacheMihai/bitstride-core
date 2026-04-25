import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/algorithm/algorithm_info.dart';
import '../../services/sort/sort_algorithms.dart';
import '../../widgets/visualizer/visualizer_widgets.dart';
import '../../widgets/visualizer/code_preview.dart';
import '../../widgets/glass/glass_app_bar.dart';

// Render layout and manage state for Algorithm Visualizer Screen.
class AlgorithmVisualizerScreen extends StatefulWidget {
  final String? preselectedAlgorithm;

  const AlgorithmVisualizerScreen({super.key, this.preselectedAlgorithm});

  @override
  State<AlgorithmVisualizerScreen> createState() =>
      _AlgorithmVisualizerScreenState();
}

// Manage state and provide providers for Algorithm Visualizer Screen State.
class _AlgorithmVisualizerScreenState extends State<AlgorithmVisualizerScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  List<int> _array = [];
  int _arraySize = 30;
  bool _running = false;
  Timer? _playbackTimer;
  List<SortEvent> _history = [];
  double _timelinePosition = 0;
  bool _isGenerating = false;
  late AnimationController _pulseCtrl;
  int _comparisons = 0, _swaps = 0, _accesses = 0;
  Set<int> _comparing = {}, _swapping = {}, _sorted = {};
  int? _pivot;
  int _codeLine = -1;
  double _speed = 50;
  String _preset = 'random';

  AlgorithmInfo get _algo => kAlgorithms[_selectedIndex];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    if (widget.preselectedAlgorithm != null) {
      final idx =
          kAlgorithms.indexWhere((a) => a.id == widget.preselectedAlgorithm);
      if (idx >= 0) _selectedIndex = idx;
    }
    _generateArray();
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _generateArray() async {
    final rng = Random();
    List<int> initialArray;
    switch (_preset) {
      case 'nearly':
        initialArray = List.generate(_arraySize, (i) => i + 1);
        for (int i = 0; i < _arraySize ~/ 5; i++) {
          final a = rng.nextInt(_arraySize), b = rng.nextInt(_arraySize);
          final tmp = initialArray[a];
          initialArray[a] = initialArray[b];
          initialArray[b] = tmp;
        }
        break;
      case 'reversed':
        initialArray = List.generate(_arraySize, (i) => _arraySize - i);
        break;
      case 'few':
        initialArray = List.generate(_arraySize, (_) => rng.nextInt(5) + 1);
        break;
      default:
        initialArray =
            List.generate(_arraySize, (_) => rng.nextInt(_arraySize) + 1);
    }
    setState(() {
      _array = List.of(initialArray);
      _comparisons = 0;
      _swaps = 0;
      _accesses = 0;
      _comparing = {};
      _swapping = {};
      _sorted = {};
      _pivot = null;
      _codeLine = -1;
      _isGenerating = true;
      _running = false;
      _playbackTimer?.cancel();
      _history.clear();
      _timelinePosition = 0;
    });

    final sorter = SortAlgorithms(speed: 0);
    final stream = sorter.run(_algo.id, List.of(initialArray));
    final events = await stream.toList();

    if (mounted) {
      setState(() {
        _history = events;
        _isGenerating = false;
      });
    }
  }

  void _updateFromHistory(double pos) {
    if (_history.isEmpty) return;
    final idx = pos.floor().clamp(0, _history.length - 1);
    final evt = _history[idx];
    _array = evt.array;
    _comparing = evt.comparing;
    _swapping = evt.swapping;
    _sorted = evt.sorted;
    _pivot = evt.pivot;
    _comparisons = evt.comparisons;
    _swaps = evt.swaps;
    _accesses = evt.accesses;
    _codeLine = evt.codeLine;
  }

  void _startSort() {
    if (_running || _isGenerating || _history.isEmpty) return;
    if (_timelinePosition >= _history.length - 1) {
      _timelinePosition = 0;
    }
    _running = true;
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        final stepDelta = 16.0 / max(1.0, _speed);
        _timelinePosition += stepDelta;
        if (_timelinePosition >= _history.length - 1) {
          _timelinePosition = (_history.length - 1).toDouble();
          _running = false;
          timer.cancel();
        }
        _updateFromHistory(_timelinePosition);
      });
    });
    setState(() {});
  }

  void _pauseSort() {
    _running = false;
    _playbackTimer?.cancel();
    setState(() {});
  }

  void _resetSort() {
    _running = false;
    _playbackTimer?.cancel();
    setState(() {
      _timelinePosition = 0;
      _updateFromHistory(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wide = MediaQuery.of(context).size.width > 900;
    final maxVal = _array.isEmpty ? 1 : _array.reduce(max);
    return Scaffold(
      appBar: GlassAppBar(
        title: Text(_algo.name),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ComplexityBadge(
                label: _algo.stable ? 'STABLE' : 'UNSTABLE', isDark: isDark),
          ),
        ],
      ),
      body: Container(
        decoration: AppTheme.meshBackground(isDark: isDark),
        child: SafeArea(
          top: false,
          child:
              wide ? _buildWide(isDark, maxVal) : _buildNarrow(isDark, maxVal),
        ),
      ),
    );
  }

  Widget _buildWide(bool isDark, int maxVal) {
    return Row(
      children: [
        SizedBox(
          width: 220,
          child: _buildAlgorithmList(isDark),
        ),
        Expanded(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Spacer(),
                    StatChip(
                        label: 'CMP',
                        value: _comparisons,
                        color: const Color(0xFFFFD740),
                        isDark: isDark),
                    const SizedBox(width: 6),
                    StatChip(
                        label: 'SWP',
                        value: _swaps,
                        color: const Color(0xFFFF5252),
                        isDark: isDark),
                    const SizedBox(width: 6),
                    StatChip(
                        label: 'ACC',
                        value: _accesses,
                        color: AppTheme.primaryCyan,
                        isDark: isDark),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: _buildChart(isDark, maxVal),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Container(
                    decoration: AppTheme.glassCard(isDark: isDark),
                    child: CodePreview(
                        algorithmId: _algo.id,
                        highlightLine: _codeLine,
                        isDark: isDark),
                  ),
                ),
              ),
              _buildControls(isDark),
            ],
          ),
        ),
        SizedBox(
          width: 200,
          child: _buildComplexityPanel(isDark),
        ),
      ],
    );
  }

}