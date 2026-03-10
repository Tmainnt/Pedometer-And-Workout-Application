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

    if (user == null) {
      return const Scaffold(body: Center(child: Text("กรุณาเข้าสู่ระบบ")));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const PedometerAppBar(title: 'ประวัติการวิ่ง'),
      // 🟢 1. StreamBuilder ชั้นนอก: ดึงข้อมูลรวมจาก User Document
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, userSnapshot) {
          
          // ดึงค่าสถิติรวมออกมา (ใช้ .toDouble() และ .toInt() ป้องกัน Error จาก Firestore)
          Map<String, dynamic> userData = {};
          if (userSnapshot.hasData && userSnapshot.data!.exists) {
            userData = userSnapshot.data!.data() as Map<String, dynamic>;
          }

          double dist = (userData['user_total_distance'] ?? 0).toDouble();
          int dur = (userData['user_total_time'] ?? 0).toInt();
          double cal = (userData['user_total_calories'] ?? 0).toDouble();
          int runsCount = (userData['user_total_runs'] ?? 0).toInt();

          // 🟢 2. StreamBuilder ชั้นใน: ดึงรายการประวัติวิ่งแบบเดิม
          return StreamBuilder<QuerySnapshot>(
            stream: repo.getUserRuns(user.uid),
            builder: (context, runSnapshot) {
              if (runSnapshot.hasError) return Center(child: Text("Error: ${runSnapshot.error}"));
              if (runSnapshot.connectionState == ConnectionState.waiting && !userSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final docs = runSnapshot.hasData ? runSnapshot.data!.docs : [];

              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🟢 3. ส่งค่าที่ดึงมาจาก User Document เข้า Summary Card ตรงๆ ไม่ต้องวนลูปแล้ว!
                          WeeklySummaryCard(
                            distance: dist, 
                            seconds: dur, 
                            cal: cal, 
                            count: runsCount > 0 ? runsCount : docs.length // เผื่อกรณี user_total_runs ยังไม่มีค่า
                          ),
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
          );
        },
      ),
    );
  }
}