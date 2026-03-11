import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pedometer_application/services/firestore_service.dart';
import 'package:pedometer_application/theme/widget_colors.dart';

class ReportUserDialog extends StatefulWidget {
  final String reportedUID;
  final String reportedName;
  final String? reporterUID;
  final String? reporterName;
  final String? postId;
  final String? commentId;
  final String? commentText;
  final String label;

  const ReportUserDialog({
    super.key,
    required this.reportedUID,
    required this.reportedName,
    required this.label,
    this.reporterUID,
    this.reporterName,
    this.postId,
    this.commentId,
    this.commentText,
  });

  @override
  State<ReportUserDialog> createState() => _ReportUserDialogState();
}

class _ReportUserDialogState extends State<ReportUserDialog> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController _detailController = TextEditingController();
  final WidgetColors widgetColors = WidgetColors();

  String? _selectedReason;
  bool _isSubmitting = false;

  String get _dialogTitle {
    switch (widget.label) {
      case 'ban_user':
        return 'ระงับบัญชีผู้ใช้ (Ban)';
      case 'report_comment':
        return 'รายงานคอมเมนต์';
      case 'report_user':
      default:
        return 'รายงานผู้ใช้';
    }
  }

  String get _dialogSubtitle {
    switch (widget.label) {
      case 'ban_user':
        return 'โปรดระบุเหตุผลในการระงับบัญชีผู้ใช้นี้:';
      case 'report_comment':
        return 'โปรดเลือกเหตุผลที่คุณต้องการรายงานคอมเมนต์นี้:';
      case 'report_user':
      default:
        return 'โปรดเลือกเหตุผลที่คุณต้องการรายงานผู้ใช้นี้:';
    }
  }

  List<String> get _reportReasons {
    switch (widget.label) {
      case 'ban_user':
        return [
          'ละเมิดกฎของชุมชนร้ายแรง',
          'สแปมหรือหลอกลวง',
          'โพสต์เนื้อหาไม่เหมาะสม',
          'อื่นๆ',
        ];
      case 'report_comment':
        return [
          'ใช้คำหยาบคายหรือสร้างความเกลียดชัง',
          'สแปมหรือโฆษณา',
          'เนื้อหาไม่เกี่ยวข้องหรือคุกคาม',
          'อื่นๆ',
        ];
      case 'report_user':
      default:
        return [
          'รูปโปรไฟล์หรือข้อมูลส่วนตัวไม่เหมาะสม',
          'พฤติกรรมก่อกวนหรือสแปม',
          'บัญชีปลอมหรือแอบอ้าง',
          'อื่นๆ',
        ];
    }
  }

  Future<void> _submitReport() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณาเลือกเหตุผล')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (widget.label == 'ban_user') {
        final currentAdminUID = FirebaseAuth.instance.currentUser?.uid;
        await firestoreService.banUser(
          targetUid: widget.reportedUID,
          reportId: null,
          reporterId: widget.reporterUID,
          reporterName: widget.reporterName,
          reason: _selectedReason!,
          detail: _detailController.text.trim(),
          adminUid: currentAdminUID ?? '',
        );
      } else if (widget.label == 'report_comment' ||
          widget.label == 'report_user') {
        await firestoreService.reportUserAndComment(
          reportedUid: widget.reportedUID,
          reportedName: widget.reportedName,
          reporterUid: widget.reporterUID ?? '',
          reporterName: widget.reporterName ?? '',
          postId: widget.postId ?? '',
          commentId: widget.commentId ?? '',
          commentText: widget.commentText ?? '',
          reason: _selectedReason!,
          detail: _detailController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.label == 'ban_user'
                  ? 'ระงับบัญชีผู้ใช้สำเร็จ'
                  : 'ส่งรายงานสำเร็จ ขอบคุณที่ช่วยดูแลชุมชนของเรา',
            ),
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
          Icon(
            widget.label == 'ban_user' ? Icons.block : Icons.flag,
            color: widgetColors.deleteWidget(),
          ),
          const SizedBox(width: 10),
          Text(
            _dialogTitle,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_dialogSubtitle),
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
              : Text(
                  widget.label == 'ban_user' ? 'ระงับบัญชี (Ban)' : 'ส่งรายงาน',
                  style: const TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }
}
