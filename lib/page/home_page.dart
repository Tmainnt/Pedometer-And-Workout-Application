import 'package:flutter/material.dart';
import 'package:pedometer_application/controller/home_controller.dart';
import 'package:pedometer_application/utils/run_status.dart'; // สำคัญ: ต้อง Import
import 'package:pedometer_application/widget/home/health_stats_card.dart';
import 'package:pedometer_application/widget/home/main_tracking_card.dart';
import 'package:pedometer_application/widget/home/run_action_button.dart';
import 'package:pedometer_application/widget/home/running_overlay.dart';
import 'package:pedometer_application/widget/navbar/pedometer_app_bar.dart';
import 'package:pedometer_application/widget/home/running_map_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final HomeController _controller = HomeController();

  @override
  void initState() {
    super.initState();
    _controller.signInAnonymously();
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
    // เช็คสถานะการวิ่งเพื่อสลับ UI
    final bool isRunning =
        _controller.runStatus == RunStatus.running ||
        _controller.runStatus == RunStatus.paused;

    // หาความสูงของหน้าจอเพื่อใช้คำนวณจุดซ่อน/แสดงของ Animation
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      // ซ่อน AppBar เมื่อวิ่ง (จะถูกแทนที่ด้วยพื้นที่แผนที่เต็มจอ)
      appBar: isRunning
          ? null
          : const PedometerAppBar(title: 'Pedometer', subtitle: '& Workout'),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ------------------------------------------------------------------
          // เลเยอร์ที่ 1: หน้าจอปกติ (ให้จางหายไปอย่างนุ่มนวลตอนเริ่มวิ่ง)
          // ------------------------------------------------------------------
          AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            opacity: isRunning ? 0.0 : 1.0,
            child: IgnorePointer(
              // ป้องกันการเผลอกดโดนปุ่มตอนที่เลเยอร์นี้ล่องหนอยู่
              ignoring: isRunning, 
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    MainTrackingCard(
                      distance: _controller.currentDistanceKm,
                      pace: double.tryParse(
                            _controller.currentPace.replaceAll(':', '.'),
                          ) ??
                          0.0,
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
            ),
          ),

          // ------------------------------------------------------------------
          // เลเยอร์ที่ 2: แผนที่ (สไลด์ลงมาจากขอบจอด้านบน)
          // ------------------------------------------------------------------
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic, // ทำให้การเคลื่อนที่ลื่นไหล
            // ถ้าไม่ได้วิ่ง ให้ลอยอยู่เหนือหน้าจอ (-screenHeight)
            top: isRunning ? 0 : -screenHeight,
            bottom: isRunning ? 0 : screenHeight,
            left: 0,
            right: 0,
            child: RunningMapCard(
              polylines: _controller.polylines,
              currentPosition: _controller.currentLatLng,
              // ให้เป็นโหมดเต็มจอตลอดเวลาเพื่อรองรับการสไลด์
              isFullScreen: true, 
            ),
          ),

          // ------------------------------------------------------------------
          // เลเยอร์ที่ 3: แถบ Overlay สีม่วง (สไลด์ขึ้นมาจากขอบจอด้านล่าง)
          // ------------------------------------------------------------------
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            // ถ้าไม่ได้วิ่ง ให้ซ่อนอยู่ใต้ขอบจอด้านล่าง (-500)
            bottom: isRunning ? 0 : -500, 
            left: 0,
            right: 0,
            child: RunningOverlay(
              distance: _controller.currentDistanceKm,
              pace: double.tryParse(
                    _controller.currentPace.replaceAll(':', '.'),
                  ) ??
                  0.0,
              totalSeconds: _controller.currentSeconds,
              runStatus: _controller.runStatus,
              isSaving: _controller.isSaving,
              onStart: _controller.startRunning,
              onPause: _controller.pauseRunning,
              onResume: _controller.resumeRunning,
              onStop: _controller.stopAndSaveRunning,
            ),
          ),
        ],
      ),
    );
  }
}