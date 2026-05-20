// Store the name and algorithm list for a sorting category group.
enum SortCategory { comparison, nonComparison, hybrid }

// Store metadata and code snippets for a single sorting algorithm.
class AlgorithmInfo {
  final String id;
  final String name;
  final SortCategory category;
  final String best;
  final String avg;
  final String worst;
  final String space;
  final bool stable;

  const AlgorithmInfo({
    required this.id,
    required this.name,
    required this.category,
    required this.best,
    required this.avg,
    required this.worst,
    required this.space,
    required this.stable,
  });
}

// Describes a single step in a sort animation with affected indices.
class SortEvent {
  final List<int> array;
  final Set<int> comparing;
  final Set<int> swapping;
  final Set<int> sorted;
  final int? pivot;
  final int comparisons;
  final int swaps;
  final int accesses;
  final int codeLine;

  SortEvent({
    required this.array,
    this.comparing = const {},
    this.swapping = const {},
    this.sorted = const {},
    this.pivot,
    required this.comparisons,
    required this.swaps,
    required this.accesses,
    this.codeLine = -1,
  });
}

const List<AlgorithmInfo> kAlgorithms = [
  AlgorithmInfo(
      id: 'selection',
      name: 'Selection Sort',
      category: SortCategory.comparison,
      best: 'O(n²)',
      avg: 'O(n²)',
      worst: 'O(n²)',
      space: 'O(1)',
      stable: false),
  AlgorithmInfo(
      id: 'bubble',
      name: 'Bubble Sort',
      category: SortCategory.comparison,
      best: 'O(n)',
      avg: 'O(n²)',
      worst: 'O(n²)',
      space: 'O(1)',
      stable: true),
  AlgorithmInfo(
      id: 'insertion',
      name: 'Insertion Sort',
      category: SortCategory.comparison,
      best: 'O(n)',
      avg: 'O(n²)',
      worst: 'O(n²)',
      space: 'O(1)',
      stable: true),
  AlgorithmInfo(
      id: 'merge',
      name: 'Merge Sort',
      category: SortCategory.comparison,
      best: 'O(n log n)',
      avg: 'O(n log n)',
      worst: 'O(n log n)',
      space: 'O(n)',
      stable: true),
  AlgorithmInfo(
      id: 'quick',
      name: 'Quick Sort',
      category: SortCategory.comparison,
      best: 'O(n log n)',
      avg: 'O(n log n)',
      worst: 'O(n²)',
      space: 'O(log n)',
      stable: false),
  AlgorithmInfo(
      id: 'heap',
      name: 'Heap Sort',
      category: SortCategory.comparison,
      best: 'O(n log n)',
      avg: 'O(n log n)',
      worst: 'O(n log n)',
      space: 'O(1)',
      stable: false),
  AlgorithmInfo(
      id: 'cycle',
      name: 'Cycle Sort',
      category: SortCategory.comparison,
      best: 'O(n²)',
      avg: 'O(n²)',
      worst: 'O(n²)',
      space: 'O(1)',
      stable: false),
  AlgorithmInfo(
      id: 'merge3',
      name: '3-Way Merge Sort',
      category: SortCategory.comparison,
      best: 'O(n log n)',
      avg: 'O(n log n)',
      worst: 'O(n log n)',
      space: 'O(n)',
      stable: true),
  AlgorithmInfo(
      id: 'counting',
      name: 'Counting Sort',
      category: SortCategory.nonComparison,
      best: 'O(n+k)',
      avg: 'O(n+k)',
      worst: 'O(n+k)',
      space: 'O(k)',
      stable: true),
  AlgorithmInfo(
      id: 'radix',
      name: 'Radix Sort',
      category: SortCategory.nonComparison,
      best: 'O(nk)',
      avg: 'O(nk)',
      worst: 'O(nk)',
      space: 'O(n+k)',
      stable: true),
  AlgorithmInfo(
      id: 'bucket',
      name: 'Bucket Sort',
      category: SortCategory.nonComparison,
      best: 'O(n+k)',
      avg: 'O(n+k)',
      worst: 'O(n²)',
      space: 'O(n)',
      stable: true),
  AlgorithmInfo(
      id: 'pigeonhole',
      name: 'Pigeonhole Sort',
      category: SortCategory.nonComparison,
      best: 'O(n+k)',
      avg: 'O(n+k)',
      worst: 'O(n+k)',
      space: 'O(k)',
      stable: true),
  AlgorithmInfo(
      id: 'introsort',
      name: 'IntroSort',
      category: SortCategory.hybrid,
      best: 'O(n log n)',
      avg: 'O(n log n)',
      worst: 'O(n log n)',
      space: 'O(log n)',
      stable: false),
  AlgorithmInfo(
      id: 'timsort',
      name: 'TimSort',
      category: SortCategory.hybrid,
      best: 'O(n)',
      avg: 'O(n log n)',
      worst: 'O(n log n)',
      space: 'O(n)',
      stable: true),
];
