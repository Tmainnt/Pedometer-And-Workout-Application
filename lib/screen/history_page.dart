import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pedometer_application/controller/history_controller.dart';
import 'package:pedometer_application/widget/history/pagination_bar.dart';
import 'package:pedometer_application/widget/history/history_date_filter.dart'; 
import 'package:pedometer_application/widget/history/history_list_content.dart'; 
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
                      HistoryDateFilter(controller: _controller),
                    ],
                  ),
                ),
              ),

              // 🟢 2. เรียกใช้ Widget ใหม่ตรงนี้เลย! สั้นและสะอาดสุดๆ
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
          );
        },
      ),
    );
  }
}