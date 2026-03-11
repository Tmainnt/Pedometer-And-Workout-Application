import 'package:flutter/material.dart';
import 'package:pedometer_application/controller/run_detail_controller.dart';
import 'package:pedometer_application/widget/navbar/pedometer_app_bar.dart';
import 'package:pedometer_application/widget/run_detail/run_bottom_stat_item.dart';
import 'package:pedometer_application/widget/run_detail/run_chart_item.dart';
import 'package:pedometer_application/widget/run_detail/run_detail_map.dart';
import 'package:pedometer_application/widget/run_detail/run_summary_card.dart';

class RunDetailPage extends StatelessWidget {
  final Map<String, dynamic> runData;
  const RunDetailPage({super.key, required this.runData});

  @override
  Widget build(BuildContext context) {
    // 💡 สร้าง instance ของ controller เพื่อใช้งาน
    final controller = RunDetailController(runData);

    return Scaffold(
      appBar: const PedometerAppBar(
        title: 'รายละเอียดการวิ่ง',
        isDetailPage: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // เรียกใช้ข้อมูลผ่าน controller ทั้งหมด
            RunDetailMap(points: controller.polylinePoints),

            Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    RunSummaryCard(
                      distance: controller.distance,
                      time: controller.timeStr,
                      cal: controller.calories,
                      pace: controller.averagePace,
                    ),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Expanded(
                          child: RunChartItem(
                            title: "เพซ (min/km)",
                            lineColor: Colors.blue,
                            data: controller.paceData,
                            timeLabels: controller.generateTimeLabels(
                              (runData['duration'] ?? 0) as int,
                              controller.paceData.length,
                            ),
                          ),
                        ),
                       
                      ],
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RunBottomStatItem(
                          label: "เพซสูงสุด",
                          value: controller.maxPaceStr,
                          unit: "min/km",
                        ),
                        RunBottomStatItem(
                          label: "ก้าวเดิน",
                          value: "${controller.steps}",
                          unit: "ก้าว",
                        ),
                        RunBottomStatItem(
                          label: "ความสูงเพิ่มขึ้น",
                          value: "${controller.elevationGain}",
                          unit: "m",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
