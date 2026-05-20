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

  Widget _buildNarrow(bool isDark, int maxVal) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.primaryCyan.withOpacity(isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryCyan.withOpacity(0.4)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedIndex,
                isExpanded: true,
                dropdownColor: isDark ? AppTheme.darkSurface : Colors.white,
                icon: Icon(Icons.arrow_drop_down_rounded,
                    color: AppTheme.primaryCyan),
                style: TextStyle(
                  color: AppTheme.primaryCyan,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  fontFamily: 'Nunito',
                ),
                onChanged: _running
                    ? null
                    : (val) {
                        if (val != null) {
                          _selectedIndex = val;
                          _generateArray();
                        }
                      },
                items: kAlgorithms.asMap().entries.map((e) {
                  return DropdownMenuItem<int>(
                    value: e.key,
                    child: Text(e.value.name),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
          const SizedBox(height: 10),
          SizedBox(height: 200, child: _buildChart(isDark, maxVal)),
          const SizedBox(height: 8),
          SizedBox(
            height: 220,
            child: Container(
              decoration: AppTheme.glassCard(isDark: isDark),
              child: CodePreview(
                  algorithmId: _algo.id,
                  highlightLine: _codeLine,
                  isDark: isDark),
            ),
          ),
          const SizedBox(height: 8),
          _buildControls(isDark),
          const SizedBox(height: 12),
          _buildMiniComplexity(isDark),
        ],
      ),
    );
  }

  Widget _buildChart(bool isDark, int maxVal) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: BarChartPainter(
                array: _array,
                maxValue: maxVal,
                comparing: _comparing,
                swapping: _swapping,
                sorted: _sorted,
                pivot: _pivot,
                isDark: isDark,
              ),
            ),
          ),
          if (!_running)
            Positioned.fill(
              child: Center(
                child: AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, __) => Opacity(
                    opacity: 0.6 + _pulseCtrl.value * 0.4,
                    child: GestureDetector(
                      onTap: _startSort,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                                color: AppTheme.primaryCyan.withOpacity(0.35),
                                blurRadius: 20,
                                spreadRadius: 2)
                          ],
                        ),
                        child: const Icon(Icons.play_arrow_rounded,
                            color: Colors.white, size: 28),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControls(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: AppTheme.glassCard(isDark: isDark),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_running)
                    ControlButton(
                        icon: Icons.pause_rounded,
                        label: 'Pause',
                        onTap: _pauseSort,
                        isDark: isDark)
                  else
                    ControlButton(
                        icon: Icons.play_arrow_rounded,
                        label: 'Start',
                        onTap: _isGenerating ? null : _startSort,
                        isDark: isDark),
                  const SizedBox(width: 8),
                  ControlButton(
                      icon: Icons.refresh_rounded,
                      label: 'Reset',
                      onTap: _resetSort,
                      isDark: isDark),
                ],
              ),
              if (_history.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      Text('${_timelinePosition.floor()}',
                          style: TextStyle(
                              fontSize: 10,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                              fontFamily: 'monospace')),
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 4,
                            activeTrackColor: AppTheme.primaryCyan,
                            inactiveTrackColor: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.1),
                            thumbColor: AppTheme.primaryCyan,
                            overlayColor: AppTheme.primaryCyan.withOpacity(0.2),
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 12),
                          ),
                          child: Slider(
                            value: _timelinePosition,
                            min: 0,
                            max: (_history.length - 1).toDouble(),
                            onChanged: (v) {
                              setState(() {
                                _timelinePosition = v;
                                _updateFromHistory(v);
                              });
                            },
                            onChangeStart: (v) {
                              if (_running) _pauseSort();
                            },
                          ),
                        ),
                      ),
                      Text('${_history.length - 1}',
                          style: TextStyle(
                              fontSize: 10,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                              fontFamily: 'monospace')),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('Size',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[500] : Colors.grey[600])),
                  Expanded(
                    child: Slider(
                      value: _arraySize.toDouble(),
                      min: 5,
                      max: 100,
                      activeColor: AppTheme.primaryCyan,
                      onChanged: _running
                          ? null
                          : (v) {
                              _arraySize = v.round();
                              _generateArray();
                            },
                    ),
                  ),
                  Text('$_arraySize',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.grey[400] : Colors.grey[700])),
                ],
              ),
              Row(
                children: [
                  Text('Speed',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[500] : Colors.grey[600])),
                  Expanded(
                    child: Slider(
                      value: _speed,
                      min: 1,
                      max: 500,
                      activeColor: const Color(0xFFFFD740),
                      onChanged: (v) {
                        _speed = v;
                        setState(() {});
                      },
                    ),
                  ),
                  Text('${_speed.round()}ms',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.grey[400] : Colors.grey[700])),
                ],
              ),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 6,
                runSpacing: 8,
                children: [
                  _presetChip('Random', 'random', isDark),
                  _presetChip('Nearly', 'nearly', isDark),
                  _presetChip('Reversed', 'reversed', isDark),
                  _presetChip('Few Unique', 'few', isDark),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _presetChip(String label, String value, bool isDark) {
    final active = _preset == value;
    return GestureDetector(
      onTap: _running
          ? null
          : () {
              _preset = value;
              _generateArray();
            },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active
              ? AppTheme.primaryCyan.withOpacity(isDark ? 0.15 : 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: active
                  ? AppTheme.primaryCyan.withOpacity(0.4)
                  : (isDark
                      ? AppTheme.darkBorder
                      : Colors.grey.withOpacity(0.2))),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active
                  ? AppTheme.primaryCyan
                  : (isDark ? Colors.grey[500] : Colors.grey[600]),
            )),
      ),
    );
  }

  Widget _buildAlgorithmList(bool isDark) {
    return Container(
      decoration: AppTheme.glassCard(isDark: isDark),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _sectionHeader('Comparison', isDark),
          ...kAlgorithms
              .where((a) => a.category == SortCategory.comparison)
              .map((a) {
            final i = kAlgorithms.indexOf(a);
            return _algorithmTile(i, isDark);
          }),
          const SizedBox(height: 8),
          _sectionHeader('Non-Comparison', isDark),
          ...kAlgorithms
              .where((a) => a.category == SortCategory.nonComparison)
              .map((a) {
            final i = kAlgorithms.indexOf(a);
            return _algorithmTile(i, isDark);
          }),
          const SizedBox(height: 8),
          _sectionHeader('Hybrid', isDark),
          ...kAlgorithms
              .where((a) => a.category == SortCategory.hybrid)
              .map((a) {
            final i = kAlgorithms.indexOf(a);
            return _algorithmTile(i, isDark);
          }),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Text(title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: isDark ? Colors.grey[600] : Colors.grey[500],
          )),
    );
  }

  Widget _algorithmTile(int i, bool isDark) {
    final selected = i == _selectedIndex;
    return GestureDetector(
      onTap: () {
        if (_running) return;
        _selectedIndex = i;
        _generateArray();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryCyan.withOpacity(isDark ? 0.12 : 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: selected
                  ? AppTheme.primaryCyan.withOpacity(0.3)
                  : Colors.transparent),
        ),
        child: Text(kAlgorithms[i].name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? AppTheme.primaryCyan
                  : (isDark ? Colors.grey[400] : Colors.grey[700]),
            )),
      ),
    );
  }

  Widget _buildComplexityPanel(bool isDark) {
    return Container(
      decoration: AppTheme.glassCard(isDark: isDark),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('COMPLEXITY',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: isDark ? Colors.grey[600] : Colors.grey[500])),
            const SizedBox(height: 12),
            ComplexityRow(
                label: 'BEST',
                value: _algo.best,
                color: const Color(0xFF69F0AE),
                isDark: isDark),
            ComplexityRow(
                label: 'AVERAGE',
                value: _algo.avg,
                color: const Color(0xFFFFD740),
                isDark: isDark),
            ComplexityRow(
                label: 'WORST',
                value: _algo.worst,
                color: const Color(0xFFFF5252),
                isDark: isDark),
            ComplexityRow(
                label: 'SPACE',
                value: _algo.space,
                color: AppTheme.primaryCyan,
                isDark: isDark),
            const SizedBox(height: 12),
            Text('RUN STATS',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: isDark ? Colors.grey[600] : Colors.grey[500])),
            const SizedBox(height: 8),
            RunStat(
                label: 'Comparisons',
                value: _comparisons,
                color: const Color(0xFFFFD740),
                isDark: isDark),
            RunStat(
                label: 'Swaps',
                value: _swaps,
                color: const Color(0xFFFF5252),
                isDark: isDark),
            RunStat(
                label: 'Accesses',
                value: _accesses,
                color: AppTheme.primaryCyan,
                isDark: isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniComplexity(bool isDark) {
    return Container(
      decoration: AppTheme.glassCard(isDark: isDark),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            MiniComplexity(
                label: 'BEST',
                value: _algo.best,
                color: const Color(0xFF69F0AE),
                isDark: isDark),
            MiniComplexity(
                label: 'AVG',
                value: _algo.avg,
                color: const Color(0xFFFFD740),
                isDark: isDark),
            MiniComplexity(
                label: 'WORST',
                value: _algo.worst,
                color: const Color(0xFFFF5252),
                isDark: isDark),
            MiniComplexity(
                label: 'SPACE',
                value: _algo.space,
                color: AppTheme.primaryCyan,
                isDark: isDark),
          ],
        ),
      ),
    );
  }
}
