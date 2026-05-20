// Store implementations of comparison-based sorting algorithms.

part of sort_algorithms;

// Implement basic comparison-based sorting algorithms such as BubbleSort and InsertionSort.
extension ComparisonSorts on SortAlgorithms {
  Stream<SortEvent> selectionSort(List<int> a) async* {
    _reset();
    final n = a.length;
    for (int i = 0; i < n - 1; i++) {
      int minIdx = i;
      for (int j = i + 1; j < n; j++) {
        _cmp++;
        _acc += 2;
        yield _evt(a, comp: {minIdx, j}, codeLine: 4);
        await _delay();
        if (a[j] < a[minIdx]) minIdx = j;
      }
      if (minIdx != i) {
        _swp++;
        _acc += 2;
        final tmp = a[i];
        a[i] = a[minIdx];
        a[minIdx] = tmp;
        yield _evt(a, swap: {i, minIdx}, codeLine: 6);
        await _delay();
      }
    }
  }

  Stream<SortEvent> bubbleSort(List<int> a) async* {
    _reset();
    final n = a.length;
    for (int i = 0; i < n - 1; i++) {
      bool swapped = false;
      for (int j = 0; j < n - i - 1; j++) {
        _cmp++;
        _acc += 2;
        yield _evt(a, comp: {j, j + 1}, codeLine: 4);
        await _delay();
        if (a[j] > a[j + 1]) {
          _swp++;
          _acc += 2;
          final tmp = a[j];
          a[j] = a[j + 1];
          a[j + 1] = tmp;
          swapped = true;
          yield _evt(a, swap: {j, j + 1}, codeLine: 5);
          await _delay();
        }
      }
      if (!swapped) break;
    }
  }

  Stream<SortEvent> insertionSort(List<int> a) async* {
    _reset();
    for (int i = 1; i < a.length; i++) {
      final key = a[i];
      _acc++;
      int j = i - 1;
      yield _evt(a, comp: {i}, codeLine: 4);
      await _delay();
      while (j >= 0 && a[j] > key) {
        _cmp++;
        _acc += 2;
        a[j + 1] = a[j];
        _swp++;
        yield _evt(a, swap: {j, j + 1}, codeLine: 5);
        await _delay();
        j--;
      }
      if (j >= 0) _cmp++;
      a[j + 1] = key;
      _acc++;
    }
  }

  Stream<SortEvent> cycleSort(List<int> a) async* {
    _reset();
    final n = a.length;
    for (int cs = 0; cs < n - 1; cs++) {
      int item = a[cs];
      _acc++;
      int pos = cs;
      for (int i = cs + 1; i < n; i++) {
        _cmp++;
        _acc++;
        if (a[i] < item) pos++;
      }
      if (pos == cs) continue;
      while (item == a[pos]) {
        pos++;
        _cmp++;
        _acc++;
      }
      if (pos != cs) {
        _swp++;
        _acc += 2;
        final tmp = a[pos];
        a[pos] = item;
        item = tmp;
        yield _evt(a, swap: {cs, pos}, codeLine: 7);
        await _delay();
      }
      while (pos != cs) {
        pos = cs;
        for (int i = cs + 1; i < n; i++) {
          _cmp++;
          _acc++;
          if (a[i] < item) pos++;
        }
        while (item == a[pos]) {
          pos++;
          _cmp++;
          _acc++;
        }
        if (item != a[pos]) {
          _swp++;
          _acc += 2;
          final tmp = a[pos];
          a[pos] = item;
          item = tmp;
          yield _evt(a, swap: {cs, pos}, codeLine: 7);
          await _delay();
        }
      }
    }
  }
}
