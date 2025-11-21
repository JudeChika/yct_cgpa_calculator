import 'dart:ui';

import 'package:flutter/material.dart';

/// A simple Sparkline widget for visualizing GPA trend
class Sparkline extends StatelessWidget {
  final List<double> values;
  final Color lineColor;
  final Color fillColor;
  final double lineWidth;

  const Sparkline({
    super.key,
    required this.values,
    required this.lineColor,
    required this.fillColor,
    this.lineWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return Center(child: Text('No data yet', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)));
    }

    return CustomPaint(
      painter: _SparklinePainter(
        values: values,
        lineColor: lineColor,
        fillColor: fillColor,
        lineWidth: lineWidth,
      ),
      child: Container(),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;
  final Color fillColor;
  final double lineWidth;

  _SparklinePainter({
    required this.values,
    required this.lineColor,
    required this.fillColor,
    required this.lineWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Define Y range (0.0 to 4.0 is typical GPA range)
    const double minY = 0.0;
    const double maxY = 4.0;
    
    if (values.length < 2) {
      // Draw a single point or horizontal line
      final y = size.height - ((values.first - minY) / (maxY - minY)) * size.height;
      canvas.drawCircle(Offset(size.width / 2, y), 4, paint..style = PaintingStyle.fill);
      return;
    }

    final path = Path();
    final fillPath = Path();

    final double stepX = size.width / (values.length - 1);

    // Start point
    double startY = size.height - ((values[0] - minY) / (maxY - minY)) * size.height;
    path.moveTo(0, startY);
    fillPath.moveTo(0, size.height); // Start bottom-left
    fillPath.lineTo(0, startY);

    for (int i = 1; i < values.length; i++) {
      double x = stepX * i;
      double y = size.height - ((values[i] - minY) / (maxY - minY)) * size.height;
      path.lineTo(x, y);
      fillPath.lineTo(x, y);
    }

    // Close fill path
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Draw fill
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    paint.style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
    
    // Draw points
    paint.style = PaintingStyle.fill;
    paint.color = lineColor;
    for (int i = 0; i < values.length; i++) {
       double x = stepX * i;
       double y = size.height - ((values[i] - minY) / (maxY - minY)) * size.height;
       canvas.drawCircle(Offset(x, y), 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
