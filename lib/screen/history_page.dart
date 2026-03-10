import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pedometer_application/controller/history_controller.dart'; // อย่าลืม Import Controller นะครับ
import 'package:pedometer_application/widget/history/history_item_list.dart';
import 'package:pedometer_application/widget/history/pagination_bar.dart';
import '../widget/navbar/pedometer_app_bar.dart';
import '../widget/history/weekly_summary_card.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // 🟢 เรียกใช้ Controller
  final HistoryController _controller = HistoryController();

  @override
  void initState() {
    super.initState();
    // 🟢 รอฟังการอัปเดตจาก Controller (เหมือนที่ทำใน HomePage)
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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const PedometerAppBar(title: 'ประวัติการวิ่ง'),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_controller.user!.uid)
            .snapshots(),
        builder: (context, userSnapshot) {
          
          Map<String, dynamic> userData = {};
          if (userSnapshot.hasData && userSnapshot.data!.exists) {
            userData = userSnapshot.data!.data() as Map<String, dynamic>;
          }

          double dist = (userData['user_total_distance'] ?? 0).toDouble();
          int dur = (userData['user_total_time'] ?? 0).toInt();
          double cal = (userData['user_total_calories'] ?? 0).toDouble();

          // 🟢 เรียกข้อมูลที่ผ่านการคำนวณจาก Controller แล้ว มาใช้ได้เลยทันที
          final currentPageDocs = _controller.currentPageDocs;

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WeeklySummaryCard(
                        distance: dist,
                        seconds: dur,
                        cal: cal,
                        count: _controller.trueRunsCount > 0 
                            ? _controller.trueRunsCount 
                            : _controller.allFetchedDocs.length,
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        "กิจกรรมล่าสุด",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              if (_controller.isLoading)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(60.0),
                      child: CircularProgressIndicator(color: Color(0xFF7E8CFD)),
                    ),
                  ),
                )
              else if (currentPageDocs.isEmpty)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text("ยังไม่มีประวัติการวิ่งในหน้านี้", style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final data = currentPageDocs[index].data() as Map<String, dynamic>;
                      return HistoryListItem(data: data);
                    }, childCount: currentPageDocs.length),
                  ),
                ),

              SliverToBoxAdapter(
                child: PaginationBar(
                  totalPages: _controller.totalPages,
                  currentPage: _controller.currentPage,
                  isLoading: _controller.isLoading,
                  onPageChanged: _controller.goToPage, // 🟢 โยนฟังก์ชันของ Controller เข้าไปเลย
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        },
      ),
    );
  }
}