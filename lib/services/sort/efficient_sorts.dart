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

}