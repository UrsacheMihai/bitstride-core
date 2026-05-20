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

  Stream<SortEvent> _heapSegment(List<int> a, int lo, int hi) async* {
    final n = hi - lo + 1;
    final seg = a.sublist(lo, hi + 1);
    for (int i = n ~/ 2 - 1; i >= 0; i--) {
      _heapifySync(seg, n, i);
    }
    for (int i = n - 1; i > 0; i--) {
      final tmp = seg[0];
      seg[0] = seg[i];
      seg[i] = tmp;
      _swp++;
      _acc += 2;
      _heapifySync(seg, i, 0);
    }
    for (int i = 0; i < n; i++) {
      a[lo + i] = seg[i];
      _acc++;
      yield _evt(a, swap: {lo + i});
      await _delay();
    }
  }

  void _heapifySync(List<int> a, int n, int i) {
    int largest = i, l = 2 * i + 1, r = 2 * i + 2;
    if (l < n && a[l] > a[largest]) largest = l;
    if (r < n && a[r] > a[largest]) largest = r;
    if (largest != i) {
      final tmp = a[i];
      a[i] = a[largest];
      a[largest] = tmp;
      _cmp++;
      _swp++;
      _acc += 4;
      _heapifySync(a, n, largest);
    }
  }

  Stream<SortEvent> timSort(List<int> a) async* {
    _reset();
    const run = 32;
    final n = a.length;
    for (int i = 0; i < n; i += run) {
      final end = min(i + run - 1, n - 1);
      for (int j = i + 1; j <= end; j++) {
        final key = a[j];
        _acc++;
        int k = j - 1;
        while (k >= i && a[k] > key) {
          _cmp++;
          _acc += 2;
          a[k + 1] = a[k];
          _swp++;
          yield _evt(a, swap: {k, k + 1}, codeLine: -1);
          await _delay();
          k--;
        }
        if (k >= i) _cmp++;
        a[k + 1] = key;
        _acc++;
      }
    }
    for (int size = run; size < n; size *= 2) {
      for (int left = 0; left < n; left += 2 * size) {
        final mid = min(left + size - 1, n - 1);
        final right = min(left + 2 * size - 1, n - 1);
        if (mid < right) yield* _merge(a, left, mid, right);
      }
    }
  }
}
