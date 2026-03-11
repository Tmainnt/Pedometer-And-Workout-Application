import 'package:flutter/material.dart';

import 'package:pedometer_application/widget/run_detail/simple_line_chart.dart';

class RunChartItem extends StatelessWidget {
  final String title;
  final Color lineColor;
  final List<double> data;
  final List<String> timeLabels; // 💡 เพิ่มพารามิเตอร์สำหรับเวลา

  const RunChartItem({
    super.key, 
    required this.title, 
    required this.lineColor, 
    required this.data,
    required this.timeLabels, // 💡 รับค่าจากภายนอก
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SizedBox(
            height: 110, 
            width: double.infinity, 
            child: CustomPaint(
              painter: SimpleLineChartPainter(
                color: lineColor, 
                dataPoints: data, 
                timeLabels: timeLabels, // 💡 ส่งค่าเวลาไปให้ Painter
              ),
            ),
          ),
        ],
      ),
    );
  }
}