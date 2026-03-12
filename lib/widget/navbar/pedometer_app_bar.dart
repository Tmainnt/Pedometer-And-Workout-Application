import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pedometer_application/screen/community/admin/banned_user_page.dart';
import 'package:pedometer_application/services/firestore_service.dart';
import 'package:pedometer_application/theme/widget_colors.dart';
import 'package:pedometer_application/screen/community/admin/admin_reports_page.dart';
import 'package:pedometer_application/screen/community/admin/admin_sanctions_page.dart';

class PedometerAppBar extends StatelessWidget implements PreferredSizeWidget {
  PedometerAppBar({super.key});

  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firestoreService.getUserData(),
      builder: (context, snapshot) {
        String role = '';

        if (snapshot.hasData) {
          role = snapshot.data!.role;
        }

        return AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 124, 139, 253),
                  Color.fromARGB(255, 123, 75, 253),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),

          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Pedometer',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              Text(
                '& Workout',
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          leading: role == 'admin'
              ? PopupMenuButton<String>(
                  icon: Icon(
                    Icons.menu,
                    color: WidgetColors().lightTheme(),
                    size: 35,
                  ),
                  onSelected: (value) {
                    if (value == 'reports') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AdminReportsPage()),
                      );
                    } else if (value == 'sanctions') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminSanctionsPage(),
                        ),
                      );
                    } else if (value == 'bannedUsers') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BannedUsersPage(),
                        ),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'reports',
                      child: Row(
                        children: [
                          Icon(Icons.flag),
                          SizedBox(width: 10),
                          Text('ดูรายงาน'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'sanctions',
                      child: Row(
                        children: [
                          Icon(Icons.gavel),
                          SizedBox(width: 10),
                          Text('ประวัติการลงโทษ'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'bannedUsers',
                      child: Row(
                        children: [
                          Icon(Icons.person_off),
                          SizedBox(width: 10),
                          Text('บัญชีที่ถูกระงับ'),
                        ],
                      ),
                    ),
                  ],
                )
              : null,

          actions: [
            IconButton(
              onPressed: () async {
                firestoreService.clearUserCache();
                await FirebaseAuth.instance.signOut();
              },
              icon: const Icon(Icons.logout, color: Colors.white, size: 20),
            ),
          ],

          centerTitle: true,
          elevation: 0,
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
