import 'package:flutter/material.dart';
import 'package:pedometer_application/services/firestore_service.dart';
import 'package:pedometer_application/theme/widget_colors.dart';

class ReportUserDialog extends StatefulWidget {
  final String reportedUID;
  final String? postId;

  const ReportUserDialog({super.key, required this.reportedUID, this.postId});

  @override
  State<ReportUserDialog> createState() => _ReportUserDialogState();
}

class _ReportUserDialogState extends State<ReportUserDialog> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController _detailController = TextEditingController();
  final WidgetColors widgetColors = WidgetColors();

  String? _selectedReason;
  bool _isSubmitting = false;

  final List<String> _reportReasons = [
    'รูปโปรไฟล์หรือข้อมูลส่วนตัวไม่เหมาะสม',
    'พฤติกรรมก่อกวนหรือสแปม',
    'บัญชีปลอมหรือแอบอ้าง',
    'อื่นๆ',
  ];

  Future<void> _submitReport() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกเหตุผลการรายงาน')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await firestoreService.reportUser(
        widget.reportedUID,
        widget.postId ?? '',
        _selectedReason!,
        _detailController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ส่งรายงานสำเร็จ ขอบคุณที่ช่วยดูแลชุมชนของเรา'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _detailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Row(
        children: [
          Icon(Icons.flag, color: widgetColors.deleteWidget()),
          SizedBox(width: 10),
          Text(
            'รายงานผู้ใช้',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('โปรดเลือกเหตุผลที่คุณต้องการรายงานผู้ใช้นี้:'),
            const SizedBox(height: 10),
            ..._reportReasons.map((reason) {
              return RadioListTile<String>(
                title: Text(reason, style: const TextStyle(fontSize: 14)),
                value: reason,
                groupValue: _selectedReason,
                contentPadding: EdgeInsets.zero,
                dense: true,
                activeColor: Colors.orange,
                onChanged: (value) {
                  setState(() {
                    _selectedReason = value;
                  });
                },
              );
            }),
            const SizedBox(height: 10),
            TextField(
              controller: _detailController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'รายละเอียดเพิ่มเติม (ถ้ามี)...',
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.all(10),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: widgetColors.deleteWidget(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _isSubmitting ? null : _submitReport,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text('ส่งรายงาน', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
