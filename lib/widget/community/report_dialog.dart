import 'package:flutter/material.dart';
import 'package:pedometer_application/services/report_service.dart';

class ReportDialog extends StatefulWidget {
  final String postId;
  final String postOwnerId;

  const ReportDialog({
    super.key,
    required this.postId,
    required this.postOwnerId,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String selectedReason = "สแปม";
  final TextEditingController detailController = TextEditingController();

  final reasons = ["สแปม", "เนื้อหาไม่เหมาะสม", "คำพูดรุนแรง", "ข้อมูลเท็จ"];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("รายงานโพสต์"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField(
            initialValue: selectedReason,
            items: reasons.map((reason) {
              return DropdownMenuItem(value: reason, child: Text(reason));
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedReason = value!;
              });
            },
          ),

          const SizedBox(height: 10),

          TextField(
            controller: detailController,
            decoration: const InputDecoration(
              hintText: "รายละเอียดเพิ่มเติม (ไม่บังคับ)",
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("ยกเลิก"),
        ),

        ElevatedButton(
          onPressed: () async {
            await ReportService.reportPost(
              postId: widget.postId,
              postOwnerId: widget.postOwnerId,
              reason: selectedReason,
              detail: detailController.text,
            );

            Navigator.pop(context);

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("รายงานสำเร็จ")));
          },
          child: const Text("ส่งรายงาน"),
        ),
      ],
    );
  }
}
