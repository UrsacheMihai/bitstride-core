// Store linear-time distribution sorting algorithms.

part of sort_algorithms;

// Implement distribution-based sorting algorithms such as Counting, Radix, and Bucket Sort.
extension DistributionSorts on SortAlgorithms {
  Stream<SortEvent> countingSort(List<int> a) async* {
    _reset();
    if (a.isEmpty) return;
    final maxVal = a.reduce(max);
    final count = List.filled(maxVal + 1, 0);
    for (int i = 0; i < a.length; i++) {
      count[a[i]]++;
      _acc++;
      yield _evt(a, comp: {i}, codeLine: 4);
      await _delay();
    }
    int idx = 0;
    for (int i = 0; i <= maxVal; i++) {
      while (count[i] > 0) {
        a[idx] = i;
        _swp++;
        _acc++;
        yield _evt(a, swap: {idx}, codeLine: 8);
        await _delay();
        count[i]--;
        idx++;
      }
    }
  }

  Stream<SortEvent> radixSort(List<int> a) async* {
    _reset();
    if (a.isEmpty) return;
    final maxVal = a.reduce(max);
    for (int exp = 1; maxVal ~/ exp > 0; exp *= 10) {
      yield* _countByDigit(a, exp);
    }
  }

}