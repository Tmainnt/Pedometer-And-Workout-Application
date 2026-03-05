import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class SimpleLineChartPainter extends CustomPainter {
  final Color color;
  final List<double> dataPoints;
  // 💡 เพิ่ม List สำหรับเก็บข้อมูลเวลา (เช่น ["0:00", "1:30", "3:02"])
  final List<String> timeLabels;

  SimpleLineChartPainter({
    required this.color, 
    required this.dataPoints, 
    required this.timeLabels, // รับค่า labels เวลาเข้ามา
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    // 1. กำหนด Margin
    const double leftMargin = 35.0;
    const double bottomMargin = 25.0; // เพิ่มพื้นที่ด้านล่างเล็กน้อยสำหรับตัวเลขแกน X
    final double graphWidth = size.width - leftMargin;
    final double graphHeight = size.height - bottomMargin;

    // 2. คำนวณหาค่า Min/Max
    double minVal = dataPoints.reduce((a, b) => a < b ? a : b);
    double maxVal = dataPoints.reduce((a, b) => a > b ? a : b);

    if (minVal == maxVal) {
      maxVal += 1.0;
      minVal -= 1.0;
    }

    double padding = (maxVal - minVal) * 0.15;
    double displayMax = maxVal + padding;
    double displayMin = (minVal - padding).clamp(0.0, double.infinity);

    // 3. ฟังก์ชันพิกัด
    double getX(int index) => leftMargin + (index * (graphWidth / (dataPoints.length - 1)));
    double getY(double value) {
      double relativeValue = (value - displayMin) / (displayMax - displayMin);
      return graphHeight - (relativeValue * graphHeight * 0.9);
    }

    // 4. วาด Grid และตัวเลขแกน Y
    int divisions = 5;
    for (int i = 0; i <= divisions; i++) {
      double val = displayMin + (i * (displayMax - displayMin) / divisions);
      double y = getY(val);
      
      _drawAxisLabel(canvas, val.toStringAsFixed(1), Offset(5, y - 6));

      canvas.drawLine(
        Offset(leftMargin, y),
        Offset(size.width, y),
        Paint()..color = Colors.grey.withValues(alpha: 0.1),
      );
    }

    // 💡 5. เพิ่มการวาดตัวเลขแกน X (เวลา)
    if (timeLabels.isNotEmpty) {
      // เลือกแสดงเฉพาะจุดเริ่มต้น จุดกลาง และจุดสิ้นสุด เพื่อความสวยงาม
      List<int> indicesToShow = [0, timeLabels.length ~/ 2, timeLabels.length - 1];
      
      for (int index in indicesToShow) {
        if (index < timeLabels.length) {
          double x = getX(index);
          // วางตำแหน่งตัวเลขใต้เส้นกราฟฐาน
          _drawAxisLabel(
            canvas, 
            timeLabels[index], 
            Offset(x - 10, graphHeight + 5), // x - 10 เพื่อให้ข้อความอยู่กึ่งกลางจุด
          );
        }
      }
    }

    // 6. วาดเส้นกราฟและ Gradient
    final path = Path();
    path.moveTo(leftMargin, getY(dataPoints[0]));

    for (int i = 1; i < dataPoints.length; i++) {
      path.lineTo(getX(i), getY(dataPoints[i]));
    }

    final bgPath = Path.from(path)
      ..lineTo(getX(dataPoints.length - 1), graphHeight)
      ..lineTo(leftMargin, graphHeight)
      ..close();

    canvas.drawPath(
      bgPath,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, getY(displayMax)), 
          Offset(0, graphHeight), 
          [color.withValues(alpha: 0.3), color.withValues(alpha: 0.01)],
        )
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawAxisLabel(Canvas canvas, String text, Offset offset) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant SimpleLineChartPainter oldDelegate) =>
      oldDelegate.dataPoints != dataPoints || oldDelegate.timeLabels != timeLabels;
}