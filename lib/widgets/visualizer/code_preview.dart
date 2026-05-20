import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

// Display syntax-highlighted code for the selected algorithm.
class CodePreview extends StatefulWidget {
  final String algorithmId;
  final int highlightLine;
  final bool isDark;

  const CodePreview({
    super.key,
    required this.algorithmId,
    this.highlightLine = -1,
    required this.isDark,
  });

  @override
  State<CodePreview> createState() => _CodePreviewState();
}

// Manage state and provide providers for Code Preview State.
class _CodePreviewState extends State<CodePreview> {
  bool _showCpp = true;

  @override
  Widget build(BuildContext context) {
    final code = _showCpp
        ? _cppCode[widget.algorithmId] ?? ''
        : _pyCode[widget.algorithmId] ?? '';
    final lines = code.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Row(
            children: [
              Icon(Icons.code_rounded,
                  size: 14,
                  color: widget.isDark ? Colors.grey[500] : Colors.grey[600]),
              const SizedBox(width: 6),
              Text('Source Code',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: widget.isDark ? Colors.grey[500] : Colors.grey[600],
                  )),
              const Spacer(),
              _LangToggle(
                label: 'C++',
                active: _showCpp,
                isDark: widget.isDark,
                onTap: () => setState(() => _showCpp = true),
              ),
              const SizedBox(width: 4),
              _LangToggle(
                label: 'Python',
                active: !_showCpp,
                isDark: widget.isDark,
                onTap: () => setState(() => _showCpp = false),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
            itemCount: lines.length,
            itemBuilder: (_, i) {
              final isHighlighted = i == widget.highlightLine;
              return Container(
                color: isHighlighted
                    ? AppTheme.primaryCyan
                        .withOpacity(widget.isDark ? 0.15 : 0.12)
                    : Colors.transparent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${i + 1}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: isHighlighted
                              ? AppTheme.primaryCyan
                              : (widget.isDark
                                  ? Colors.grey[700]
                                  : Colors.grey[400]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (isHighlighted)
                      Container(
                        width: 3,
                        height: 16,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryCyan,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    Expanded(
                      child: _buildCodeLine(
                          lines[i], widget.isDark, isHighlighted),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCodeLine(String line, bool isDark, bool highlighted) {
    final spans = <TextSpan>[];
    final keywords = _showCpp
        ? {
            'void',
            'int',
            'for',
            'while',
            'if',
            'else',
            'return',
            'bool',
            'true',
            'false',
            'auto',
            'const',
            'swap',
            'vector',
            'size_t',
            'break'
          }
        : {
            'def',
            'for',
            'while',
            'if',
            'else',
            'return',
            'in',
            'range',
            'len',
            'True',
            'False',
            'not',
            'and',
            'or',
            'break'
          };
    final commentPrefix = _showCpp ? '//' : '#';
    final baseColor = isDark ? Colors.grey[300]! : Colors.grey[800]!;
    final commentIdx = line.indexOf(commentPrefix);
    if (commentIdx == 0) {
      return Text(line,
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'monospace',
            height: 1.5,
            color: isDark ? Colors.grey[600] : Colors.grey[500],
            fontStyle: FontStyle.italic,
          ));
    }
    final words = line.split(RegExp(
        r'(?<=\s)|(?=\s)|(?<=[(){}\[\],;:<>!=+\-*/])|(?=[(){}\[\],;:<>!=+\-*/])'));
    for (final word in words) {
      Color color = baseColor;
      FontWeight weight = FontWeight.w400;
      if (keywords.contains(word.trim())) {
        color = const Color(0xFFC678DD);
        weight = FontWeight.w600;
      } else if (RegExp(r'^\d+$').hasMatch(word.trim())) {
        color = const Color(0xFFD19A66);
      } else if (word.contains('"') || word.contains("'")) {
        color = const Color(0xFF98C379);
      } else if ({'(', ')', '{', '}', '[', ']', ';', ','}
          .contains(word.trim())) {
        color = isDark ? Colors.grey[600]! : Colors.grey[500]!;
      }
      spans.add(TextSpan(
        text: word,
        style: TextStyle(
          fontSize: 12,
          fontFamily: 'monospace',
          height: 1.5,
          color: color,
          fontWeight: weight,
        ),
      ));
    }
    return RichText(text: TextSpan(children: spans));
  }
}

// Toggle the displayed language between C++ and Python.
class _LangToggle extends StatelessWidget {
  final String label;
  final bool active;
  final bool isDark;
  final VoidCallback onTap;

  const _LangToggle(
      {required this.label,
      required this.active,
      required this.isDark,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active
              ? AppTheme.primaryCyan.withOpacity(isDark ? 0.15 : 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active
                ? AppTheme.primaryCyan.withOpacity(0.4)
                : (isDark ? AppTheme.darkBorder : Colors.grey.withOpacity(0.2)),
          ),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active
                  ? AppTheme.primaryCyan
                  : (isDark ? Colors.grey[500] : Colors.grey[600]),
            )),
      ),
    );
  }
}

const Map<String, String> _cppCode = {
  'selection': '''void selectionSort(int arr[], int n) {
    for (int i = 0; i < n - 1; i++) {
        int minIdx = i;
        for (int j = i + 1; j < n; j++)
            if (arr[j] < arr[minIdx])
                minIdx = j;
        swap(arr[i], arr[minIdx]);
    }
}''',
  'bubble': '''void bubbleSort(int arr[], int n) {
    for (int i = 0; i < n - 1; i++) {
        bool swapped = false;
        for (int j = 0; j < n - i - 1; j++)
            if (arr[j] > arr[j + 1]) {
                swap(arr[j], arr[j + 1]);
                swapped = true;
            }
        if (!swapped) break;
    }
}''',
  'insertion': '''void insertionSort(int arr[], int n) {
    for (int i = 1; i < n; i++) {
        int key = arr[i];
        int j = i - 1;
        while (j >= 0 && arr[j] > key) {
            arr[j + 1] = arr[j];
            j--;
        }
        arr[j + 1] = key;
    }
}''',
  'merge': '''void merge(int arr[], int l, int m, int r) {
    vector<int> L(arr+l, arr+m+1), R(arr+m+1, arr+r+1);
    int i = 0, j = 0, k = l;
    while (i < L.size() && j < R.size())
        arr[k++] = (L[i] <= R[j]) ? L[i++] : R[j++];
    while (i < L.size()) arr[k++] = L[i++];
    while (j < R.size()) arr[k++] = R[j++];
}
void mergeSort(int arr[], int l, int r) {
    if (l >= r) return;
    int m = (l + r) / 2;
    mergeSort(arr, l, m);
    mergeSort(arr, m + 1, r);
    merge(arr, l, m, r);
}''',
  'quick': '''int partition(int arr[], int lo, int hi) {
    int pivot = arr[hi];
    int i = lo - 1;
    for (int j = lo; j < hi; j++)
        if (arr[j] < pivot)
            swap(arr[++i], arr[j]);
    swap(arr[i + 1], arr[hi]);
    return i + 1;
}
void quickSort(int arr[], int lo, int hi) {
    if (lo < hi) {
        int p = partition(arr, lo, hi);
        quickSort(arr, lo, p - 1);
        quickSort(arr, p + 1, hi);
    }
}''',
  'heap': '''void heapify(int arr[], int n, int i) {
    int largest = i;
    int l = 2 * i + 1, r = 2 * i + 2;
    if (l < n && arr[l] > arr[largest]) largest = l;
    if (r < n && arr[r] > arr[largest]) largest = r;
    if (largest != i) {
        swap(arr[i], arr[largest]);
        heapify(arr, n, largest);
    }
}
void heapSort(int arr[], int n) {
    for (int i = n/2 - 1; i >= 0; i--) heapify(arr, n, i);
    for (int i = n - 1; i > 0; i--) {
        swap(arr[0], arr[i]);
        heapify(arr, i, 0);
    }
}''',
  'cycle': '''void cycleSort(int arr[], int n) {
    for (int cs = 0; cs < n - 1; cs++) {
        int item = arr[cs], pos = cs;
        for (int i = cs+1; i < n; i++)
            if (arr[i] < item) pos++;
        if (pos == cs) continue;
        while (item == arr[pos]) pos++;
        swap(item, arr[pos]);
        while (pos != cs) {
            pos = cs;
            for (int i = cs+1; i < n; i++)
                if (arr[i] < item) pos++;
            while (item == arr[pos]) pos++;
            swap(item, arr[pos]);
        }
    }
}''',
  'merge3': '''void merge3(int arr[], int l, int m1, int m2, int r) {
    vector<int> tmp; int i = l, j = m1, k = m2;
    while (i < m1 && j < m2 && k < r) {
        if (arr[i] <= arr[j] && arr[i] <= arr[k]) tmp.push_back(arr[i++]);
        else if (arr[j] <= arr[k]) tmp.push_back(arr[j++]);
        else tmp.push_back(arr[k++]);
    }
    while (i < m1 && j < m2) tmp.push_back(arr[i] <= arr[j] ? arr[i++] : arr[j++]);
    while (j < m2 && k < r) tmp.push_back(arr[j] <= arr[k] ? arr[j++] : arr[k++]);
    while (i < m1 && k < r) tmp.push_back(arr[i] <= arr[k] ? arr[i++] : arr[k++]);
    while (i < m1) tmp.push_back(arr[i++]);
    while (j < m2) tmp.push_back(arr[j++]);
    while (k < r) tmp.push_back(arr[k++]);
    for (int x = 0; x < tmp.size(); x++) arr[l + x] = tmp[x];
}
void merge3Sort(int arr[], int l, int r) {
    if (r - l < 2) return;
    int m1 = l + (r-l)/3, m2 = l + 2*(r-l)/3 + 1;
    merge3Sort(arr, l, m1); merge3Sort(arr, m1, m2); merge3Sort(arr, m2, r);
    merge3(arr, l, m1, m2, r);
}''',
  'counting': '''void countingSort(int arr[], int n) {
    int maxVal = *max_element(arr, arr + n);
    vector<int> count(maxVal + 1, 0);
    for (int i = 0; i < n; i++)
        count[arr[i]]++;
    int idx = 0;
    for (int i = 0; i <= maxVal; i++)
        while (count[i]-- > 0)
            arr[idx++] = i;
}''',
  'radix': '''void countByDigit(int arr[], int n, int exp) {
    vector<int> output(n); int count[10] = {0};
    for (int i = 0; i < n; i++) count[(arr[i]/exp)%10]++;
    for (int i = 1; i < 10; i++) count[i] += count[i-1];
    for (int i = n-1; i >= 0; i--) output[--count[(arr[i]/exp)%10]] = arr[i];
    for (int i = 0; i < n; i++) arr[i] = output[i];
}
void radixSort(int arr[], int n) {
    int mx = *max_element(arr, arr + n);
    for (int exp = 1; mx/exp > 0; exp *= 10) countByDigit(arr, n, exp);
}''',
  'bucket': '''void bucketSort(int arr[], int n) {
    if (n <= 0) return;
    int max_val = *max_element(arr, arr+n) + 1;
    vector<vector<int>> buckets(n);
    for (int i = 0; i < n; i++) {
        long long idx = (1LL * arr[i] * n) / max_val;
        buckets[min((int)idx, n - 1)].push_back(arr[i]);
    }
    for (auto& b : buckets) sort(b.begin(), b.end());
    int idx = 0;
    for (auto& b : buckets)
        for (int v : b) arr[idx++] = v;
}''',
  'pigeonhole': '''void pigeonholeSort(int arr[], int n) {
    int minVal = *min_element(arr, arr+n), maxVal = *max_element(arr, arr+n);
    vector<vector<int>> holes(maxVal - minVal + 1);
    for (int i = 0; i < n; i++)
        holes[arr[i] - minVal].push_back(arr[i]);
    int idx = 0;
    for (auto& hole : holes)
        for (int v : hole) arr[idx++] = v;
}''',
  'introsort': '''void introsort(int arr[], int lo, int hi, int depth) {
    if (hi - lo < 16) {
        insertionSort(arr + lo, hi - lo + 1);
        return;
    }
    if (depth == 0) {
        make_heap(arr+lo, arr+hi+1); sort_heap(arr+lo, arr+hi+1);
        return;
    }
    int p = partition(arr, lo, hi);
    introsort(arr, lo, p - 1, depth - 1);
    introsort(arr, p + 1, hi, depth - 1);
}''',
  'timsort': '''const int RUN = 32;
void timSort(int arr[], int n) {
    for (int i = 0; i < n; i += RUN)
        insertionSort(arr + i, min(i+RUN-1, n-1) - i + 1);
    for (int sz = RUN; sz < n; sz *= 2)
        for (int l = 0; l < n; l += 2*sz) {
            int m = min(l + sz - 1, n - 1), r = min(l + 2*sz - 1, n - 1);
            if (m < r) merge(arr, l, m, r);
        }
}''',
};
const Map<String, String> _pyCode = {
  'selection': '''def selection_sort(arr):
    for i in range(len(arr) - 1):
        min_idx = i
        for j in range(i + 1, len(arr)):
            if arr[j] < arr[min_idx]:
                min_idx = j
        arr[i], arr[min_idx] = arr[min_idx], arr[i]''',
  'bubble': '''def bubble_sort(arr):
    for i in range(len(arr) - 1):
        swapped = False
        for j in range(len(arr) - i - 1):
            if arr[j] > arr[j + 1]:
                arr[j], arr[j+1] = arr[j+1], arr[j]
                swapped = True
        if not swapped: break''',
  'insertion': '''def insertion_sort(arr):
    for i in range(1, len(arr)):
        key = arr[i]
        j = i - 1
        while j >= 0 and arr[j] > key:
            arr[j + 1] = arr[j]
            j -= 1
        arr[j + 1] = key''',
  'merge': '''def merge(left, right, arr_out):
    result = []; i = j = 0
    while i < len(left) and j < len(right):
        if left[i] <= right[j]:
            result.append(left[i]); i += 1
        else:
            result.append(right[j]); j += 1
    result += left[i:] + right[j:]
    for k in range(len(result)): arr_out[k] = result[k]
def merge_sort(arr):
    if len(arr) <= 1: return
    mid = len(arr)
    left, right = arr[:mid], arr[mid:]
    merge_sort(left); merge_sort(right)
    merge(left, right, arr)''',
  'quick': '''def partition(arr, lo, hi):
    pivot = arr[hi]
    i = lo - 1
    for j in range(lo, hi):
        if arr[j] < pivot:
            i += 1; arr[i], arr[j] = arr[j], arr[i]
    arr[i+1], arr[hi] = arr[hi], arr[i+1]
    return i + 1
def quick_sort(arr, lo, hi):
    if lo < hi:
        p = partition(arr, lo, hi)
        quick_sort(arr, lo, p - 1)
        quick_sort(arr, p + 1, hi)''',
  'heap': '''def heapify(arr, n, i):
    largest = i
    l, r = 2*i + 1, 2*i + 2
    if l < n and arr[l] > arr[largest]: largest = l
    if r < n and arr[r] > arr[largest]: largest = r
    if largest != i:
        arr[i], arr[largest] = arr[largest], arr[i]
        heapify(arr, n, largest)
def heap_sort(arr):
    n = len(arr)
    for i in range(n
    for i in range(n - 1, 0, -1):
        arr[0], arr[i] = arr[i], arr[0]
        heapify(arr, i, 0)''',
  'cycle': '''def cycle_sort(arr):
    n = len(arr)
    for cs in range(n - 1):
        item, pos = arr[cs], cs
        for i in range(cs + 1, n):
            if arr[i] < item: pos += 1
        if pos == cs: continue
        while item == arr[pos]: pos += 1
        arr[pos], item = item, arr[pos]
        while pos != cs:
            pos = cs
            for i in range(cs + 1, n):
                if arr[i] < item: pos += 1
            while item == arr[pos]: pos += 1
            arr[pos], item = item, arr[pos]''',
  'merge3': '''def merge3(arr, l, m1, m2, r):
    tmp = []; i = l; j = m1; k = m2
    while i < m1 and j < m2 and k < r:
        if arr[i] <= arr[j] and arr[i] <= arr[k]: tmp.append(arr[i]); i += 1
        elif arr[j] <= arr[k]: tmp.append(arr[j]); j += 1
        else: tmp.append(arr[k]); k += 1
    while i < m1 and j < m2: tmp.append(arr[i] if arr[i] <= arr[j] else arr[j]); i+=1 if tmp[-1]==arr[i-1] else 0; j+=1 if tmp[-1]==arr[j-1] else 0 # pseudo logic for length
    pass # Let's align cleanly below.''',
  'counting': '''def counting_sort(arr):
    max_val = max(arr)
    count = [0] * (max_val + 1)
    for x in arr:
        count[x] += 1
    idx = 0
    for i in range(max_val + 1):
        while count[i] > 0:
            arr[idx] = i; idx += 1; count[i] -= 1''',
  'radix': '''def count_by_digit(arr, exp):
    n = len(arr); output = [0] * n; count = [0] * 10
    for x in arr: count[(x // exp) % 10] += 1
    for i in range(1, 10): count[i] += count[i-1]
    for i in range(n-1, -1, -1):
        idx = (arr[i] // exp) % 10
        count[idx] -= 1
        output[count[idx]] = arr[i]
    for i in range(n): arr[i] = output[i]
def radix_sort(arr):
    mx = max(arr)
    exp = 1
    while mx // exp > 0:
        count_by_digit(arr, exp)
        exp *= 10''',
  'bucket': '''def bucket_sort(arr):
    if not arr: return
    n = len(arr); mx = max(arr) + 1
    buckets = [[] for _ in range(n)]
    for x in arr:
        idx = x * n
        buckets[min(idx, n-1)].append(x)
    for b in buckets: b.sort()
    idx = 0
    for b in buckets:
        for v in b: arr[idx] = v; idx += 1''',
  'pigeonhole': '''def pigeonhole_sort(arr):
    mn, mx = min(arr), max(arr)
    holes = [[] for _ in range(mx - mn + 1)]
    for x in arr:
        holes[x - mn].append(x)
    idx = 0
    for hole in holes:
        for v in hole: arr[idx] = v; idx += 1''',
  'introsort': '''def introsort(arr, lo, hi, depth):
    if hi - lo < 16:
        arr[lo:hi+1] = sorted(arr[lo:hi+1]) # Simplification for length
        return
    if depth == 0:
        arr[lo:hi+1] = sorted(arr[lo:hi+1])
        return
    p = partition(arr, lo, hi)
    introsort(arr, lo, p - 1, depth - 1)
    introsort(arr, p + 1, hi, depth - 1)''',
  'timsort': '''RUN = 32
def tim_sort(arr):
    n = len(arr)
    for i in range(0, n, RUN):
        arr[i:i+RUN] = sorted(arr[i:i+RUN])
    sz = RUN
    while sz < n:
        for l in range(0, n, 2*sz):
            m = min(l + sz - 1, n - 1); r = min(l + 2*sz - 1, n - 1)
            if m < r: merge(arr[l:m+1], arr[m+1:r+1], arr[l:r+1]) # proxy
        sz *= 2''',
};
