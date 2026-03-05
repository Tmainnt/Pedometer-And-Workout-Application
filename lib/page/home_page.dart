import 'package:flutter/material.dart';
import 'package:pedometer_application/controller/home_controller.dart';
import 'package:pedometer_application/widget/home/health_stats_card.dart';
import 'package:pedometer_application/widget/home/main_tracking_card.dart';
import 'package:pedometer_application/widget/home/run_action_button.dart';
import 'package:pedometer_application/widget/navbar/pedometer_app_bar.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  // สร้าง Controller ไว้ที่นี่
  final HomeController _controller = HomeController();

  @override
  void initState() {
    super.initState();
    _controller.signInAnonymously();
    // ฟังการเปลี่ยนแปลงเพื่อสั่ง setState
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.stopService();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PedometerAppBar(title: 'Pedometer', subtitle: '& Workout'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            MainTrackingCard(
              distance: _controller.currentDistanceKm,
              pace: double.tryParse(_controller.currentPace.replaceAll(':', '.')) ?? 0.0,
              totalSeconds: _controller.currentSeconds,
              polylines: _controller.polylines,
              currentPosition: _controller.currentLatLng,
              actionButton: RunActionButtons(
                runStatus: _controller.runStatus,
                isSaving: _controller.isSaving,
                onStart: _controller.startRunning,
                onPause: _controller.pauseRunning,
                onResume: _controller.resumeRunning,
                onStop: _controller.stopAndSaveRunning,
              ),
            ),
            HealthStatsCard(
              elevation: _controller.currentElevationGain,
              steps: _controller.currentSteps,
            ),
          ],
        ),
      ),
    );
  }
}
