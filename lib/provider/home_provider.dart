import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pedometer_application/state/home_state.dart';
import 'package:pedometer_application/utils/run_status.dart';
import '../services/run_repository.dart';
import '../services/runtime_tracking_service.dart';
import '../utils/show_snack_bar.dart';
import 'package:logger/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import ไฟล์ HomeState ที่เราเพิ่งสร้าง

class HomeNotifier extends Notifier<HomeState> {
  final RuntimeTrackingService _trackingService = RuntimeTrackingService();
  final RunRepository _runRepository = RunRepository();
  final Logger logger = Logger();
  
  String _currentTrackingDate = "";

  @override
  HomeState build() {
    // 🟢 ทำงานแทน initState
    signInAnonymously();

    // 🟢 ทำงานแทน dispose ระบบจะสั่งหยุด GPS ให้เองเมื่อปิดหน้าจอ
    ref.onDispose(() {
      _trackingService.stopTracking();
    });

    return HomeState();
  }

  String _getTodayDateString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  Future<void> signInAnonymously() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
      await fetchDailyStats();
    } catch (e) {
      logger.e("Login Error: $e");
    }
  }

  Future<void> fetchDailyStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _currentTrackingDate = _getTodayDateString();
    try {
      final data = await _runRepository.getDailyStats(user.uid, _currentTrackingDate);
      if (data != null) {
        // 🟢 ใช้ state = state.copyWith(...) แทนการแก้ค่าตรงๆ
        state = state.copyWith(
          dailyDistanceKm: (data['distance'] ?? 0).toDouble(),
          dailySteps: data['steps'] ?? 0,
          dailyKcal: (data['kcal'] ?? 0).toDouble(),
          dailySeconds: data['seconds'] ?? 0,
        );
      } else {
        _resetDailyStatsLocally();
      }
    } catch (e) {
      logger.e("Error fetching daily stats: $e");
    }
  }

  void _resetDailyStatsLocally() {
    state = state.copyWith(
      dailyDistanceKm: 0.0,
      dailySteps: 0,
      dailyKcal: 0.0,
      dailySeconds: 0,
    );
  }

  void startRunning() async {
    if (state.isSaving) return;

    bool hasPermission = await _trackingService.checkPermission();
    if (!hasPermission) {
      showGlobalSnackBar("กรุณาอนุญาตการเข้าถึงตำแหน่ง");
      return;
    }

    state = state.copyWith(runStatus: RunStatus.running);

    _trackingService.startTracking(
      onUpdate: (distance, time, pace, route, elevationGain, steps) {
        Set<Polyline> newPolylines = state.polylines;
        LatLng? newLatLng;

        if (route.isNotEmpty) {
          newLatLng = LatLng(route.last['lat']!, route.last['lng']!);
          newPolylines = {
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

        // 🟢 อัปเดตข้อมูล Real-time
        state = state.copyWith(
          currentDistanceKm: distance / 1000,
          currentSeconds: time,
          currentPace: pace,
          currentRoute: route,
          currentElevationGain: elevationGain,
          currentSteps: steps,
          currentLatLng: newLatLng,
          polylines: newPolylines,
        );
      },
    );
  }

  void pauseRunning() {
    _trackingService.pauseTracking();
    state = state.copyWith(runStatus: RunStatus.paused);
  }

  void resumeRunning() {
    _trackingService.resumeTracking();
    state = state.copyWith(runStatus: RunStatus.running);
  }

  void stopAndSaveRunning() async {
    _trackingService.stopTracking();
    state = state.copyWith(runStatus: RunStatus.notStart);

    if (state.currentDistanceKm > 0.01) {
      saveRunData();
    } else {
      resetRunData();
      showGlobalSnackBar("ระยะทางสั้นเกินไป ไม่ได้บันทึก");
    }
  }

  Future<void> saveRunData() async {
    state = state.copyWith(isSaving: true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("ไม่พบผู้ใช้งาน");

      double calories = state.currentDistanceKm * 60;
      String today = _getTodayDateString();

      if (_currentTrackingDate != today) {
        _resetDailyStatsLocally();
        _currentTrackingDate = today;
      }

      // บวกทบเข้ากับสถิติรายวัน
      final newDailyDistance = state.dailyDistanceKm + state.currentDistanceKm;
      final newDailySteps = state.dailySteps + state.currentSteps;
      final newDailyKcal = state.dailyKcal + calories;
      final newDailySeconds = state.dailySeconds + state.currentSeconds;
      
      await _runRepository.saveRun(
        userId: user.uid,
        distance: state.currentDistanceKm,
        duration: state.currentSeconds,
        calories: calories,
        pace: state.currentPace,
        route: state.currentRoute,
        steps: state.currentSteps,
      );

      await _runRepository.updateDailyStats(
        userId: user.uid,
        dateString: today,
        distance: newDailyDistance,
        steps: newDailySteps,
        kcal: newDailyKcal,
        seconds: newDailySeconds,
      );

      showGlobalSnackBar("บันทึกสำเร็จ! ระยะทาง ${state.currentDistanceKm.toStringAsFixed(2)} กม.");

      // อัปเดต Daily Stats ที่บวกทบแล้ว และเคลียร์ข้อมูลการวิ่งรอบนี้
      state = state.copyWith(
        dailyDistanceKm: newDailyDistance,
        dailySteps: newDailySteps,
        dailyKcal: newDailyKcal,
        dailySeconds: newDailySeconds,
        isSaving: false,
        currentDistanceKm: 0.0,
        currentSeconds: 0,
        currentPace: "0:00",
        currentElevationGain: 0.0,
        currentSteps: 0,
        currentRoute: [],
        polylines: {},
        currentLatLng: null, // กำหนด null โดยการไม่ส่งค่าไป (หรือต้องปรับ copyWith ให้รองรับ null ถ้ามีปัญหา)
      );

    } catch (e) {
      logger.e("error saving $e");
      showGlobalSnackBar("เกิดข้อผิดพลาด: $e");
      state = state.copyWith(isSaving: false);
    }
  }

  void resetRunData() {
    // รีเซ็ตค่าเฉพาะรอบปัจจุบัน
    state = HomeState(
      dailyDistanceKm: state.dailyDistanceKm,
      dailySteps: state.dailySteps,
      dailyKcal: state.dailyKcal,
      dailySeconds: state.dailySeconds,
      // ค่าอื่นๆ จะกลับเป็น Default ของ constructor
    );
  }
}

// 🟢 ท่อส่งข้อมูลหลัก ประกาศเป็น Global
final homeProvider = NotifierProvider.autoDispose<HomeNotifier, HomeState>(() {
  return HomeNotifier();
});