import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

// Provide interface component for Bar Chart Painter.
class BarChartPainter extends CustomPainter {
  final List<int> array;
  final int maxValue;
  final Set<int> comparing;
  final Set<int> swapping;
  final Set<int> sorted;
  final int? pivot;
  final bool isDark;

  BarChartPainter({
    required this.array,
    required this.maxValue,
    required this.comparing,
    required this.swapping,
    required this.sorted,
    required this.pivot,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (array.isEmpty) return;
    final n = array.length;
    final barWidth = (size.width - 8) / n;
    final maxH = size.height - 24;
    for (int i = 0; i < n; i++) {
      final h = (array[i] / maxValue) * maxH;
      final x = 4 + i * barWidth;
      final rect = Rect.fromLTWH(x, size.height - h - 4, barWidth - 1, h);
      Color color;
      if (swapping.contains(i)) {
        color = const Color(0xFFFF5252);
      } else if (comparing.contains(i)) {
        color = const Color(0xFFFFD740);
      } else if (sorted.contains(i)) {
        color = const Color(0xFF69F0AE);
      } else if (pivot != null && i == pivot) {
        color = const Color(0xFFE040FB);
      } else {
        color = isDark ? const Color(0xFF00E5FF) : const Color(0xFF00BFA5);
      }
      final paint = Paint()..color = color;
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(2));
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(BarChartPainter old) => true;
}

// Provide interface component for Stat Chip.
class StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final bool isDark;

  const StatChip(
      {super.key,
      required this.label,
      required this.value,
      required this.color,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.1 : 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color.withOpacity(0.7))),
          const SizedBox(width: 4),
          Text('$value',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}

// Provide interface component for Complexity Badge.
class ComplexityBadge extends StatelessWidget {
  final String label;
  final bool isDark;

  const ComplexityBadge({super.key, required this.label, required this.isDark});

}