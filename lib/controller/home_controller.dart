import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/web.dart';
import 'package:pedometer_application/utils/run_status.dart';
import '../services/run_repository.dart';
import '../services/runtime_tracking_service.dart';
import '../utils/show_snack_bar.dart';


class HomeController extends ChangeNotifier {
  final RuntimeTrackingService _trackingService = RuntimeTrackingService();
  final RunRepository _runRepository = RunRepository();
  final Logger logger = Logger();

  // --- State Variables ---
  bool isSaving = false;
  RunStatus runStatus = RunStatus.notStart;

  double currentDistanceKm = 0.0;
  int currentSeconds = 0;
  String currentPace = "0:00";
  double currentElevationGain = 0.0;
  int currentSteps = 0;

  List<Map<String, double>> currentRoute = [];
  Set<Polyline> polylines = {};
  LatLng? currentLatLng;

  // --- Logic Methods ---

  Future<void> signInAnonymously() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
    } catch (e) {
      logger.e("Login Error: $e");
    }
  }

  void startRunning() async {
    if (isSaving) return;

    bool hasPermission = await _trackingService.checkPermission();
    if (!hasPermission) {
      showGlobalSnackBar("กรุณาอนุญาตการเข้าถึงตำแหน่ง");
      return;
    }

    runStatus = RunStatus.running;
    notifyListeners();

    _trackingService.startTracking(
      onUpdate: (distance, time, pace, route, elevationGain, steps) {
        currentDistanceKm = distance / 1000;
        currentSeconds = time;
        currentPace = pace;
        currentRoute = route;
        currentElevationGain = elevationGain;
        currentSteps = steps;

        if (route.isNotEmpty) {
          currentLatLng = LatLng(route.last['lat']!, route.last['lng']!);
          polylines = {
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
        notifyListeners(); // แจ้ง UI ให้อัปเดต
      },
    );
  }

  void pauseRunning() {
    runStatus = RunStatus.paused;
    _trackingService.pauseTracking();
    notifyListeners();
  }

  void resumeRunning() {
    runStatus = RunStatus.running;
    _trackingService.resumeTracking();
    notifyListeners();
  }

  void stopAndSaveRunning() async {
    _trackingService.stopTracking();
    runStatus = RunStatus.notStart;

    if (currentDistanceKm > 0.01) {
      saveRunData();
    } else {
      resetRunData();
      showGlobalSnackBar("ระยะทางสั้นเกินไป ไม่ได้บันทึก");
    }
    notifyListeners();
  }

  Future<void> saveRunData() async {
    isSaving = true;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("ไม่พบผู้ใช้งาน");

      double calories = currentDistanceKm * 60;
      await _runRepository.saveRun(
        userId: user.uid,
        distance: currentDistanceKm,
        duration: currentSeconds,
        calories: calories,
        pace: currentPace,
        route: currentRoute,
        steps: currentSteps,
      );

      showGlobalSnackBar("บันทึกสำเร็จ! ระยะทาง ${currentDistanceKm.toStringAsFixed(2)} กม.");
      resetRunData();
    } catch (e) {
      logger.e("error saving $e");
      showGlobalSnackBar("เกิดข้อผิดพลาด: $e");
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  void resetRunData() {
    currentDistanceKm = 0.0;
    currentSeconds = 0;
    currentPace = "0:00";
    currentElevationGain = 0.0;
    currentSteps = 0;
    currentRoute = [];
    polylines = {};
    currentLatLng = null;
    notifyListeners();
  }

  void stopService() {
    _trackingService.stopTracking();
  }
}