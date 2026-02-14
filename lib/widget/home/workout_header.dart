import 'package:flutter/material.dart';
import 'package:pedometer_application/widget/home/stat_item.dart';

class WorkoutStatsHeader extends StatelessWidget {
  final double distance;
  final double pace;
  final double kcal;
  final int totalSeconds;

  const WorkoutStatsHeader({
    super.key,
    required this.distance,
    required this.pace,
    required this.kcal,
    required this.totalSeconds,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$distance km',
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            StatItem(
              label: "Pace",
              value: '$pace min/km',
              icon: Icons.timer_outlined,
            ),
            StatItem(
              label: "kcal",
              value: '$kcal',
              icon: Icons.local_fire_department_outlined,
            ),
            StatItem(
              label: "Duration",
              value: formatTime(totalSeconds),
              icon: Icons.access_time,
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