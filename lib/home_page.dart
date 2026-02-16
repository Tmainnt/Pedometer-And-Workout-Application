import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/web.dart';
import 'package:pedometer_application/services/run_repository.dart';
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
  final RunRepository _runRepository = RunRepository();

  var logger = Logger();

  bool _isSaving = false;
  bool _isTracking = false;
  double _currentDistanceKm = 0.0;
  int _currentSeconds = 0;
  String _currentPace = "0:00";

  @override
  void initState() {
    super.initState();
    _signInAnonymously();
  }

  Future<void> _signInAnonymously() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        await FirebaseAuth.instance.signInAnonymously();
      } else {
        logger.d("Login อยู่แล้ว UID: ${user.uid}");
      }
    } catch (e) {
      logger.e("Login Error: $e");
    }
  }

  void _handleToggleTracking() async {
    if (_isSaving) {
      return;
    }

    bool hasPermission = await _trackingService.checkPermission();
    if (!hasPermission) {
      if (mounted) {
        showGlobalSnackBar("กรุณาอนุญาติการเข้าถึงตำแหน่ง");
      }
      return;
    }

    if (!_isTracking) {
      _startRunning();
    } else {
      _stopAndSaveRunning();
    }
  }

  void _startRunning() {
    _trackingService.startTracking(
      onUpdate: (distance, time, pace) {
        setState(() {
          _currentDistanceKm = distance / 1000;
          _currentSeconds = time;
          _currentPace = pace;
        });
      },
    );
    setState(() => _isTracking = true);
  }

  void _stopAndSaveRunning() async {
    _trackingService.stopTracking();
    setState(() => _isTracking = false);

    if (_currentDistanceKm > 0.01) {
      Future.delayed(Duration.zero, () => _saveRunData());

    } else {
      _resetRunData();
      if (mounted) showGlobalSnackBar("ระยะทางสั้นเกินไป ไม่ได้บันทึก");
    }
  }

  Future<void> _saveRunData() async {
    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("ไม่พบผู้ใช้งาน");
      }
      double calories = _currentDistanceKm * 60;
      await _runRepository.saveRun(
        userId: user.uid,
        distance: _currentDistanceKm,
        duration: _currentSeconds,
        calories: calories,
        pace: _currentPace,
      );

      if (mounted) {
        showGlobalSnackBar(
          "บันทึกสำเร็จ! ระยะทาง ${_currentDistanceKm.toStringAsFixed(2)} กม.",
        );
        _resetRunData();
      }
    } catch (e) {
      logger.e("error saving $e");
      if (mounted) {
        showGlobalSnackBar("เกิดข้อผิดพลาด: $e");
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _resetRunData() {
    setState(() {
      _currentDistanceKm = 0.0;
      _currentSeconds = 0;
      _currentPace = "0:00";
    });
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
      onPressed: _isSaving ? null : _handleToggleTracking,
      icon: _isSaving
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(_isTracking ? Icons.pause : Icons.play_arrow, size: 40),
      label: Text(
        _isSaving
            ? "กำลังบันทึก..."
            : (_isTracking ? "หยุดชั่วคราว" : "เริ่มวิ่ง"),
      ),
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
