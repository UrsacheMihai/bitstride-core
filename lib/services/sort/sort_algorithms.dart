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
      {Set<int> comp = const {},
      Set<int> swap = const {},
      Set<int> sorted = const {},
      int? piv,
      int codeLine = -1}) {
    return SortEvent(
        array: List.of(a),
        comparing: comp,
        swapping: swap,
        sorted: sorted,
        pivot: piv,
        comparisons: _cmp,
        swaps: _swp,
        accesses: _acc,
        codeLine: codeLine);
  }

  Future<void> _delay() =>
      Future.delayed(Duration(milliseconds: speed.round()));

  Stream<SortEvent> run(String id, List<int> arr) {
    switch (id) {
      case 'selection':
        return selectionSort(arr);
      case 'bubble':
        return bubbleSort(arr);
      case 'insertion':
        return insertionSort(arr);
      case 'merge':
        return mergeSort(arr);
      case 'quick':
        return quickSort(arr);
      case 'heap':
        return heapSort(arr);
      case 'cycle':
        return cycleSort(arr);
      case 'merge3':
        return threeWayMergeSort(arr);
      case 'counting':
        return countingSort(arr);
      case 'radix':
        return radixSort(arr);
      case 'bucket':
        return bucketSort(arr);
      case 'pigeonhole':
        return pigeonholeSort(arr);
      case 'introsort':
        return introSort(arr);
      case 'timsort':
        return timSort(arr);
      default:
        return bubbleSort(arr);
    }
  }
}
