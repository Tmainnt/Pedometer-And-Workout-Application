import 'package:flutter/material.dart';
import 'package:pedometer_application/utils/run_status.dart';

class RunActionButtons extends StatelessWidget {
  final RunStatus runStatus;
  final bool isSaving;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  const RunActionButtons({
    super.key,
    required this.runStatus,
    required this.isSaving,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    // กรณีที่ยังไม่ได้เริ่มวิ่ง
    if (runStatus == RunStatus.notStart) {
      return Center(
        child: SizedBox(
          width: 200,
          height: 60,
          child: ElevatedButton.icon(
            onPressed: onStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF7E8CFD),
            ),
            label: const Text(
              "เริ่มวิ่ง",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            icon: const Icon(Icons.play_arrow, size: 30),
          ),
        ),
      );
    }

    // กรณีที่กำลังวิ่งอยู่ หรือกดหยุดพักไว้
    return Row(
      children: [
        // ปุ่มหยุดชั่วคราว / วิ่งต่อ
        Expanded(
          child: SizedBox(
            height: 60,
            child: ElevatedButton.icon(
              onPressed: runStatus == RunStatus.running ? onPause : onResume,
              label: Text(
                runStatus == RunStatus.running ? 'หยุดชั่วคราว' : 'วิ่งต่อ',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              icon: Icon(
                runStatus == RunStatus.running ? Icons.pause : Icons.play_arrow,
                size: 28,
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 15), // ใช้ SizedBox แทนระยะห่างเดิม

        // ปุ่มบันทึกผล
        Expanded(
          child: SizedBox(
            height: 60,
            child: ElevatedButton.icon(
              onPressed: isSaving ? null : onStop,
              label: Text(
                isSaving ? "กำลังบันทึก..." : "บันทึกผล",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA500),
                foregroundColor: Colors.white,
              ),
              icon: isSaving
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
}