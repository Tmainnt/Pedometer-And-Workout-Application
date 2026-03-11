import 'package:flutter/material.dart';
import 'package:pedometer_application/controller/history_controller.dart';
import 'package:pedometer_application/widget/history/history_item_list.dart';

class HistoryListContent extends StatelessWidget {
  final HistoryController controller; // 🟢 รับ Controller จากหน้าหลัก

  const HistoryListContent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final currentPageDocs = controller.currentPageDocs;

    // สถานะที่ 1: กำลังโหลด
    if (controller.isLoading) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(60.0),
            child: CircularProgressIndicator(color: Color(0xFF7E8CFD)),
          ),
        ),
      );
    }

    // สถานะที่ 2: ไม่มีข้อมูล
    if (currentPageDocs.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(40.0),
            child: Text(
              "ไม่พบประวัติการวิ่งในช่วงเวลานี้", 
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    // สถานะที่ 3: มีข้อมูล (โชว์ลิสต์)
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final data = currentPageDocs[index].data() as Map<String, dynamic>;
            return HistoryListItem(data: data);
          },
          childCount: currentPageDocs.length,
        ),
      ),
    );
  }
}