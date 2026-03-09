import 'package:cloud_firestore/cloud_firestore.dart';
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
    final isCommentReport = report.commentID.isNotEmpty ? true : false;
    final reportedName = report.reportedName.isEmpty
        ? 'ไม่ทราบชื่อ'
        : report.reportedName;
    final commentText = report.commentText;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isCommentReport ? Colors.orangeAccent : Colors.blueAccent,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCommentReport ? Icons.comment : Icons.post_add,
                  color: isCommentReport ? Colors.orange : Colors.blue,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  isCommentReport ? "รายงานคอมเมนต์" : "รายงานโพสต์",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Divider(),

            const SizedBox(height: 4),
            Text(
              "เหตุผล: ${report.reason}",
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            if (isCommentReport) ...[
              Text(
                "ผู้ถูกรายงาน: $reportedName",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              const Text(
                "หลักฐานคอมเมนต์:",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),

              Container(
                constraints: const BoxConstraints(maxHeight: 120),
                width: double.infinity,
                margin: const EdgeInsets.only(top: 4, bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: Text(
                      commentText.isEmpty ? '-' : commentText,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ] else ...[
              const Text(
                "รายละเอียดเพิ่มเติม:",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),

              Container(
                constraints: const BoxConstraints(maxHeight: 120),
                width: double.infinity,
                margin: const EdgeInsets.only(top: 4, bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: Text(
                      report.detail.isEmpty
                          ? 'ไม่มีรายละเอียดเพิ่มเติม'
                          : report.detail,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
              ),
            ],

            Text(
              "PostID: ${report.postId}",
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            const Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (isCommentReport)
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(report.reportedUID)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          width: 48,
                          height: 48,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }

                      bool isBanned = false;
                      if (snapshot.hasData && snapshot.data!.data() != null) {
                        final userData =
                            snapshot.data!.data() as Map<String, dynamic>;
                        isBanned = userData['is_banned'] ?? false;
                      }

                      if (isBanned) {
                        return const SizedBox.shrink();
                      }

                      return IconButton(
                        icon: const Icon(Icons.gavel, color: Colors.deepPurple),
                        tooltip: 'แบนบัญชีผู้ใช้นี้',
                        onPressed: () async {
                          final confirm = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text(
                                "ระงับบัญชีผู้ใช้",
                                style: TextStyle(color: Colors.deepPurple),
                              ),
                              content: Text(
                                "คุณต้องการแบนผู้ใช้ '$reportedName' ใช่หรือไม่? (ไม่สามารถล็อกอินได้อีก)",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("ยกเลิก"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    "แบนทันที",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await firestoreService.banUser(
                              targetUid: report.reportedUID,
                              reportId: report.id,
                              reason: report.reason,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('ระงับบัญชีสำเร็จ'),
                                ),
                              );
                            }
                          }
                        },
                      );
                    },
                  ),

                IconButton(
                  icon: const Icon(Icons.visibility, color: Colors.blue),
                  tooltip: 'ดูโพสต์ต้นทาง',
                  onPressed: () async {
                    if (report.postId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ไม่มีโพสต์แนบมา')),
                      );
                      return;
                    }
                    final post = await firestoreService.getOnePostById(
                      report.postId,
                    );
                    if (post == null) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ไม่พบโพสต์')),
                        );
                      }
                      return;
                    }
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            appBar: AppBar(title: const Text('ตรวจสอบโพสต์')),
                            body: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: CreatePosts(
                                userPost: post,
                                currentUserRole: 'admin',
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),

                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: isCommentReport ? 'ลบคอมเมนต์' : 'ลบโพสต์',
                  onPressed: () async {
                    final confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          isCommentReport
                              ? "ยืนยันการลบคอมเมนต์"
                              : "ยืนยันการลบโพสต์",
                        ),
                        content: const Text(
                          "คุณต้องการลบเนื้อหานี้และปิดรายงานใช่หรือไม่?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("ยกเลิก"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              "ลบ",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      if (isCommentReport) {
                        await firestoreService.deleteComment(
                          report.postId,
                          report.commentID,
                        );
                        await ReportService.ignoreReport(report.id);
                      } else {
                        await ReportService.deletePostFromReport(
                          report.id,
                          report.postId,
                        );
                      }
                    }
                  },
                ),

                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  tooltip: 'เพิกเฉย',
                  onPressed: () async {
                    await ReportService.ignoreReport(report.id);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
