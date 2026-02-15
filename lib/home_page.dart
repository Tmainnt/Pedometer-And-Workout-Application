import 'package:flutter/material.dart';
import 'package:pedometer_application/services/runtime_tracking_service.dart';
import 'package:pedometer_application/utils/show_snack_bar.dart';
import 'package:pedometer_application/widget/home/list_heath_stat_item.dart';
import 'package:pedometer_application/widget/home/pedometer_app_bar.dart';
import 'package:pedometer_application/widget/home/running_map_card.dart';
import 'package:pedometer_application/widget/home/workout_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final RuntimeTrackingService _trackingService = RuntimeTrackingService();

  bool _isTracking = false;
  double _currentDistanceKm = 0.0;
  int _currentSeconds = 0;
  String _currentPace = "0:00";

  void _handleToggleTracking() async {
    bool hasPermission = await _trackingService.checkPermission();

    if (!hasPermission) {
      if (mounted) {
        showGlobalSnackBar("กรุณาอนุญาติการเข้าถึงตำแหน่ง");
      }
      return;
    }

    if (!_isTracking) {
      _trackingService.startTracking(
        onUpdate: (distance, time, pace) {
          setState(() {
            _currentDistanceKm = distance / 1000;
            _currentSeconds = time;
            _currentPace = pace;
          });
        },
      );
    } else {
      _trackingService.stopTracking();
    }

    setState(() => _isTracking = !_isTracking);
  }

  @override
  void dispose() {
    _trackingService.stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PedometerAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [_buildMainTrackingCard(), _buildHealthStatsCard()],
        ),
      ),
    );
  }

  Widget _buildMainTrackingCard() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFF7E8CFD), const Color(0xFFB599FF)],
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: const Color(0xFF7E8CFD).withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          spacing: 20,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(255, 178, 186, 250),
                    const Color.fromARGB(255, 197, 179, 248),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                spacing: 20,
                children: [
                  WorkoutStatsHeader(
                    distance: _currentDistanceKm,
                    pace:
                        double.tryParse(_currentPace.replaceAll(':', '.')) ??
                        0.0,
                    kcal: (_currentDistanceKm * 60),
                    totalSeconds: _currentSeconds,
                  ),
                  const RunningMapCard(),
                ],
              ),
            ),

            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return ElevatedButton.icon(
      onPressed: _handleToggleTracking,
      icon: Icon(_isTracking ? Icons.pause : Icons.play_arrow, size: 40),
      label: Text(_isTracking ? "หยุดชั่วคราว" : "เริ่มวิ่ง"),
    );
  }

  Widget _buildHealthStatsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF7E8CFD), const Color(0xFFB599FF)],
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: const Column(
        children: [
          ListHealthStatItem(
            icon: Icons.trending_up,
            label: "Elevation Gain",
            value: "+00",
          ),
          Divider(color: Colors.white54, height: 30),
          ListHealthStatItem(
            icon: Icons.favorite_outlined,
            label: "Heart Rate",
            value: "--",
          ),
        ],
      ),
    );
  }
}
