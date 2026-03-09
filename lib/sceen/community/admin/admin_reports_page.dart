import 'package:flutter/material.dart';
import 'package:pedometer_application/services/firestore_service.dart';
import 'package:pedometer_application/models/report.dart';
import 'package:pedometer_application/widget/community/report_card.dart';

class AdminReportsPage extends StatelessWidget {
  final FirestoreService firestoreService = FirestoreService();

  AdminReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("รายงานโพสต์")),
      body: StreamBuilder<List<ReportModel>>(
        stream: firestoreService.getReportsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(
              "🔥 Firebase Error: ${snapshot.error}",
            ); // สำคัญมาก! บรรทัดนี้จะให้ลิงก์เรา
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  "เกิดข้อผิดพลาด:\n${snapshot.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = snapshot.data!;

          if (reports.isEmpty) {
            return const Center(child: Text("ไม่มีรายงาน"));
          }

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];

              return ReportCard(report: report);
            },
          );
        },
      ),
    );
  }
}
