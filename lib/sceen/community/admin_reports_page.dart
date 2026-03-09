import 'package:flutter/material.dart';
import 'package:pedometer_application/services/firestore_service.dart';
import 'package:pedometer_application/models/community/report.dart';

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

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(
                    "เหตุผล: ${report.reason}",
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("รายละเอียด: ${report.detail}"),
                      Text("PostID: ${report.postId}"),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {
                      // ไปหน้าตรวจสอบโพสต์
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
