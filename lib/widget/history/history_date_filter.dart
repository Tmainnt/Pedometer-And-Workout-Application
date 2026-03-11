import 'package:flutter/material.dart';
import 'package:pedometer_application/controller/history_controller.dart';

class HistoryDateFilter extends StatelessWidget {
  final HistoryController controller; // 🟢 รับ Controller มาจากหน้าหลัก

  const HistoryDateFilter({super.key, required this.controller});

  // 🟢 ย้าย Logic จัดรูปแบบวันที่มาไว้ที่นี่
  String _getDateDisplayText() {
    if (controller.startDate == null || controller.endDate == null) {
      return "กิจกรรมล่าสุด";
    }

    String startStr =
        "${controller.startDate!.day}/${controller.startDate!.month}/${controller.startDate!.year}";
    String endStr =
        "${controller.endDate!.day}/${controller.endDate!.month}/${controller.endDate!.year}";

    return (startStr == endStr) ? "วันที่ $startStr" : "$startStr - $endStr";
  }

  // 🟢 ย้าย Logic เปิด Pop-up ปฏิทินมาไว้ที่นี่
  Future<void> _showDateRangePickerPopup(BuildContext context) async {
    DateTimeRange? initialRange;
    if (controller.startDate != null && controller.endDate != null) {
      initialRange = DateTimeRange(
        start: controller.startDate!,
        end: controller.endDate!,
      );
    }

    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF7E8CFD),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );


    if (picked != null) {
      controller.setFilterDate(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            _getDateDisplayText(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Row(
          children: [
            if (controller.startDate != null)
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.redAccent),
                tooltip: 'ดูทั้งหมด',
                onPressed: () => controller.setFilterDate(null, null),
              ),
            IconButton(
              icon: const Icon(Icons.calendar_month, color: Color(0xFF7E8CFD)),
              tooltip: 'เลือกช่วงเวลา',
              onPressed: () => _showDateRangePickerPopup(context),
            ),
          ],
        ),
      ],
    );
  }
}
