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