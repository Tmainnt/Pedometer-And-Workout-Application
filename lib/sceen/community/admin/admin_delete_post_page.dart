import 'package:flutter/material.dart';
import 'package:pedometer_application/models/community/post.dart';
import 'package:pedometer_application/services/firestore_service.dart';
import 'package:pedometer_application/theme/font_color.dart';
import 'package:pedometer_application/theme/widget_colors.dart';

class AdminDeleteReasonPage extends StatefulWidget {
  final Post post;

  const AdminDeleteReasonPage({super.key, required this.post});

  @override
  State<AdminDeleteReasonPage> createState() => _AdminDeleteReasonPageState();
}

class _AdminDeleteReasonPageState extends State<AdminDeleteReasonPage> {
  String reason = 'เนื้อหาไม่เหมาะสม';
  TextEditingController detailController = TextEditingController();
  final WidgetColors widgetColors = WidgetColors();
  final FontColor fontColor = FontColor();
  final FirestoreService firestoreService = FirestoreService();

  List<String> reasons = [
    'เนื้อหาไม่เหมาะสม',
    'สแปม',
    'คำพูดรุนแรง',
    'ข้อมูลเท็จ',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'รายงานการลบโพสต์',
          style: TextStyle(color: fontColor.generalTextDarkTheme()),
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
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.cancel,
            color: Colors.white,
            size: 40,
            shadows: [
              Shadow(
                color: widgetColors.boxShadowColor(),
                blurRadius: 3,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<String>(
              value: reason,
              items: reasons.map((r) {
                return DropdownMenuItem(value: r, child: Text(r));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  reason = value!;
                });
              },
            ),

            const SizedBox(height: 10),

            TextField(
              controller: detailController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'รายละเอียดเพิ่มเติม',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widgetColors.deleteWidget(),
              ),
              onPressed: () async {
                if (detailController.text.isNotEmpty) {
                  await firestoreService.deletePostByAdmin(
                    widget.post,
                    reason,
                    detailController.text,
                  );

                  Navigator.pop(context);
                }
              },
              child: const Text(
                'ยืนยันการลบ',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
