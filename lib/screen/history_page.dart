import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pedometer_application/widget/history/history_item_list.dart';
import '../services/run_repository.dart';
import '../widget/navbar/pedometer_app_bar.dart';
import '../widget/history/weekly_summary_card.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final repo = RunRepository();

    if (user == null) return const Scaffold(body: Center(child: Text("กรุณาเข้าสู่ระบบ")));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const PedometerAppBar(title: 'ประวัติการวิ่ง'),
      body: StreamBuilder<QuerySnapshot>(
        stream: repo.getUserRuns(user.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("ยังไม่มีประวัติการวิ่ง"));

          final docs = snapshot.data!.docs;
          
          // คำนวณยอดรวมสำหรับ Summary Card
          double dist = 0; int dur = 0; double cal = 0;
          for (var doc in docs) {
            final d = doc.data() as Map<String, dynamic>;
            dist += (d['distance'] ?? 0.0);
            dur += (d['duration'] ?? 0) as int;
            cal += (d['calories'] ?? 0.0);
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WeeklySummaryCard(distance: dist, seconds: dur, cal: cal, count: docs.length),
                      const SizedBox(height: 25),
                      const Text("กิจกรรมล่าสุด", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => HistoryListItem(data: docs[index].data() as Map<String, dynamic>),
                    childCount: docs.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          );
        },
      ),
    );
  }
}