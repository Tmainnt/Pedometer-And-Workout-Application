import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/web.dart';
import 'package:pedometer_application/services/run_repository.dart';
import 'package:pedometer_application/services/runtime_tracking_service.dart';
import 'package:pedometer_application/utils/show_snack_bar.dart';
import 'package:pedometer_application/widget/home/list_heath_stat_item.dart';
import 'package:pedometer_application/widget/navbar/pedometer_app_bar.dart';
import 'package:pedometer_application/widget/home/running_map_card.dart';
import 'package:pedometer_application/widget/home/workout_header.dart';

enum RunStatus { notStart, running, paused }

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
  RunStatus _runStatus = RunStatus.notStart;

  double _currentDistanceKm = 0.0;
  int _currentSeconds = 0;
  String _currentPace = "0:00";
  double _currentElevationGain = 0.0;
  int _currentSteps = 0;

  List<Map<String, double>> _currentRoute = [];
  Set<Polyline> _polylines = {};
  LatLng? _currentLatLng;

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

  void _startRunning() async {
    if (_isSaving) return;

    bool hasPermission = await _trackingService.checkPermission();
    if (!hasPermission) {
      if (mounted) {
        showGlobalSnackBar("กรุณาอนุญาติการเข้าถึงตำแหน่ง");
      }
      return;
    }

    setState(() => _runStatus = RunStatus.running);

    _trackingService.startTracking(
      onUpdate: (distance, time, pace, route, elevationGain, steps) {
        setState(() {
          _currentDistanceKm = distance / 1000;
          _currentSeconds = time;
          _currentPace = pace;
          _currentRoute = route;
          _currentElevationGain = elevationGain;
          _currentSteps = steps;

          if (route.isNotEmpty) {
            _currentLatLng = LatLng(route.last['lat']!, route.last['lng']!);

            _polylines = {
              Polyline(
                polylineId: const PolylineId('running_path'),
                points: route.map((p) => LatLng(p['lat']!, p['lng']!)).toList(),
                color: const Color(0xFF7E8CFD),
                width: 5,
                startCap: Cap.roundCap,
                endCap: Cap.roundCap,
              ),
            };
          }
        });
      },
    );
  }

  void _pauseRunning() {
    setState(() => _runStatus = RunStatus.paused);
    _trackingService.pauseTracking();
  }

  void _resumeRunning() {
    setState(() => _runStatus = RunStatus.running);
    _trackingService.resumeTracking();
  }

  void _stopAndSaveRunning() async {
    print(_currentRoute);
    _trackingService.stopTracking();
    setState(() => _runStatus = RunStatus.notStart);

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
        route: _currentRoute,
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
      _currentElevationGain = 0.0;
      _currentRoute = [];
      _polylines = {};
      _currentLatLng = null;
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
      appBar: const PedometerAppBar(title: 'Pedometer', subtitle: '& Workout'),
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
                  RunningMapCard(
                    polylines: _polylines,
                    currentPosition: _currentLatLng,
                  ),
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
    if (_runStatus == RunStatus.notStart) {
      return SizedBox(
        width: 200,
        height: 60,
        child: ElevatedButton.icon(
          onPressed: _startRunning,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
          label: const Text(
            "เริ่มวิ่ง",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          icon: const Icon(Icons.play_arrow, size: 30),
        ),
      );
    }
    return Row(
      spacing: 15,
      children: [
        Expanded(
          child: SizedBox(
            height: 60,
            child: ElevatedButton.icon(
              onPressed: _runStatus == RunStatus.running
                  ? _pauseRunning
                  : _resumeRunning,
              label: Text(
                _runStatus == RunStatus.running ? 'หยุดชั่วคราว' : 'วิ่งต่อ',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              icon: Icon(
                _runStatus == RunStatus.running
                    ? Icons.pause
                    : Icons.play_arrow,
                size: 28,
              ),
            ),
          ),
        ),

        Expanded(
          child: SizedBox(
            height: 60,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _stopAndSaveRunning,
              label: Text(
                _isSaving ? "กำลังบันทึก..." : "บันทึกผล",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA500),
                foregroundColor: Colors.white,
              ),
              icon: _isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.stop, size: 28),
            ),
          ),
        ),
      ],
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
      child: Column(
        children: [
          ListHealthStatItem(
            icon: Icons.trending_up,
            label: "Elevation Gain",
            value: "+${_currentElevationGain.toStringAsFixed(0)} m",
          ),
          const Divider(color: Colors.white54, height: 20),
          // 💡 เพิ่มส่วนแสดงจำนวนก้าวตรงนี้ครับ
          ListHealthStatItem(
            icon: Icons.directions_walk,
            label: "Steps",
            value: "$_currentSteps steps",
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
