import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 🟢 อย่าลืม import
import 'package:pedometer_application/utils/run_status.dart';
import 'package:pedometer_application/widget/home/health_stats_card.dart';
import 'package:pedometer_application/widget/home/main_tracking_card.dart';
import 'package:pedometer_application/widget/home/run_action_button.dart';
import 'package:pedometer_application/widget/home/running_overlay.dart';
import 'package:pedometer_application/widget/home/running_map_card.dart';

// 🟢 Import Provider ของคุณให้ถูก path นะครับ
import 'package:pedometer_application/provider/home_provider.dart'; 

class HomePage extends ConsumerWidget {
  final Function(bool)? onRunningStateChanged;

  const HomePage({super.key, this.onRunningStateChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🟢 1. ดึงแค่ Notifier มาเตรียมไว้เรียกฟังก์ชัน (ไม่ทำให้หน้าจออัปเดต)
    final notifier = ref.read(homeProvider.notifier);

    // 🟢 2. ดักฟัง Event เปลี่ยนแปลงสถานะ (เพื่อส่งกลับไปให้ MainWrapper ซ่อน NavBar)
    ref.listen(homeProvider.select((s) => s.runStatus), (previous, current) {
      final bool isRunning = current == RunStatus.running || current == RunStatus.paused;
      onRunningStateChanged?.call(isRunning);
    });

    // 🟢 3. ดึงเฉพาะสถานะ "การวิ่ง" มาคุม Layout หลัก 
    // (ตัวแปรนี้จะเปลี่ยนแค่ตอนกดปุ่ม Start/Stop หน้าจอหลักจึงถูกวาดใหม่แค่ตอนกดปุ่ม)
    final runStatus = ref.watch(homeProvider.select((s) => s.runStatus));
    final bool isRunning = runStatus == RunStatus.running || runStatus == RunStatus.paused;

    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ------------------------------------------------------------------
          // เลเยอร์ที่ 1: หน้าจอปกติ
          // ------------------------------------------------------------------
          AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            opacity: isRunning ? 0.0 : 1.0,
            child: IgnorePointer(
              ignoring: isRunning,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 🎯 ใช้ Consumer ครอบ MainTrackingCard ให้อัปเดตแค่ตรงนี้ทุกวินาที
                    Consumer(
                      builder: (context, ref, child) {
                        final currentDistance = ref.watch(homeProvider.select((s) => s.currentDistanceKm));
                        final dailyDistance = ref.watch(homeProvider.select((s) => s.dailyDistanceKm));
                        final paceStr = ref.watch(homeProvider.select((s) => s.currentPace));
                        final currentSec = ref.watch(homeProvider.select((s) => s.currentSeconds));
                        final dailySec = ref.watch(homeProvider.select((s) => s.dailySeconds));
                        final polylines = ref.watch(homeProvider.select((s) => s.polylines));
                        final currentLatLng = ref.watch(homeProvider.select((s) => s.currentLatLng));
                        final isSaving = ref.watch(homeProvider.select((s) => s.isSaving));

                        return MainTrackingCard(
                          distance: isRunning ? currentDistance : dailyDistance,
                          pace: isRunning ? (double.tryParse(paceStr.replaceAll(':', '.')) ?? 0.0) : 0.0,
                          totalSeconds: isRunning ? currentSec : dailySec,
                          polylines: polylines,
                          currentPosition: currentLatLng,
                          actionButton: RunActionButtons(
                            runStatus: runStatus,
                            isSaving: isSaving,
                            onStart: notifier.startRunning,
                            onPause: notifier.pauseRunning,
                            onResume: notifier.resumeRunning,
                            onStop: notifier.stopAndSaveRunning,
                          ),
                          isRunning: isRunning,
                        );
                      },
                    ),
                    
                    // 🎯 ใช้ Consumer ครอบ HealthStatsCard 
                    Consumer(
                      builder: (context, ref, child) {
                        final elevation = ref.watch(homeProvider.select((s) => s.currentElevationGain));
                        final currentSteps = ref.watch(homeProvider.select((s) => s.currentSteps));
                        final dailySteps = ref.watch(homeProvider.select((s) => s.dailySteps));

                        return HealthStatsCard(
                          elevation: elevation,
                          steps: isRunning ? currentSteps : dailySteps,
                        );
                      },
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
            curve: Curves.easeInOutCubic,
            top: isRunning ? 0 : -screenHeight,
            bottom: isRunning ? 0 : screenHeight,
            left: 0,
            right: 0,
            // 🎯 ใช้ Consumer ครอบแผนที่ ให้อัปเดตแค่ตอนพิกัด/เส้นทางเปลี่ยน
            child: Consumer(
              builder: (context, ref, child) {
                final polylines = ref.watch(homeProvider.select((s) => s.polylines));
                final currentLatLng = ref.watch(homeProvider.select((s) => s.currentLatLng));

                return RunningMapCard(
                  polylines: polylines,
                  currentPosition: currentLatLng,
                  isFullScreen: true,
                );
              },
            ),
          ),

          // ------------------------------------------------------------------
          // เลเยอร์ที่ 3: แถบ Overlay สีม่วง (สไลด์ขึ้นมาจากขอบจอด้านล่าง)
          // ------------------------------------------------------------------
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            bottom: isRunning ? 0 : -500,
            left: 0,
            right: 0,
            // 🎯 ใช้ Consumer ครอบ Overlay ให้ตัวเลขเวลา/ระยะทางวิ่งเฉพาะตรงนี้
            child: Consumer(
              builder: (context, ref, child) {
                final distance = ref.watch(homeProvider.select((s) => s.currentDistanceKm));
                final paceStr = ref.watch(homeProvider.select((s) => s.currentPace));
                final seconds = ref.watch(homeProvider.select((s) => s.currentSeconds));
                final isSaving = ref.watch(homeProvider.select((s) => s.isSaving));

                return RunningOverlay(
                  isRunning: isRunning,
                  distance: distance,
                  pace: double.tryParse(paceStr.replaceAll(':', '.')) ?? 0.0,
                  totalSeconds: seconds,
                  runStatus: runStatus,
                  isSaving: isSaving,
                  onStart: notifier.startRunning,
                  onPause: notifier.pauseRunning,
                  onResume: notifier.resumeRunning,
                  onStop: notifier.stopAndSaveRunning,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}