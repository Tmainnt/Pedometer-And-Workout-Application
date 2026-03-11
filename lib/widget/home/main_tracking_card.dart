import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pedometer_application/widget/home/running_map_card.dart';
import 'package:pedometer_application/widget/home/workout_header.dart';

class MainTrackingCard extends StatelessWidget {
  // 1. ประกาศตัวแปรที่จะรับเข้ามา (Fields)
  final double distance;
  final double pace;
  final int totalSeconds;
  final Set<Polyline> polylines;
  final LatLng? currentPosition;
  final Widget actionButton; // รับปุ่มเข้ามาเป็น Widget เลยจะยืดหยุ่นที่สุด
  final bool isRunning;

  // 2. สร้าง Constructor
  const MainTrackingCard({
    super.key,
    required this.distance,
    required this.pace,
    required this.totalSeconds,
    required this.polylines,
    required this.currentPosition,
    required this.actionButton,
    required this.isRunning
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7E8CFD), Color(0xFFB599FF)],
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: const Color(0xFF7E8CFD).withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 178, 186, 250),
                    Color.fromARGB(255, 197, 179, 248),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  WorkoutStatsHeader(
                    distance: distance,
                    pace: pace,
                    kcal: (distance * 60),
                    totalSeconds: totalSeconds,
                    isRunning: isRunning,
                  ),
                  const SizedBox(height: 20),
                  RunningMapCard(
                    polylines: polylines,
                    currentPosition: currentPosition,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            actionButton, // วางปุ่มที่ส่งเข้ามาตรงนี้
          ],
        ),
      ),
    );
  }
}
