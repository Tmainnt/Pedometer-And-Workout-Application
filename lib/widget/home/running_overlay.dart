import 'package:flutter/material.dart';
import 'package:pedometer_application/utils/run_status.dart';
import 'package:pedometer_application/widget/home/workout_header.dart';
import 'package:pedometer_application/widget/home/run_action_button.dart';

class RunningOverlay extends StatelessWidget {
  final double distance;
  final double pace;
  final int totalSeconds;
  final RunStatus runStatus;
  final bool isSaving;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  const RunningOverlay({
    super.key,
    required this.distance,
    required this.pace,
    required this.totalSeconds,
    required this.runStatus,
    required this.isSaving,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8161FF), Color(0xFFE96FFF)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            WorkoutStatsHeader(
              distance: distance,
              pace: pace,
              kcal: (distance * 60),
              totalSeconds: totalSeconds,
            ),
            const SizedBox(height: 30),
            RunActionButtons(
              runStatus: runStatus,
              isSaving: isSaving,
              onStart: onStart,
              onPause: onPause,
              onResume: onResume,
              onStop: onStop,
            ),
          ],
        ),
      ),
    );
  }
}