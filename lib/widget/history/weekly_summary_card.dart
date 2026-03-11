import 'package:flutter/material.dart';
import 'stat_column.dart'; // 💡 อย่าลืม import ไฟล์ใหม่เข้ามาครับ

class WeeklySummaryCard extends StatelessWidget {
  final double distance;
  final int seconds;
  final double cal;
  final int count;

  const WeeklySummaryCard({
    super.key,
    required this.distance,
    required this.seconds,
    required this.cal,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final timeString = hours > 0 ? "${hours}h ${minutes}m" : "${minutes}m";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7E8CFD), Color(0xFFB599FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7E8CFD).withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "สรุปสถิติการวิ่ง",
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // 💡 เรียกใช้ StatColumn แทนฟังก์ชันเดิม
              Expanded(
                child: StatColumn(
                  label: "ระยะทางรวม",
                  value: "${distance.toStringAsFixed(1)} km",
                ),
              ),
              Expanded(
                child: StatColumn(
                  label: "เวลารวม",
                  value: timeString,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: StatColumn(
                  label: "แคลอรี่รวม",
                  value: "${cal.toInt()} kcal",
                ),
              ),
              Expanded(
                child: StatColumn(
                  label: "จำนวนกิจกรรม",
                  value: "$count ครั้ง",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}