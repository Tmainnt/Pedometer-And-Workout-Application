import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pedometer_application/models/community/report.dart';
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
    final bool isCommentReport = report.commentID.isNotEmpty;
    final bool isPostReport =
        report.postId.isNotEmpty && report.commentID.isEmpty;
    final bool isUserReport = report.postId.isEmpty && report.commentID.isEmpty;

    final reportedName = report.reportedName.isEmpty
        ? 'ไม่ทราบชื่อ'
        : report.reportedName;
    final commentText = report.commentText;

    String titleText = "รายงานผู้ใช้";
    Color typeColor = Colors.deepPurple;
    IconData typeIcon = Icons.person_off;

    if (isCommentReport) {
      titleText = "รายงานคอมเมนต์";
      typeColor = Colors.orange;
      typeIcon = Icons.comment;
    } else if (isPostReport) {
      titleText = "รายงานโพสต์";
      typeColor = Colors.blue;
      typeIcon = Icons.post_add;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: typeColor, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(typeIcon, color: typeColor, size: 28),
                const SizedBox(width: 8),
                Text(
                  titleText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: typeColor,
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
            Text(
              "ผู้ถูกรายงาน: $reportedName",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),

            if (isCommentReport) ...[
              const Text(
                "ข้อความคอมเมนต์:",
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
            ],

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
                    report.detail.isEmpty ? '-' : report.detail,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ),
            ),

            if (report.postId.isNotEmpty)
              Text(
                "PostID: ${report.postId}",
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),

            const SizedBox(height: 4),
            const Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
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
                      return const Icon(Icons.block, color: Colors.grey);
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
                                onPressed: () => Navigator.pop(context, false),
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
                          final adminUid =
                              FirebaseAuth.instance.currentUser?.uid ?? '';
                          await firestoreService.banUser(
                            targetUid: report.reportedUID,
                            reportId: report.id,
                            reason: report.reason,
                            reporterId: report.reporterUID,
                            reporterName: report.reporterName,
                            detail: report.detail,
                            adminUid: adminUid,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('ระงับบัญชีสำเร็จ')),
                            );
                            await ReportService.ignoreReport(report.id);
                          }
                        }
                      },
                    );
                  },
                ),

                if (report.postId.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.visibility, color: Colors.blue),
                    tooltip: 'ดูโพสต์ต้นทาง',
                    onPressed: () async {
                      final post = await firestoreService.getOnePostById(
                        report.postId,
                      );
                      if (post == null) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('ไม่พบโพสต์ อาจถูกลบไปแล้ว'),
                            ),
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

                if (!isUserReport)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: isCommentReport ? 'ลบคอมเมนต์' : 'ลบโพสต์',
                    onPressed: () async {
                      final TextEditingController reasonController =
                          TextEditingController();

                      final resultReason = await showDialog<String>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            isCommentReport
                                ? "ยืนยันการลบคอมเมนต์"
                                : "ยืนยันการลบโพสต์",
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "คุณต้องการลบเนื้อหานี้ใช่หรือไม่?\nโปรดระบุเหตุผลในการลบ:",
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: reasonController,
                                maxLines: 2,
                                decoration: InputDecoration(
                                  hintText: 'กรอกเหตุผล...',
                                  hintStyle: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.all(10),
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, null),
                              child: const Text("ยกเลิก"),
                            ),
                            ValueListenableBuilder<TextEditingValue>(
                              valueListenable: reasonController,
                              builder: (context, value, child) {
                                final isEnabled = value.text.trim().isNotEmpty;
                                return TextButton(
                                  onPressed: isEnabled
                                      ? () => Navigator.pop(
                                          context,
                                          value.text.trim(),
                                        )
                                      : null,
                                  child: Text(
                                    "ลบ",
                                    style: TextStyle(
                                      color: isEnabled
                                          ? Colors.red
                                          : Colors.grey,
                                      fontWeight: isEnabled
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                      if (resultReason != null && resultReason.isNotEmpty) {
                        if (isCommentReport) {
                          await firestoreService.deleteComment(
                            report.postId,
                            report.commentID,
                            reason: resultReason,
                          );
                          await ReportService.ignoreReport(report.id);
                        } else if (isPostReport) {
                          await ReportService.deletePostFromReport(
                            report.id,
                            report.postId,
                          );
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('ลบเนื้อหาสำเร็จ')),
                          );
                        }
                      }
                    },
                  ),

                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  tooltip: 'เพิกเฉย / ปิดรายงาน',
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
