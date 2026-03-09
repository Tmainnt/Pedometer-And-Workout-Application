import 'package:flutter/material.dart';
import 'package:pedometer_application/models/community/notification.dart';
import 'package:pedometer_application/theme/widget_colors.dart';
import 'package:pedometer_application/services/firestore_service.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      body: StreamBuilder<List<NotificationModel>>(
        stream: firestoreService.getNotificationStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("ยังไม่มีการแจ้งเตือน"));
          }

          final notifications = snapshot.data!;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];

              return Card(
                color: notif.isRead ? Colors.white : Colors.grey[100],
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(
                    _getTitle(notif.type),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      if (notif.reason.isNotEmpty)
                        Text("เหตุผล: ${notif.reason}"),
                      if (notif.detail.isNotEmpty)
                        Text("รายละเอียด: ${notif.detail}"),
                      const SizedBox(height: 4),
                      Text(
                        "${notif.createTimestamp.day}/${notif.createTimestamp.month}/${notif.createTimestamp.year}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      firestoreService.deleteNotification(notif.id);
                    },
                    icon: Icon(
                      Icons.cancel,
                      color: WidgetColors().iconColorMoreDark(),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _getTitle(String type) {
    switch (type) {
      case "post_deleted":
        return "โพสต์ของคุณถูกลบ";
      case "reply_comment":
        return "มีการตอบกลับข้อความ";
      case "comment":
        return "มีความคิดเห็นใหม่";
      default:
        return "การแจ้งเตือน";
    }
  }
}
