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
    // 1. กรณีหน้าแรก (ยังไม่ได้เริ่ม)
    if (runStatus == RunStatus.notStart) {
      return Center(
        child: _buildStartButton(),
      );
    }

    // 2. กรณี Running หรือ Paused
    bool isPaused = runStatus == RunStatus.paused;
    // คำนวณความกว้างเป้าหมายของปุ่มบันทึก (ครึ่งหน้าจอหักลบ margin)
    double targetWidth = (MediaQuery.of(context).size.width / 2) - 40;

    return SizedBox(
      height: 60,
      child: Row(
        children: [
          // --- ปุ่มซ้าย: วิ่งต่อ หรือ หยุดชั่วคราว ---
          Expanded(
            flex: 1,
            child: _buildMainButton(
              onPressed: isPaused ? onResume : onPause,
              label: isPaused ? 'วิ่งต่อ' : 'หยุดชั่วคราว',
              icon: isPaused ? Icons.play_arrow : Icons.pause,
              color: Colors.white,
              textColor: const Color(0xFF7E8CFD),
            ),
          ),

          // --- ระยะห่างแอนิเมชันระหว่างปุ่ม ---
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            width: isPaused ? 15 : 0, 
          ),
          
          // --- ปุ่มขวา: บันทึกผล (ใช้ OverflowBox แก้ไข Layout Overflow) ---
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            // ป้องกันความกว้างติดลบชั่วคราวขณะทำ Animation
            width: isPaused ? targetWidth.clamp(0, double.infinity) : 0,
            child: OverflowBox(
              minWidth: 0,
              maxWidth: targetWidth,
              alignment: Alignment.centerLeft, // ให้ปุ่มงอกออกมาจากฝั่งซ้าย
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isPaused ? 1.0 : 0.0,
                child: SizedBox(
                  width: targetWidth,
                  child: _buildMainButton(
                    onPressed: isSaving ? null : onStop,
                    label: isSaving ? "..." : "บันทึก",
                    icon: Icons.stop,
                    color: const Color(0xFFFFA500),
                    textColor: Colors.white,
                    isLoading: isSaving,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper สร้างปุ่มหลัก
  Widget _buildMainButton({
    required VoidCallback? onPressed,
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
    bool isLoading = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        elevation: 0,
        minimumSize: const Size(0, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      icon: isLoading 
        ? const SizedBox(
            width: 20, 
            height: 20, 
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
          )
        : Icon(icon, size: 24),
      label: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label, 
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: 200, 
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onStart,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF7E8CFD),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        label: const Text(
          "เริ่มวิ่ง", 
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
        ),
        icon: const Icon(Icons.play_arrow, size: 30),
      ),
    );
  }
}