import 'package:flutter/material.dart';
import 'package:pedometer_application/controller/history_controller.dart';

class HistoryFilterBar extends StatelessWidget {
  final HistoryController controller;

  const HistoryFilterBar({super.key, required this.controller});

  String _getDateDisplayText() {
    if (controller.startDate == null || controller.endDate == null) {
      return "สถิติทั้งหมด (All Time)";
    }
    String startStr =
        "${controller.startDate!.day}/${controller.startDate!.month}/${controller.startDate!.year}";
    String endStr =
        "${controller.endDate!.day}/${controller.endDate!.month}/${controller.endDate!.year}";
    return (startStr == endStr) ? "วันที่ $startStr" : "$startStr - $endStr";
  }

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. แถบเลือกวันที่
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _getDateDisplayText(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              children: [
                if (controller.startDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.redAccent),
                    onPressed: () => controller.setFilterDate(null, null),
                  ),
                IconButton(
                  icon: const Icon(
                    Icons.calendar_month,
                    color: Color(0xFF7E8CFD),
                  ),
                  onPressed: () => _showDateRangePickerPopup(context),
                ),
              ],
            ),
          ],
        ),

        // 2. Dropdown จัดเรียง
        Row(
          children: [
            const Icon(Icons.sort, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            const Text(
              "จัดเรียงตาม:",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(width: 10),
            DropdownButton<String>(
              value: controller.sortBy,
              underline: const SizedBox(),
              style: const TextStyle(
                color: Color(0xFF7E8CFD),
                fontWeight: FontWeight.bold,
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF7E8CFD),
              ),
              items: const [
                DropdownMenuItem(value: 'timestamp', child: Text("ล่าสุด")),
                DropdownMenuItem(
                  value: 'distance',
                  child: Text("ระยะทางไกลสุด"),
                ),
                DropdownMenuItem(
                  value: 'calories',
                  child: Text("แคลอรี่มากสุด"),
                ),
                DropdownMenuItem(value: 'duration', child: Text("เวลานานสุด")),
              ],
              onChanged: (value) {
                print('value $value');
                if (value != null) controller.setSortBy(value);
              },
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 3. ปุ่ม Filter ระยะทาง
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('ทั้งหมด', 'all'),
              const SizedBox(width: 8),
              _buildFilterChip('วิ่งเบาๆ (< 5 km)', 'light'),
              const SizedBox(width: 8),
              _buildFilterChip('ระยะกลาง (5-10 km)', 'medium'),
              const SizedBox(width: 8),
              _buildFilterChip('ระยะไกล (> 10 km)', 'long'),
            ],
          ),
        ),
        const SizedBox(height: 5), // ลดระยะห่างลงนิดหน่อยให้สวย
      ],
    );
  }

  // สร้างปุ่มชิป
  Widget _buildFilterChip(String label, String value) {
    bool isSelected = controller.distanceFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF7E8CFD).withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF7E8CFD) : Colors.black54,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? const Color(0xFF7E8CFD) : Colors.grey.shade300,
        ),
      ),
      onSelected: (bool selected) {
        if (selected) controller.setDistanceFilter(value);
      },
    );
  }
}
