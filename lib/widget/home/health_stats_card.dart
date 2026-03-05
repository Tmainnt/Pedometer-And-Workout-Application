import 'package:flutter/material.dart';
import 'package:pedometer_application/widget/home/list_heath_stat_item.dart';

class HealthStatsCard extends StatelessWidget {
  // 1. รับค่า Elevation และ Steps เข้ามาแสดงผล
  final double elevation;
  final int steps;

  const HealthStatsCard({
    super.key,
    required this.elevation,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7E8CFD), Color(0xFFB599FF)],
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          ListHealthStatItem(
            icon: Icons.trending_up,
            label: "Elevation Gain",
            value: "+${elevation.toStringAsFixed(0)} m",
          ),
          const Divider(color: Colors.white54, height: 20),
          ListHealthStatItem(
            icon: Icons.directions_walk,
            label: "Steps",
            value: "$steps steps",
          ),
          const Divider(color: Colors.white54, height: 20),
          const ListHealthStatItem(
            icon: Icons.favorite_outlined,
            label: "Heart Rate",
            value: "--",
          ),
        ],
      ),
    );
  }
}