// Paint custom paths between course map nodes on the course map.

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// Course definition and initialization
class CourseMapPainter extends CustomPainter {
  final int lessonCount;
  final List<bool> completionStatuses;
  final int activeIndex;
  final Color primaryColor;
  final Color accentColor;
  final Color completedColor;
  final Color lockedColor;
  final double spacingY;
  final double amplitude;
  final double animationValue;

  CourseMapPainter({
    required this.lessonCount,
    required this.completionStatuses,
    required this.activeIndex,
    required this.primaryColor,
    required this.accentColor,
    required this.completedColor,
    required this.lockedColor,
    required this.spacingY,
    required this.amplitude,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (lessonCount <= 1) return;

    final paintLine = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;

    final paintGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

    final List<Offset> points = [];
    final double centerX = size.width / 2;

    for (int i = 0; i < lessonCount; i++) {
      final double x = centerX +
          (i % 2 == 0 ? -amplitude : amplitude) * (i == 0 ? 0.0 : 1.0);
      final double y = spacingY / 2 + i * spacingY;
      points.add(Offset(x, y));
    }

    for (int i = 0; i < lessonCount - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlPoint1 = Offset(p1.dx, p1.dy + spacingY / 2);
      final controlPoint2 = Offset(p2.dx, p2.dy - spacingY / 2);

      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          p2.dx,
          p2.dy,
        );

      final bool isSegmentDone =
          completionStatuses[i] && completionStatuses[i + 1];
      final bool isActiveSegment = i == activeIndex - 1;
      final Color segmentColor = isSegmentDone
          ? completedColor
          : (isActiveSegment ? primaryColor : lockedColor);

      if (isSegmentDone) {
        paintGlow.color = completedColor.withOpacity(0.4);
        canvas.drawPath(path, paintGlow);
      } else if (isActiveSegment) {
        paintGlow.color = primaryColor.withOpacity(0.35);
        canvas.drawPath(path, paintGlow);
      }

      if (isSegmentDone || isActiveSegment) {
        paintLine.color = segmentColor;
        canvas.drawPath(path, paintLine);
      } else {
        paintLine.color = segmentColor.withOpacity(0.5);
        final double dashWidth = 8.0;
        final double dashSpace = 8.0;
        final double phase =
            (1.0 - animationValue) * (dashWidth + dashSpace) * 4;

        for (final metric in path.computeMetrics()) {
          double distance = -(phase % (dashWidth + dashSpace));
          while (distance < metric.length) {
            double start = distance;
            double end = distance + dashWidth;
            if (start < 0) start = 0.0;
            if (end > metric.length) end = metric.length;
            if (end > start) {
              canvas.drawPath(metric.extractPath(start, end), paintLine);
            }
            distance += dashWidth + dashSpace;
          }
        }
      }

      if (isSegmentDone || isActiveSegment) {
        final pathMetrics = path.computeMetrics();
        for (final metric in pathMetrics) {
          for (int p = 0; p < 2; p++) {
            final double progress = (animationValue + p * 0.5) % 1.0;
            final tangent =
                metric.getTangentForOffset(metric.length * progress);
            if (tangent != null) {
              final Offset position = tangent.position;
              final Paint particlePaint = Paint()
                ..color = isSegmentDone
                    ? completedColor.withOpacity(0.8)
                    : primaryColor.withOpacity(0.9)
                ..style = PaintingStyle.fill
                ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

              canvas.drawCircle(position, 8.0, particlePaint);

              final Paint corePaint = Paint()
                ..color = Colors.white
                ..style = PaintingStyle.fill;
              canvas.drawCircle(position, 2.5, corePaint);
            }
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CourseMapPainter oldDelegate) {
    return oldDelegate.lessonCount != lessonCount ||
        oldDelegate.activeIndex != activeIndex ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.completedColor != completedColor ||
        oldDelegate.spacingY != spacingY ||
        oldDelegate.amplitude != amplitude ||
        oldDelegate.animationValue != animationValue ||
        !listEquals(oldDelegate.completionStatuses, completionStatuses);
  }
}
