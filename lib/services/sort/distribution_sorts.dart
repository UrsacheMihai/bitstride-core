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

  Stream<SortEvent> _countByDigit(List<int> a, int exp) async* {
    final n = a.length;
    final output = List.filled(n, 0);
    final count = List.filled(10, 0);
    for (int i = 0; i < n; i++) {
      count[(a[i] ~/ exp) % 10]++;
      _acc++;
    }
    for (int i = 1; i < 10; i++) {
      count[i] += count[i - 1];
    }
    for (int i = n - 1; i >= 0; i--) {
      final digit = (a[i] ~/ exp) % 10;
      _acc++;
      output[count[digit] - 1] = a[i];
      count[digit]--;
    }
    for (int i = 0; i < n; i++) {
      a[i] = output[i];
      _swp++;
      _acc++;
      yield _evt(a, swap: {i}, codeLine: 4);
      await _delay();
    }
  }

  Stream<SortEvent> bucketSort(List<int> a) async* {
    _reset();
    if (a.isEmpty) return;
    final maxVal = a.reduce(max) + 1;
    final bucketCount = max(1, a.length ~/ 3);
    final buckets = List.generate(bucketCount, (_) => <int>[]);
    for (int i = 0; i < a.length; i++) {
      final idx = (a[i] * bucketCount ~/ maxVal).clamp(0, bucketCount - 1);
      buckets[idx].add(a[i]);
      _acc++;
      yield _evt(a, comp: {i}, codeLine: 4);
      await _delay();
    }
    int pos = 0;
    for (final bucket in buckets) {
      bucket.sort();
      for (final val in bucket) {
        a[pos] = val;
        _swp++;
        _acc++;
        yield _evt(a, swap: {pos}, codeLine: 11);
        await _delay();
        pos++;
      }
    }
  }

  Stream<SortEvent> pigeonholeSort(List<int> a) async* {
    _reset();
    if (a.isEmpty) return;
    final minVal = a.reduce(min);
    final maxVal = a.reduce(max);
    final range = maxVal - minVal + 1;
    final holes = List.generate(range, (_) => <int>[]);
    for (int i = 0; i < a.length; i++) {
      holes[a[i] - minVal].add(a[i]);
      _acc++;
      yield _evt(a, comp: {i}, codeLine: 4);
      await _delay();
    }
    int idx = 0;
    for (final hole in holes) {
      for (final val in hole) {
        a[idx] = val;
        _swp++;
        _acc++;
        yield _evt(a, swap: {idx}, codeLine: 8);
        await _delay();
        idx++;
      }
    }
  }
}
