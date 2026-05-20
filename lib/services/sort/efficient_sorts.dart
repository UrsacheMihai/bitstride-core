// Store efficient logarithmic-time sorting algorithms.

part of sort_algorithms;

// Implement efficient comparison-based sorting algorithms such as MergeSort and HeapSort.
extension EfficientSorts on SortAlgorithms {
  Stream<SortEvent> mergeSort(List<int> a) async* {
    _reset();
    yield* _mergeSortHelper(a, 0, a.length - 1);
  }

  Stream<SortEvent> _mergeSortHelper(List<int> a, int l, int r) async* {
    if (l >= r) return;
    final m = (l + r) ~/ 2;
    yield* _mergeSortHelper(a, l, m);
    yield* _mergeSortHelper(a, m + 1, r);
    yield* _merge(a, l, m, r);
  }

  Stream<SortEvent> _merge(List<int> a, int l, int m, int r) async* {
    final left = a.sublist(l, m + 1);
    final right = a.sublist(m + 1, r + 1);
    int i = 0, j = 0, k = l;
    while (i < left.length && j < right.length) {
      _cmp++;
      _acc += 2;
      yield _evt(a, comp: {l + i, m + 1 + j}, codeLine: 4);
      await _delay();
      if (left[i] <= right[j]) {
        a[k] = left[i];
        i++;
      } else {
        a[k] = right[j];
        j++;
      }
      _swp++;
      _acc++;
      yield _evt(a, swap: {k}, codeLine: -1);
      await _delay();
      k++;
    }
    while (i < left.length) {
      a[k] = left[i];
      _acc++;
      _swp++;
      yield _evt(a, swap: {k});
      await _delay();
      i++;
      k++;
    }
    while (j < right.length) {
      a[k] = right[j];
      _acc++;
      _swp++;
      yield _evt(a, swap: {k});
      await _delay();
      j++;
      k++;
    }
  }

  Stream<SortEvent> quickSort(List<int> a) async* {
    _reset();
    yield* _quickSortHelper(a, 0, a.length - 1);
  }

  Stream<SortEvent> _quickSortHelper(List<int> a, int lo, int hi) async* {
    if (lo >= hi) return;
    int pivot = a[hi];
    _acc++;
    int i = lo - 1;
    for (int j = lo; j < hi; j++) {
      _cmp++;
      _acc++;
      yield _evt(a, comp: {j, hi}, piv: hi, codeLine: 4);
      await _delay();
      if (a[j] < pivot) {
        i++;
        _swp++;
        _acc += 2;
        final tmp = a[i];
        a[i] = a[j];
        a[j] = tmp;
        yield _evt(a, swap: {i, j}, piv: hi, codeLine: 5);
        await _delay();
      }
    }
    i++;
    _swp++;
    _acc += 2;
    final tmp = a[i];
    a[i] = a[hi];
    a[hi] = tmp;
    yield _evt(a, swap: {i, hi}, codeLine: 6);
    await _delay();
    yield* _quickSortHelper(a, lo, i - 1);
    yield* _quickSortHelper(a, i + 1, hi);
  }

  Stream<SortEvent> heapSort(List<int> a) async* {
    _reset();
    final n = a.length;
    for (int i = n ~/ 2 - 1; i >= 0; i--) {
      yield* _heapify(a, n, i);
    }
    for (int i = n - 1; i > 0; i--) {
      _swp++;
      _acc += 2;
      final tmp = a[0];
      a[0] = a[i];
      a[i] = tmp;
      yield _evt(a,
          swap: {0, i},
          sorted: Set.from(List.generate(n - i, (j) => n - 1 - j)),
          codeLine: 12);
      await _delay();
      yield* _heapify(a, i, 0);
    }
  }

  Stream<SortEvent> _heapify(List<int> a, int n, int i) async* {
    int largest = i, l = 2 * i + 1, r = 2 * i + 2;
    if (l < n) {
      _cmp++;
      _acc += 2;
      if (a[l] > a[largest]) largest = l;
    }
    if (r < n) {
      _cmp++;
      _acc += 2;
      if (a[r] > a[largest]) largest = r;
    }
    if (largest != i) {
      _swp++;
      _acc += 2;
      final tmp = a[i];
      a[i] = a[largest];
      a[largest] = tmp;
      yield _evt(a, swap: {i, largest}, codeLine: 5);
      await _delay();
      yield* _heapify(a, n, largest);
    }
  }

  Stream<SortEvent> threeWayMergeSort(List<int> a) async* {
    _reset();
    yield* _threeWayHelper(a, 0, a.length);
  }

  Stream<SortEvent> _threeWayHelper(List<int> a, int lo, int hi) async* {
    if (hi - lo < 2) return;
    final mid1 = lo + (hi - lo) ~/ 3;
    final mid2 = lo + 2 * ((hi - lo) ~/ 3) + 1;
    yield* _threeWayHelper(a, lo, mid1);
    yield* _threeWayHelper(a, mid1, mid2);
    yield* _threeWayHelper(a, mid2, hi);
    yield* _mergeThree(a, lo, mid1, mid2, hi);
  }

  Stream<SortEvent> _mergeThree(
      List<int> a, int lo, int m1, int m2, int hi) async* {
    final merged = <int>[];
    int i = lo, j = m1, k = m2;
    while (i < m1 && j < m2 && k < hi) {
      _cmp += 2;
      _acc += 3;
      if (a[i] <= a[j]) {
        if (a[i] <= a[k]) {
          merged.add(a[i++]);
        } else {
          merged.add(a[k++]);
        }
      } else {
        if (a[j] <= a[k]) {
          merged.add(a[j++]);
        } else {
          merged.add(a[k++]);
        }
      }
    }
    while (i < m1 && j < m2) {
      _cmp++;
      _acc += 2;
      merged.add(a[i] <= a[j] ? a[i++] : a[j++]);
    }
    while (j < m2 && k < hi) {
      _cmp++;
      _acc += 2;
      merged.add(a[j] <= a[k] ? a[j++] : a[k++]);
    }
    while (i < m1 && k < hi) {
      _cmp++;
      _acc += 2;
      merged.add(a[i] <= a[k] ? a[i++] : a[k++]);
    }
    while (i < m1) {
      merged.add(a[i++]);
      _acc++;
    }
    while (j < m2) {
      merged.add(a[j++]);
      _acc++;
    }
    while (k < hi) {
      merged.add(a[k++]);
      _acc++;
    }
    for (int x = 0; x < merged.length; x++) {
      a[lo + x] = merged[x];
      _swp++;
      _acc++;
      yield _evt(a, swap: {lo + x}, codeLine: -1);
      await _delay();
    }
  }
}
