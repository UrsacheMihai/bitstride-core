library sort_algorithms;

import 'dart:math';
import '../../models/algorithm/algorithm_info.dart';

part 'comparison_sorts.dart';
part 'efficient_sorts.dart';
part 'distribution_sorts.dart';
part 'hybrid_sorts.dart';

// Orchestrate all sorting algorithm implementations and return step events.
class SortAlgorithms {
  int _cmp = 0, _swp = 0, _acc = 0;
  double speed;

  SortAlgorithms({this.speed = 50});

  void _reset() {
    _cmp = 0;
    _swp = 0;
    _acc = 0;
  }

  SortEvent _evt(List<int> a,
}