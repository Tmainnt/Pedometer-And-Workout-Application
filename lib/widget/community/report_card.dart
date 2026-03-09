import 'package:flutter/material.dart';
import 'package:pedometer_application/models/report.dart';
import 'package:pedometer_application/services/firestore_service.dart';
import 'package:pedometer_application/services/report_service.dart';
import 'package:pedometer_application/theme/widget_colors.dart';
import 'package:pedometer_application/widget/community/create_posts.dart';

class ReportCard extends StatelessWidget {
  final ReportModel report;
  final FirestoreService firestoreService = FirestoreService();
  final WidgetColors widgetColors = WidgetColors();

  ReportCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: ListTile(
        title: Text("เหตุผล: ${report.reason}"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("รายละเอียด: ${report.detail}"),
            Text("PostID: ${report.postId}"),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility),
              onPressed: () async {
                final post = await firestoreService.getOnePostById(
                  report.postId,
                );

                if (post == null) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('ไม่พบโพสต์')));
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Pedometer',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),

                            Text(
                              '& Workout',
                              style: const TextStyle(
                                color: Colors.orangeAccent,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        centerTitle: true,
                        flexibleSpace: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: widgetColors.applicationMainTheme(),
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                        leading: Navigator.canPop(context)
                            ? IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      body: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: CreatePosts(
                          userPost: post,
                          currentUserRole: 'admin',
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("ยืนยันการลบโพสต์"),
                    content: const Text(
                      "คุณต้องการลบโพสต์นี้และปิดรายงานใช่หรือไม่?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("ยกเลิก"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("ลบ"),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await ReportService.deletePostFromReport(
                    report.id,
                    report.postId,
                  );
                }
              },
            ),

            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () async {
                await ReportService.ignoreReport(report.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
