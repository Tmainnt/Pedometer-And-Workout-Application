import 'package:flutter/material.dart';
import 'package:pedometer_application/widget/home/stat_item.dart';

class WorkoutStatsHeader extends StatelessWidget {
  final bool isRunning; // 🟢 1. รับค่าสถานะการวิ่ง
  final double distance;
  final double pace;
  final double kcal;
  final int totalSeconds;

  const WorkoutStatsHeader({
    super.key,
    required this.isRunning, // 🟢 บังคับให้ต้องส่งค่านี้เข้ามา
    required this.distance,
    required this.pace,
    required this.kcal,
    required this.totalSeconds,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🟢 2. เพิ่ม Label บอกว่าเป็นระยะทางวันนี้ (โชว์เฉพาะตอนยังไม่ได้วิ่ง)
        if (!isRunning)
          const Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Text(
              'ระยะทางวันนี้',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black54, // สีเทาเข้มให้ดูเนียนตา
              ),
            ),
          ),
        
        Text(
          '${distance.toStringAsFixed(2)} km',
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
        
        const SizedBox(height: 8), // เว้นระยะนิดนึงให้ดูสบายตา
        
        Row(
          children: [
            Expanded(
              child: StatItem(
                // 🟢 3. สลับคำว่า Pace / Pace วันนี้
                label: isRunning ? "Pace" : "Pace วันนี้",
                value: '${pace.toStringAsFixed(2)} min/km',
                icon: Icons.timer_outlined,
              ),
            ),
            Expanded(
              child: StatItem(
                // 🟢 4. สลับคำว่า kcal / kcal วันนี้
                label: isRunning ? "kcal" : "kcal วันนี้",
                value: kcal.toStringAsFixed(2),
                icon: Icons.local_fire_department_outlined,
              ),
            ),
            Expanded(
              child: StatItem(
                // 🟢 5. สลับคำว่า Duration / เวลาวันนี้
                label: isRunning ? "Duration" : "เวลาวันนี้",
                value: formatTime(totalSeconds),
                icon: Icons.access_time,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String formatTime(int totalSeconds) {
    Duration duration = Duration(seconds: totalSeconds);

    String hours = duration.inHours.toString().padLeft(2, '0');
    String minutes = duration.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    String seconds = duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }
}