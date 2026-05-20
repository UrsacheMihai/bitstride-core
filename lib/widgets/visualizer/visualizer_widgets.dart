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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
            color: isDark ? Colors.grey[500] : Colors.grey[600],
          )),
    );
  }
}

// Provide interface component for Complexity Row.
class ComplexityRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const ComplexityRow(
      {super.key,
      required this.label,
      required this.value,
      required this.color,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
              width: 4,
              height: 32,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                        fontWeight: FontWeight.w600)),
                Text(value,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'monospace',
                        color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Store icon, label, and value fields for an algorithm statistic display.
class RunStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final bool isDark;

  const RunStat(
      {super.key,
      required this.label,
      required this.value,
      required this.color,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : Colors.grey[600])),
          Text('$value',
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

// Render a compact complexity badge with color-coded ranking.
class MiniComplexity extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const MiniComplexity(
      {super.key,
      required this.label,
      required this.value,
      required this.color,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[500] : Colors.grey[600])),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
                color: color)),
      ],
    );
  }
}

// Provide interface component for Control Button.
class ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isDark;

  const ControlButton(
      {super.key,
      required this.icon,
      required this.label,
      required this.onTap,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.grey.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: isDark
                    ? AppTheme.darkBorder
                    : Colors.grey.withOpacity(0.15)),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 18,
                  color: isDark ? Colors.grey[400] : Colors.grey[600]),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[500] : Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }
}
