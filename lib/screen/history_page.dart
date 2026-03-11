import 'package:flutter/material.dart';
import 'package:pedometer_application/controller/history_controller.dart';
import 'package:pedometer_application/widget/history/pagination_bar.dart';
import 'package:pedometer_application/widget/history/history_list_content.dart';
import 'package:pedometer_application/widget/history/history_filter_bar.dart';
import '../widget/navbar/pedometer_app_bar.dart';
import '../widget/history/weekly_summary_card.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryController _controller = HistoryController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.user == null) {
      return const Scaffold(body: Center(child: Text("กรุณาเข้าสู่ระบบ")));
    }

    return Scaffold(
      body: CustomScrollView(
        // 🟢 ลบ StreamBuilder ของเก่าที่ครอบอยู่ทิ้งไปได้เลย
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🟢 ใช้ค่าจาก Controller ที่คำนวณสดตาม Filter
                  WeeklySummaryCard(
                    distance: _controller.filteredDistance,
                    seconds: _controller.filteredDuration,
                    cal: _controller.filteredCalories,
                    count: _controller.trueRunsCount,
                  ),
                  const SizedBox(height: 25),
                  HistoryFilterBar(controller: _controller),
                ],
              ),
            ),
          ),

          HistoryListContent(controller: _controller),

          SliverToBoxAdapter(
            child: PaginationBar(
              totalPages: _controller.totalPages,
              currentPage: _controller.currentPage,
              isLoading: _controller.isLoading,
              onPageChanged: _controller.goToPage,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}
