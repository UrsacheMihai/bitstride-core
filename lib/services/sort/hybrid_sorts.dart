// Store hybrid sorting algorithms like timsort and introsort.

part of sort_algorithms;

// Implement hybrid sorting algorithms such as TimSort and IntroSort.
extension HybridSorts on SortAlgorithms {
  Stream<SortEvent> introSort(List<int> a) async* {
    _reset();
    final depthLimit = (2 * (log(a.length) / log(2))).floor();
    yield* _introHelper(a, 0, a.length - 1, depthLimit);
  }

  Stream<SortEvent> _introHelper(
      List<int> a, int lo, int hi, int depth) async* {
    if (hi - lo < 16) {
      for (int i = lo + 1; i <= hi; i++) {
        final key = a[i];
        _acc++;
        int j = i - 1;
        while (j >= lo && a[j] > key) {
          _cmp++;
          _acc += 2;
          a[j + 1] = a[j];
          _swp++;
          yield _evt(a, swap: {j, j + 1}, codeLine: 5);
          await _delay();
          j--;
        }
        if (j >= lo) _cmp++;
        a[j + 1] = key;
        _acc++;
      }
      return;
    }
    if (depth == 0) {
      yield* _heapSegment(a, lo, hi);
      return;
    }
    int pivot = a[hi];
    _acc++;
    int i = lo - 1;
    for (int j = lo; j < hi; j++) {
      _cmp++;
      _acc++;
      yield _evt(a, comp: {j, hi}, piv: hi, codeLine: -1);
      await _delay();
      if (a[j] < pivot) {
        i++;
        _swp++;
        _acc += 2;
        final tmp = a[i];
        a[i] = a[j];
        a[j] = tmp;
        yield _evt(a, swap: {i, j}, codeLine: -1);
        await _delay();
      }
    }
    i++;
    _swp++;
    _acc += 2;
    final tmp = a[i];
    a[i] = a[hi];
    a[hi] = tmp;
    yield _evt(a, swap: {i, hi});
    await _delay();
    yield* _introHelper(a, lo, i - 1, depth - 1);
    yield* _introHelper(a, i + 1, hi, depth - 1);
  }
}