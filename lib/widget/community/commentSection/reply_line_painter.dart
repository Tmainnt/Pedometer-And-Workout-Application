import 'dart:ui';

import 'package:flutter/material.dart';

class ReplyLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(-20, -30);
    path.lineTo(-20, 15);
    path.quadraticBezierTo(-20, 25, -10, 25);
    path.lineTo(0, 25);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
